"""Normalized input and output records shared by ANSIA support modules."""

from dataclasses import dataclass

import pandas as pd


@dataclass(frozen=True)
class Plant:
    key: str
    name: str
    remote_file: str
    file_name: str
    layout: str
    flow_unit: str
    design_flow_m3_s: float
    max_power_kw: float


@dataclass
class HydroSeries:
    plant: Plant
    samples: pd.DataFrame


@dataclass(frozen=True)
class HydroMetrics:
    last_timestamp: object
    last_power_kw: float
    last_flow_m3_s: float
    last_pressure_bar: float
    last_efficiency_pct: float | None
    energy_kwh: float
    volume_m3: float
    mean_head_m: float | None
    daily_efficiency_pct: float | None
    design_flow_pct: float | None
    sample_count: int
