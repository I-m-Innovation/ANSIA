"""Environment configuration. Secrets are read from the local .env file."""

from dataclasses import dataclass
from datetime import time
import os
from pathlib import Path
from zoneinfo import ZoneInfo

from dotenv import load_dotenv


APP_DIR = Path(__file__).resolve().parents[1]
load_dotenv(APP_DIR / ".env")


def _clock(value, fallback):
    hour, minute = map(int, os.getenv(value, fallback).split(":"))
    return time(hour, minute)


def _path(value, fallback):
    path = Path(os.getenv(value, str(fallback))).expanduser()
    return path if path.is_absolute() else APP_DIR / path


@dataclass(frozen=True)
class Settings:
    timezone: ZoneInfo
    data_source: str
    data_dir: Path
    ftp_host: str
    ftp_port: int
    ftp_username: str
    ftp_password: str
    ftp_timeout: int
    smtp_enabled: bool
    smtp_host: str
    smtp_port: int
    smtp_username: str
    smtp_password: str
    smtp_from: str
    smtp_to: tuple[str, ...]
    smtp_use_starttls: bool
    smtp_use_ssl: bool
    subject: str
    output_dir: Path
    interval_minutes: int
    start_time: time
    end_time: time


def load_settings():
    """Load runtime settings, with safe local-preview defaults."""
    timezone_name = os.getenv("REPORT_TIMEZONE", "Europe/Rome")
    data_source = os.getenv("DATA_SOURCE", "local").strip().lower()
    if data_source not in {"local", "ftp"}:
        raise ValueError("DATA_SOURCE must be 'local' or 'ftp'")

    csv_to = os.getenv("SMTP_TO", "")
    return Settings(
        timezone=ZoneInfo(timezone_name),
        data_source=data_source,
        data_dir=_path("DATA_DIR", APP_DIR / "data"),
        ftp_host=os.getenv("FTP_HOST", ""),
        ftp_port=int(os.getenv("FTP_PORT", "21")),
        ftp_username=os.getenv("FTP_USERNAME", ""),
        ftp_password=os.getenv("FTP_PASSWORD", ""),
        ftp_timeout=int(os.getenv("FTP_TIMEOUT", "30")),
        smtp_enabled=os.getenv("SMTP_ENABLED", "false").lower() in {"1", "true", "yes"},
        smtp_host=os.getenv("SMTP_HOST", ""),
        smtp_port=int(os.getenv("SMTP_PORT", "587")),
        smtp_username=os.getenv("SMTP_USERNAME", ""),
        smtp_password=os.getenv("SMTP_PASSWORD", ""),
        smtp_from=os.getenv("SMTP_FROM", ""),
        smtp_to=tuple(address.strip() for address in csv_to.split(",") if address.strip()),
        smtp_use_starttls=os.getenv("SMTP_USE_STARTTLS", "true").lower() in {"1", "true", "yes"},
        smtp_use_ssl=os.getenv("SMTP_USE_SSL", "false").lower() in {"1", "true", "yes"},
        subject=os.getenv("SMTP_SUBJECT", "Report giornaliero impianti"),
        output_dir=_path("REPORT_OUTPUT_DIR", APP_DIR / "output"),
        interval_minutes=max(1, int(os.getenv("REPORT_INTERVAL_MINUTES", "60"))),
        start_time=_clock("REPORT_START_TIME", "05:30"),
        end_time=_clock("REPORT_END_TIME", "23:59"),
    )
