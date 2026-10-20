"""Dashboard data records returned by source adapters."""

from dataclasses import dataclass

import polars as pl


@dataclass(frozen=True)
class DashboardPlant:
    key: str
    name: str
    kind: str
    nominal_kw: float | None = None
    design_flow_m3_s: float | None = None


@dataclass
class DashboardData:
    plant: DashboardPlant
    # Tabella larga: timestamp condivisi una volta sola, una colonna numerica per ogni flusso.
    samples: pl.DataFrame
    units: dict[str, str]
