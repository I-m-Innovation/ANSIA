"""Hydro data acquisition and schema normalization for active ANSIA plants."""

from ftplib import FTP
from pathlib import Path
from io import BytesIO
import os

import pandas as pd

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
    return pd.read_csv(BytesIO(payload), sep=None, engine="python", dtype=str)


def _number(values):
    normalized = values.astype("string").str.strip().str.replace(",", ".", regex=False)
    return pd.to_numeric(normalized, errors="coerce")


def _local_timestamps(values, timezone):
    parsed = pd.to_datetime(values, errors="coerce", dayfirst=True)
    if getattr(parsed.dt, "tz", None) is None:
        parsed = parsed.dt.tz_localize(timezone, ambiguous="NaT", nonexistent="shift_forward")
    else:
        parsed = parsed.dt.tz_convert(timezone)
    return parsed


def _normalize(frame, plant, timezone):
    if plant.layout == "long":
        required = {"VarName", "TimeString", "VarValue"}
        if not required.issubset(frame.columns):
            raise ValueError(f"{plant.name}: expected columns {sorted(required)}")
        aliases = {
            "Potenza_FTP": "power_kw",
            "Portata_FTP": "flow_m3_s",
            "Pressione_FTP": "pressure_bar",
        }
        frame = frame.loc[frame["VarName"].isin(aliases), ["VarName", "TimeString", "VarValue"]].copy()
        frame["value"] = _number(frame["VarValue"])
        frame["timestamp"] = _local_timestamps(frame["TimeString"], timezone)
        wide = frame.pivot_table(index="timestamp", columns="VarName", values="value", aggfunc="last")
        wide = wide.rename(columns=aliases).reset_index()
        for column in ("power_kw", "flow_m3_s", "pressure_bar"):
            if column not in wide:
                wide[column] = float("nan")
        if plant.flow_unit == "l/s":
            wide["flow_m3_s"] = wide["flow_m3_s"] / 1000
        samples = wide[["timestamp", "power_kw", "flow_m3_s", "pressure_bar"]]
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
        samples = frame[list(columns)].rename(columns=columns).copy()
        samples["timestamp"] = _local_timestamps(samples["timestamp"], timezone)
        for column in ("power_kw", "flow_m3_s", "pressure_bar"):
            samples[column] = _number(samples[column])
        if plant.flow_unit == "l/s":
            samples["flow_m3_s"] = samples["flow_m3_s"] / 1000

    today = pd.Timestamp.now(tz=timezone).normalize()
    samples = samples.loc[samples["timestamp"] >= today].copy()
    if samples.empty:
        raise ValueError(f"{plant.name}: no valid samples for {today.date()}")
    return samples.sort_values("timestamp").reset_index(drop=True)


def fetch_hydro_data(plant, settings):
    """Fetch one configured plant and return today's normalized samples."""
    raw = _read_csv(_download(plant, settings))
    return HydroSeries(plant=plant, samples=_normalize(raw, plant, settings.timezone))
