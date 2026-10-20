"""Runtime entry points for ANSIA report calculations."""

from Scripts.dashboard_service.status import calculate_dashboard_status


class calculation:
    """Calculate daily metrics for one normalized hydro plant series."""

    def calculate_daily_metrics(self, series, plant):
        # Numba è caricato solo nel percorso ANSIA; L'Occhio non paga il costo d'import del JIT.
        from Scripts.calculator_service.metrics import calculate_hydro_metrics

        return calculate_hydro_metrics(series, plant)

    def calculate_dashboard_status(self, data, now):
        return calculate_dashboard_status(data, now)
