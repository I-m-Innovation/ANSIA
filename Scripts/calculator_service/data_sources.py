"""Hydro data acquisition and schema normalization for active ANSIA plants."""

import csv
from datetime import datetime
from ftplib import FTP
from io import BytesIO
import os
from pathlib import Path

import polars as pl

from Scripts.models import HydroSeries, Plant


PLANTS = (
    Plant("SA3", "SA3", "dati/SA3/SA3last24hTL.csv", "SA3last24hTL.csv", "timeseries", "m3/s", 3.0, 249.0),
    Plant("TF", "Torrino Foresta", "dati/Torrino_Foresta/DBTFNEW5.csv", "DBTFNEW5.csv", "plc", "m3/s", 1.54, 249.0),
    Plant("PG", "Ponte Giurino", "dati/ponte_giurino/PGlast24hTL.csv", "PGlast24hTL.csv", "timeseries", "m3/s", 0.070, 200.0),
    Plant("Partitore", "Partitore", "dati/San_Teodoro/201833_Partitore.csv", "201833_Partitore.csv", "long", "l/s", 0.025, 84.86),
    Plant("ST", "San Teodoro", "dati/San_Teodoro/201832_SanTeodoro.csv", "201832_SanTeodoro.csv", "long", "l/s", 0.070, 238.30),
)

def _download(plant, settings):
    local_path = settings.data_dir / Path(plant.remote_file)
    if settings.data_source == "local":
        if not local_path.is_file():
            raise FileNotFoundError(
                f"Missing local source {local_path}; set DATA_SOURCE=ftp or populate DATA_DIR"
            )
        return local_path.read_bytes()

    if not settings.ftp_host or not settings.ftp_username or not settings.ftp_password:
        raise ValueError("FTP_HOST, FTP_USERNAME and FTP_PASSWORD are required for DATA_SOURCE=ftp")

    remote_root = os.getenv("FTP_REMOTE_ROOT", "").strip("/")
    remote_file = f"{remote_root}/{plant.remote_file}" if remote_root else plant.remote_file
    payload = BytesIO()
    with FTP() as ftp:
        ftp.connect(settings.ftp_host, settings.ftp_port, timeout=settings.ftp_timeout)
        ftp.login(settings.ftp_username, settings.ftp_password)
        ftp.retrbinary(f"RETR {remote_file}", payload.write)

    local_path.parent.mkdir(parents=True, exist_ok=True)
    local_path.write_bytes(payload.getvalue())
    return payload.getvalue()


def _read_csv(payload):
    """Read CSV text columns with Polars, detecting the common delimiter once."""
    sample = payload[:8192].decode("utf-8-sig", errors="replace")
    try:
        delimiter = csv.Sniffer().sniff(sample, delimiters=",;\t").delimiter
    except csv.Error:
        delimiter = ","
    return pl.read_csv(
        BytesIO(payload),
        separator=delimiter,
        infer_schema=False,
        encoding="utf8-lossy",
    )


def _number(column):
    """Return a Polars expression parsing dot or comma decimal notation."""
    return (
        pl.col(column)
        .cast(pl.String)
        .str.strip_chars()
        .str.replace_all(",", ".")
        .cast(pl.Float64, strict=False)
    )


def _local_timestamps(column, timezone):
    """Parse common PLC/CSV datetime layouts and localize naive values."""
    value = pl.col(column).cast(pl.String).str.strip_chars()
    formats = (
        "%d/%m/%Y %H:%M:%S%.f",
        "%d/%m/%Y %H:%M:%S",
        "%d/%m/%Y %H:%M",
        "%d-%m-%Y %H:%M:%S%.f",
        "%d-%m-%Y %H:%M:%S",
        "%d-%m-%Y %H:%M",
        "%Y-%m-%d %H:%M:%S%.f",
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%d %H:%M",
        "%Y-%m-%dT%H:%M:%S%.f",
        "%Y-%m-%dT%H:%M:%S",
    )
    parsed = pl.coalesce(
        [value.str.strptime(pl.Datetime("us"), fmt, strict=False) for fmt in formats]
    )
    # L'ambiguità/non esistenza dell'ora DST diventa null e viene esclusa durante il filtro.
    return parsed.dt.replace_time_zone(str(timezone), ambiguous="null", non_existent="null")


def _normalize(frame, plant, timezone):
    """Convert configured CSV layouts to one compact, typed Polars table."""
    if plant.layout == "long":
        required = {"VarName", "TimeString", "VarValue"}
        if not required.issubset(frame.columns):
            raise ValueError(f"{plant.name}: expected columns {sorted(required)}")
        aliases = {
            "Potenza_FTP": "power_kw",
            "Portata_FTP": "flow_m3_s",
            "Pressione_FTP": "pressure_bar",
        }
        frame = frame.filter(pl.col("VarName").is_in(list(aliases)))
        if frame.is_empty():
            samples = pl.DataFrame(
                schema={
                    "timestamp": pl.Datetime("us", time_zone=str(timezone)),
                    "power_kw": pl.Float64,
                    "flow_m3_s": pl.Float64,
                    "pressure_bar": pl.Float64,
                }
            )
        else:
            frame = (
                frame
                .select("VarName", "TimeString", "VarValue")
                .with_columns(
                    _number("VarValue").alias("value"),
                    _local_timestamps("TimeString", timezone).alias("timestamp"),
                )
                .group_by(["timestamp", "VarName"], maintain_order=True)
                .agg(pl.col("value").last())
                .pivot(on="VarName", index="timestamp", values="value", aggregate_function="last")
            )
            frame = frame.rename({source: target for source, target in aliases.items() if source in frame.columns})
            for column in ("power_kw", "flow_m3_s", "pressure_bar"):
                if column not in frame.columns:
                    frame = frame.with_columns(pl.lit(None, dtype=pl.Float64).alias(column))
            samples = frame.select("timestamp", "power_kw", "flow_m3_s", "pressure_bar")
    else:
        if plant.layout == "timeseries":
            columns = {"t": "timestamp", "P": "power_kw", "Q": "flow_m3_s", "Bar": "pressure_bar"}
        else:
            columns = {
                "Local": "timestamp",
                "PLC1_AI_POT_ATTIVA": "power_kw",
                "PLC1_AI_FT_PORT_IST": "flow_m3_s",
                "PLC1_AI_PT_TURBINA": "pressure_bar",
            }
        missing = set(columns) - set(frame.columns)
        if missing:
            raise ValueError(f"{plant.name}: missing columns {sorted(missing)}")
        timestamp_source = next(source for source, target in columns.items() if target == "timestamp")
        samples = frame.select(
            _local_timestamps(timestamp_source, timezone).alias("timestamp"),
            *[
                _number(source).alias(target)
                for source, target in columns.items()
                if target != "timestamp"
            ],
        )

    if plant.flow_unit == "l/s":
        samples = samples.with_columns((pl.col("flow_m3_s") / 1000).alias("flow_m3_s"))

    today_date = datetime.now(timezone).date()
    today = pl.col("timestamp").dt.date() == pl.lit(today_date)
    samples = samples.filter(today).sort("timestamp")
    if samples.is_empty():
        raise ValueError(f"{plant.name}: no valid samples for {today_date}")
    return samples


def fetch_hydro_data(plant, settings):
    """Fetch one configured plant and return today's normalized samples."""
    raw = _read_csv(_download(plant, settings))
    return HydroSeries(plant=plant, samples=_normalize(raw, plant, settings.timezone))
