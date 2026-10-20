"""Matplotlib rendering helpers for the Polars-backed Tkinter dashboard."""

import matplotlib.dates as mdates
import numpy as np
import polars as pl


def _stream(samples, name):
    return (
        samples.select("timestamp", name)
        .filter(pl.col(name).is_not_null() & pl.col(name).is_finite())
        .sort("timestamp")
    )


def _plot_power(axes, samples, names, show_mean, linewidth=1.5):
    for name in names:
        stream = _stream(samples, name)
        if stream.is_empty():
            continue
        timestamps = stream.get_column("timestamp").to_list()
        values = stream.get_column(name).to_numpy()
        axes.fill_between(timestamps, values, alpha=0.22)
        axes.plot(timestamps, values, linewidth=linewidth, label=f"{name} [kW]")
        if show_mean and len(values):
            axes.axhline(float(np.mean(values)), color="#555555", linestyle="-", linewidth=1.7, label=f"{name} media")


def render_dashboard_chart(axes, data, show_mean=False):
    secondary = getattr(axes, "_occhio_secondary_axis", None)
    if secondary is not None:
        secondary.remove()
        axes._occhio_secondary_axis = None
    axes.clear()
    axes.set_title(data.plant.name)
    axes.set_xlabel("Ora")
    axes.grid(True, alpha=0.25)

    names = [name for name in data.samples.columns if name != "timestamp"]
    if data.plant.kind == "combined":
        timestamps = data.samples.get_column("timestamp").to_list()
        bottom = np.zeros(len(timestamps), dtype=np.float64)
        for name in names:
            values = data.samples.get_column(name).fill_null(0).fill_nan(0).to_numpy()
            axes.bar(timestamps, values, bottom=bottom, width=0.035, alpha=0.78, label=name)
            bottom += values
        axes.set_ylabel("Energia prodotta [kWh]")
        if names:
            axes.legend(loc="best", fontsize=8)
    elif data.plant.kind == "hydro":
        power_names = [name for name in names if name not in {"Portata", "Pressione"}]
        _plot_power(axes, data.samples, power_names, show_mean)
        axes.set_ylabel("Potenza [kW]")
        if "Portata" in names:
            flow = _stream(data.samples, "Portata")
            if not flow.is_empty():
                right = axes.twinx()
                axes._occhio_secondary_axis = right
                timestamps = flow.get_column("timestamp").to_list()
                values = flow.get_column("Portata").to_numpy()
                right.plot(timestamps, values, color="#2788b5", linewidth=1.4, label="Portata [m³/s]")
                right.set_ylabel("Portata [m³/s]")
                if show_mean:
                    right.axhline(float(np.mean(values)), color="#2788b5", linewidth=1.7, label="Portata media")
                if data.plant.design_flow_m3_s is not None:
                    right.axhline(data.plant.design_flow_m3_s, color="#2da44e", linewidth=1.7, label="Portata di riferimento")
                handles, labels = axes.get_legend_handles_labels()
                right_handles, right_labels = right.get_legend_handles_labels()
                axes.legend(handles + right_handles, labels + right_labels, loc="best", fontsize=8)
        elif power_names:
            axes.legend(loc="best", fontsize=8)
    elif data.plant.kind in {"pv", "scn"}:
        irradiation_name = "Irraggiamento"
        power_names = [name for name in names if name != irradiation_name]
        _plot_power(axes, data.samples, power_names, False, linewidth=1.7)
        axes.set_ylabel("Potenza [kW]")
        if irradiation_name in names:
            irradiation = _stream(data.samples, irradiation_name)
            if not irradiation.is_empty():
                right = axes.twinx()
                axes._occhio_secondary_axis = right
                right.plot(
                    irradiation.get_column("timestamp").to_list(),
                    irradiation.get_column(irradiation_name).to_numpy(),
                    color="#d97706",
                    linewidth=1.3,
                    label="Irraggiamento [W/m²]",
                )
                right.set_ylabel("Irraggiamento [W/m²]")
                h1, l1 = axes.get_legend_handles_labels()
                h2, l2 = right.get_legend_handles_labels()
                axes.legend(h1 + h2, l1 + l2, loc="best", fontsize=8)
        elif power_names:
            axes.legend(loc="best", fontsize=8)
    else:
        _plot_power(axes, data.samples, names, False)
        axes.set_ylabel("Potenza [kW]")
        if names:
            axes.legend(loc="best", fontsize=8)

    non_empty = next((name for name in names if not _stream(data.samples, name).is_empty()), None)
    if non_empty is not None:
        stamp = _stream(data.samples, non_empty).get_column("timestamp")[0]
        axes.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M", tz=stamp.tzinfo))
    axes.figure.autofmt_xdate()
