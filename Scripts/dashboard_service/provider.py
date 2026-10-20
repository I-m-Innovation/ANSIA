"""Fetch and normalize data for the L'Occhio dashboard using Polars tables."""

from datetime import datetime, time, timezone

import polars as pl
import requests

from Scripts.calculator_service.data_sources import PLANTS as HYDRO_PLANTS
from Scripts.calculator_service.data_sources import fetch_hydro_data
from Scripts.dashboard_service.models import DashboardData


HYDRO_BY_KEY = {plant.key: plant for plant in HYDRO_PLANTS}


def _wide_streams(streams, timezone_name):
    """Combine timestamp/value frames into one table with a shared timestamp column."""
    records = []
    for name, frame in streams.items():
        records.extend(
            (timestamp, name, float(value))
            for timestamp, value in frame.select("timestamp", "value").iter_rows()
            if timestamp is not None and value is not None
        )
    schema = {
        "timestamp": pl.Datetime("us", time_zone=str(timezone_name)),
        "name": pl.String,
        "value": pl.Float64,
    }
    if not records:
        return pl.DataFrame(
            schema={
                "timestamp": schema["timestamp"],
                **{name: pl.Float64 for name in streams},
            }
        )
    long = pl.DataFrame(records, schema=schema, orient="row")
    result = (
        long.group_by(["timestamp", "name"], maintain_order=True)
        .agg(pl.col("value").last())
        .pivot(on="name", index="timestamp", values="value", aggregate_function="last")
        .sort("timestamp")
    )
    for name in streams:
        if name not in result.columns:
            result = result.with_columns(pl.lit(None, dtype=pl.Float64).alias(name))
    return result.select("timestamp", *streams.keys())


def _higeco_streams(settings, hsi, plant_id, device_id, log_id, variables):
    username = settings.hsi_username if hsi else settings.higeco_username
    password = settings.hsi_password if hsi else settings.higeco_password
    base_url = settings.hsi_base_url if hsi else settings.higeco_base_url
    if not username or not password:
        label = "HSI_USERNAME/HSI_PASSWORD" if hsi else "HIGECO_USERNAME/HIGECO_PASSWORD"
        raise ValueError(f"Configure {label} in .env to load this plant")

    session = requests.Session()
    try:
        auth = session.post(
            f"{base_url}/authenticate",
            json={"username": username, "password": password},
            timeout=settings.api_timeout,
        )
        auth.raise_for_status()
        token = auth.json().get("token")
        if not token:
            raise ValueError("The monitoring API did not return an authorization token")

        now = datetime.now(settings.timezone)
        start = datetime.combine(now.date(), time.min, tzinfo=settings.timezone)
        params = {"from": int(start.timestamp()), "to": int(now.timestamp())}
        streams = {}
        for name, variable_id in variables.items():
            response = session.get(
                f"{base_url}/getLogData/{plant_id}/{device_id}/{log_id}/{variable_id}",
                params=params,
                headers={"authorization": token, "Content-Type": "application/json"},
                timeout=settings.api_timeout,
            )
            response.raise_for_status()
            records = []
            for row in response.json().get("data", []):
                if isinstance(row, dict):
                    stamp = row.get("timestamp", row.get("time", row.get("t")))
                    value = row.get("value", row.get("v"))
                elif isinstance(row, (list, tuple)) and len(row) >= 2:
                    stamp, value = row[0], row[1]
                else:
                    continue
                try:
                    timestamp = datetime.fromtimestamp(float(stamp), tz=timezone.utc).astimezone(settings.timezone)
                    records.append((timestamp, float(value)))
                except (TypeError, ValueError, OverflowError, OSError):
                    continue
            streams[name] = pl.DataFrame(
                records,
                schema={
                    "timestamp": pl.Datetime("us", time_zone=str(settings.timezone)),
                    "value": pl.Float64,
                },
                orient="row",
            )
        return _wide_streams(streams, settings.timezone)
    finally:
        session.close()


def _hydro_dashboard(plant, settings):
    source = HYDRO_BY_KEY[plant.key]
    samples = fetch_hydro_data(source, settings).samples
    dashboard_samples = samples.select(
        "timestamp",
        pl.col("power_kw").alias("Potenza"),
        pl.col("flow_m3_s").alias("Portata"),
        pl.col("pressure_bar").alias("Pressione"),
    )
    return DashboardData(
        plant,
        dashboard_samples,
        {"Potenza": "kW", "Portata": "m3/s", "Pressione": "bar"},
    )


def _hourly_energy(samples, timezone_name):
    """Approximate hourly kWh from hourly mean kW, matching EnergyData.m."""
    hourly = (
        samples.sort("timestamp")
        .group_by_dynamic("timestamp", every="1h")
        .agg(pl.col("power_kw").mean().alias("value"))
        .drop_nulls("value")
    )
    if not hourly.is_empty():
        # L'ora ancora in corso non rappresenta 60 minuti di produzione: scala la media sulla durata trascorsa.
        now = datetime.now(timezone_name)
        elapsed = now.minute * 60 + now.second
        last_stamp = hourly.get_column("timestamp")[-1]
        if elapsed > 0 and last_stamp.replace(minute=0, second=0, microsecond=0) == now.replace(minute=0, second=0, microsecond=0):
            hourly = hourly.with_columns(
                pl.when(pl.col("timestamp") == last_stamp)
                .then(pl.col("value") * elapsed / 3600)
                .otherwise(pl.col("value"))
                .alias("value")
            )
    return hourly


def fetch_dashboard_data(plant, settings, scn_sections=("Sezione 1", "Sezione 2")):
    """Fetch one plant's current time-series data for display."""
    if plant.kind == "hydro":
        return _hydro_dashboard(plant, settings)

    if plant.kind == "combined":
        san_teodoro = _hourly_energy(fetch_hydro_data(HYDRO_BY_KEY["ST"], settings).samples, settings.timezone)
        partitore = _hourly_energy(fetch_hydro_data(HYDRO_BY_KEY["Partitore"], settings).samples, settings.timezone)
        samples = _wide_streams(
            {"San Teodoro": san_teodoro, "Partitore": partitore},
            settings.timezone,
        )
        return DashboardData(plant, samples, {"San Teodoro": "kWh", "Partitore": "kWh"})

    if plant.kind == "pv":
        samples = _higeco_streams(
            settings, False, 992, "3189OVTGIDEF", 1042331,
            {"Potenza": 1042331001, "Irraggiamento": 1042331009},
        )
        return DashboardData(plant, samples, {"Potenza": "kW", "Irraggiamento": "W/m2"})

    if plant.kind == "scn":
        streams = _higeco_streams(
            settings, False, 1032, "2589LJTGI818", 1042242,
            {
                "Potenza totale": 1042242001,
                "Sezione 1": 1042242101,
                "Sezione 2": 1042242121,
                "Irraggiamento": 1042242009,
            },
        )
        if not scn_sections:
            raise ValueError("Select at least one SCN section")
        selected = ["Potenza totale"] if len(scn_sections) == 2 else [scn_sections[0]]
        if len(scn_sections) == 1 and scn_sections[0] in {"Sezione 1", "Sezione 2"}:
            selected = [scn_sections[0]]
        return DashboardData(
            plant,
            streams.select("timestamp", *selected, "Irraggiamento"),
            {"Potenza totale": "kW", "Sezione 1": "kW", "Sezione 2": "kW", "Irraggiamento": "W/m2"},
        )

    if plant.kind == "hsi":
        identifiers = {
            "Potenza prelevata": 1999813104,
            "Potenza prodotta": 1999813105,
            "Potenza immessa": 1999813106,
            "Autoconsumo": 1999813107,
        }
        samples = _higeco_streams(settings, True, 53, "2360PGKGI8E8", 1999813, identifiers)
        return DashboardData(plant, samples, {name: "kW" for name in identifiers})

    raise ValueError(f"Unsupported plant type: {plant.kind}")
