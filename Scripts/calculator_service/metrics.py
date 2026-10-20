"""Pure calculation helpers for normalized hydroelectric time series."""

import math

import numpy as np

from Scripts.models import HydroMetrics


def _finite(values):
    return np.asarray(values, dtype=float)


def calculate_hydro_metrics(series, plant):
    """Integrate power and flow with trapezoids and compute hydro indicators.

    Normalized input units are kW, m³/s and bar. Samples are sorted before
    integration; rows with an invalid timestamp or any invalid measurement are
    ignored. A single sample has zero integrated energy and volume.
    """
    samples = series.samples.dropna(subset=["timestamp"]).sort_values("timestamp")
    samples = samples.drop_duplicates(subset=["timestamp"], keep="last")
    for column in ("power_kw", "flow_m3_s", "pressure_bar"):
        samples[column] = np.asarray(samples[column], dtype=float)
    samples = samples.replace([np.inf, -np.inf], np.nan).dropna(
        subset=["power_kw", "flow_m3_s", "pressure_bar"]
    )
    if samples.empty:
        raise ValueError(f"No valid samples for {plant.name}")

    times = samples["timestamp"].astype("int64").to_numpy(dtype=float) / 1e9
    power = _finite(samples["power_kw"])
    flow = _finite(samples["flow_m3_s"])
    pressure = _finite(samples["pressure_bar"])
    seconds = np.diff(times)
    energy_kwh = float(np.sum(seconds * (power[:-1] + power[1:]) / 2 / 3600))
    volume_m3 = float(np.sum(seconds * (flow[:-1] + flow[1:]) / 2))

    head = pressure * 10.1974
    mean_head = float(np.mean(head)) if len(head) else None
    last_power, last_flow, last_pressure = float(power[-1]), float(flow[-1]), float(pressure[-1])
    last_denominator = 9.81 * head[-1] * last_flow
    last_efficiency = (last_power / last_denominator * 100) if last_denominator > 0 else None
    daily_denominator = 9.81 * volume_m3 * mean_head if mean_head and volume_m3 > 0 else 0
    daily_efficiency = energy_kwh * 3600 / daily_denominator * 100 if daily_denominator > 0 else None
    design_flow_pct = (
        volume_m3 / (plant.design_flow_m3_s * 86400) * 100
        if plant.design_flow_m3_s > 0
        else None
    )

    return HydroMetrics(
        last_timestamp=samples["timestamp"].iloc[-1],
        last_power_kw=last_power,
        last_flow_m3_s=last_flow,
        last_pressure_bar=last_pressure,
        last_efficiency_pct=last_efficiency if last_efficiency is None or math.isfinite(last_efficiency) else None,
        energy_kwh=energy_kwh,
        volume_m3=volume_m3,
        mean_head_m=mean_head,
        daily_efficiency_pct=daily_efficiency if daily_efficiency is None or math.isfinite(daily_efficiency) else None,
        design_flow_pct=design_flow_pct,
        sample_count=len(samples),
    )
