"""Operational lamp and efficiency calculations for L'Occhio."""

from dataclasses import dataclass
from datetime import datetime
import math

import polars as pl


COLORS = {"green": "#238636", "red": "#cf222e", "amber": "#bf8700", "gray": "#8c959f"}


@dataclass(frozen=True)
class DashboardStatus:
    color: str
    message: str
    last_seen: datetime | None
    efficiency: str


def _latest(samples, name):
    """Get the newest finite value for one stream from the shared table."""
    if name not in samples.columns:
        return None, None
    latest = (
        samples.select("timestamp", name)
        .filter(pl.col(name).is_not_null() & pl.col(name).is_finite())
        .sort("timestamp")
        .tail(1)
    )
    if latest.is_empty():
        return None, None
    timestamp, value = latest.row(0)
    return timestamp, float(value)


def calculate_dashboard_status(data, now):
    names = [name for name in data.samples.columns if name != "timestamp"]
    latest_values = {name: _latest(data.samples, name) for name in names}
    timestamps = [stamp for stamp, _ in latest_values.values() if stamp is not None]
    if not timestamps:
        return DashboardStatus("gray", "Nessun dato disponibile", None, "")

    last_seen = max(timestamps)
    age_minutes = max(0, (now - last_seen).total_seconds() / 60)
    color, message = "green", "Comunicazione regolare"
    if age_minutes > 20:
        color, message = "amber", f"Dato non aggiornato da {age_minutes:.0f} min"

    values = {name: value for name, (_, value) in latest_values.items()}
    efficiency = ""
    if data.plant.kind in {"hydro", "combined"}:
        power = values.get("Potenza")
        flow = values.get("Portata")
        pressure = values.get("Pressione")
        if data.plant.kind == "hydro" and power is not None and power <= 0 and color == "green":
            color, message = "red", "Potenza nulla"
        if power is not None and flow is not None and pressure is not None:
            denominator = 9.81 * pressure * 10.1974 * flow
            if denominator > 0:
                efficiency = f"η {power / denominator * 100:.1f}%"
    elif data.plant.kind in {"pv", "scn"}:
        irradiation = values.get("Irraggiamento")
        power_names = [name for name in values if name != "Irraggiamento"]
        power = values.get("Potenza totale") if data.plant.kind == "scn" else values.get("Potenza")
        if power is None and power_names:
            power = values[power_names[0]]
        if irradiation is not None and irradiation < 100:
            color, message = "gray", "Irraggiamento basso"
        elif power is not None and power < 1:
            color, message = "red", "Produzione nulla"
        if power is not None and irradiation and data.plant.nominal_kw:
            pr = power / irradiation / data.plant.nominal_kw * 1000 * 100
            if math.isfinite(pr):
                efficiency = f"PR {pr:.1f}%"
    elif data.plant.kind == "hsi":
        produced = values.get("Potenza prodotta")
        consumed = values.get("Autoconsumo")
        if produced is not None and consumed is not None and produced <= 0 and consumed <= 0:
            color, message = "red", "Produzione e autoconsumo nulli"

    return DashboardStatus(color, message, last_seen, efficiency)
