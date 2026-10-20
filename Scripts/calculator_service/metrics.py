"""Polars preparation and Numba-compiled hydro metric calculations."""

import math

import numba
import numpy as np
import polars as pl

from Scripts.models import HydroMetrics


@numba.njit(cache=True)
def _integrate_hydro(times_seconds, power_kw, flow_m3_s, pressure_bar, design_flow_m3_s):
    """Run the numeric integration loop as compiled machine code."""
    energy_kwh = 0.0
    volume_m3 = 0.0
    head_sum = 0.0
    for index in range(len(times_seconds)):
        head_sum += pressure_bar[index] * 10.1974
        if index:
            elapsed = times_seconds[index] - times_seconds[index - 1]
            energy_kwh += elapsed * (power_kw[index - 1] + power_kw[index]) / 2.0 / 3600.0
            volume_m3 += elapsed * (flow_m3_s[index - 1] + flow_m3_s[index]) / 2.0

    mean_head_m = head_sum / len(times_seconds)
    last_head_m = pressure_bar[-1] * 10.1974
    last_denominator = 9.81 * last_head_m * flow_m3_s[-1]
    last_efficiency_pct = (
        power_kw[-1] / last_denominator * 100.0 if last_denominator > 0 else np.nan
    )
    daily_denominator = 9.81 * volume_m3 * mean_head_m
    daily_efficiency_pct = (
        energy_kwh * 3600.0 / daily_denominator * 100.0 if daily_denominator > 0 else np.nan
    )
    design_flow_pct = (
        volume_m3 / (design_flow_m3_s * 86400.0) * 100.0 if design_flow_m3_s > 0 else np.nan
    )
    return (
        energy_kwh,
        volume_m3,
        mean_head_m,
        last_efficiency_pct,
        daily_efficiency_pct,
        design_flow_pct,
    )


def calculate_hydro_metrics(series, plant):
    """Integrate normalized hydro measurements and return daily indicators."""
    samples = (
        series.samples
        .filter(pl.col("timestamp").is_not_null())
        .unique(subset="timestamp", keep="last", maintain_order=True)
        .sort("timestamp")
        .filter(
            pl.col("power_kw").is_finite()
            & pl.col("flow_m3_s").is_finite()
            & pl.col("pressure_bar").is_finite()
        )
    )
    if samples.is_empty():
        raise ValueError(f"No valid samples for {plant.name}")

    # Polars conserva timestamp compatto; il JIT riceve solo array numerici contigui.
    times = samples.get_column("timestamp").cast(pl.Int64).to_numpy().astype(np.float64) / 1_000_000.0
    power = np.ascontiguousarray(samples.get_column("power_kw").to_numpy(), dtype=np.float64)
    flow = np.ascontiguousarray(samples.get_column("flow_m3_s").to_numpy(), dtype=np.float64)
    pressure = np.ascontiguousarray(samples.get_column("pressure_bar").to_numpy(), dtype=np.float64)
    (
        energy_kwh,
        volume_m3,
        mean_head_m,
        last_efficiency_pct,
        daily_efficiency_pct,
        design_flow_pct,
    ) = _integrate_hydro(times, power, flow, pressure, plant.design_flow_m3_s)

    return HydroMetrics(
        last_timestamp=samples.get_column("timestamp")[-1],
        last_power_kw=float(power[-1]),
        last_flow_m3_s=float(flow[-1]),
        last_pressure_bar=float(pressure[-1]),
        last_efficiency_pct=float(last_efficiency_pct) if math.isfinite(last_efficiency_pct) else None,
        energy_kwh=float(energy_kwh),
        volume_m3=float(volume_m3),
        mean_head_m=float(mean_head_m),
        daily_efficiency_pct=float(daily_efficiency_pct) if math.isfinite(daily_efficiency_pct) else None,
        design_flow_pct=float(design_flow_pct) if math.isfinite(design_flow_pct) else None,
        sample_count=samples.height,
    )
