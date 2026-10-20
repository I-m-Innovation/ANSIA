"""Plant selection order and settings represented by the L'Occhio UI."""

from Scripts.dashboard_service.models import DashboardPlant


PLANTS = (
    DashboardPlant("ST", "San Teodoro", "hydro", design_flow_m3_s=0.070),
    DashboardPlant("PP", "Condotta San Teodoro", "combined"),
    DashboardPlant("Partitore", "Partitore", "hydro", design_flow_m3_s=0.025),
    DashboardPlant("PG", "Ponte Giurino", "hydro", design_flow_m3_s=0.080),
    DashboardPlant("TF", "Torrino Foresta", "hydro", design_flow_m3_s=1.54),
    DashboardPlant("SCN", "SCN - Pilota", "scn", 926.64),
    DashboardPlant("Rubino", "Rubino", "pv", 997.92),
    DashboardPlant("HSI", "Zilio Group 20 kW", "hsi", 20.0),
    DashboardPlant("SA3", "SA3", "hydro", design_flow_m3_s=1.80),
)

PLANTS_BY_NAME = {plant.name: plant for plant in PLANTS}
