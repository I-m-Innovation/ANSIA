"""Runtime entry points for ANSIA report calculations."""

from Scripts.metrics import calculate_hydro_metrics


class calculation:
    """Calculate daily metrics for one normalized hydro plant series."""

    def calculate_daily_metrics(self, series, plant):
        return calculate_hydro_metrics(series, plant)
