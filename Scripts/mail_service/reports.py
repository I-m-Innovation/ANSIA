"""HTML and chart rendering for daily hydro reports."""

from html import escape
from io import BytesIO

import matplotlib

matplotlib.use("Agg")
import matplotlib.dates as mdates
import matplotlib.pyplot as plt


def _fmt(value, digits=1):
    return "N.D." if value is None else f"{value:,.{digits}f}".replace(",", "X").replace(".", ",").replace("X", ".")


def _chart(series):
    frame = series.samples
    fig, left = plt.subplots(figsize=(9, 4), constrained_layout=True)
    timestamps = frame.get_column("timestamp").to_list()
    power = frame.get_column("power_kw").to_numpy()
    flow = frame.get_column("flow_m3_s").to_numpy()
    left.fill_between(timestamps, power, alpha=0.45, color="#4f9d69")
    left.plot(timestamps, power, color="#287343", linewidth=1.4, label="Potenza")
    left.set_ylabel("Potenza [kW]")
    left.set_ylim(bottom=0)
    right = left.twinx()
    right.plot(timestamps, flow, color="#2788b5", linewidth=1.3, label="Portata")
    right.set_ylabel("Portata [m³/s]")
    right.set_ylim(bottom=0)
    timezone = timestamps[0].tzinfo
    left.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M", tz=timezone))
    left.grid(True, alpha=0.25)
    left.set_title(series.plant.name)
    # Il PNG rimane in memoria: lo stesso payload può essere allegato inline o scritto nell'anteprima.
    output = BytesIO()
    fig.savefig(output, format="png", dpi=130)
    plt.close(fig)
    return output.getvalue()


def build_daily_report(plant, series, metrics, unavailable=False):
    """Return an HTML section and an optional ``(cid, filename, bytes)`` image."""
    title = escape(plant.name)
    if unavailable or metrics is None or series is None:
        return (
            f"<h2>{title}</h2><p style='color:#b42318;text-align:center'><b>NO LINK</b></p>",
            None,
        )

    timestamp = metrics.last_timestamp.strftime("%d/%m/%Y %H:%M")
    rows = [
        ("Ora ultimo dato", timestamp),
        ("Portata attuale", f"{_fmt(metrics.last_flow_m3_s, 3)} m³/s"),
        ("Potenza attuale", f"{_fmt(metrics.last_power_kw, 1)} kW"),
        ("Rendimento attuale", f"{_fmt(metrics.last_efficiency_pct, 1)} %"),
        ("Volume giornaliero", f"{_fmt(metrics.volume_m3, 0)} m³"),
        ("Energia giornaliera", f"{_fmt(metrics.energy_kwh, 0)} kWh"),
        ("Rendimento giornaliero", f"{_fmt(metrics.daily_efficiency_pct, 1)} %"),
        ("Portata rispetto al riferimento", f"{_fmt(metrics.design_flow_pct, 1)} %"),
    ]
    table = "".join(
        f"<tr><th style='text-align:left;padding:5px'>{escape(label)}</th>"
        f"<td style='text-align:right;padding:5px'>{escape(value)}</td></tr>"
        for label, value in rows
    )
    cid = f"ansia-{plant.key.lower()}"
    image = (cid, f"{plant.key}.png", _chart(series))
    section = (
        f"<h2>{title}</h2><table style='border-collapse:collapse'>{table}</table>"
        f"<p><img alt='Grafico {title}' style='max-width:100%;height:auto' src='cid:{cid}'></p>"
        f"<small>Campioni utilizzati: {metrics.sample_count}</small>"
    )
    return section, image


def save_preview(html, images, output_dir):
    """Save a self-contained local preview when SMTP is not enabled."""
    output_dir.mkdir(parents=True, exist_ok=True)
    html_path = output_dir / "ansia-report.html"
    for cid, filename, payload in images:
        (output_dir / filename).write_bytes(payload)
        html = html.replace(f"cid:{cid}", filename)
    html_path.write_text(
        "<!doctype html><html lang='it'><meta charset='utf-8'><body>" + html + "</body></html>",
        encoding="utf-8",
    )
    return html_path
