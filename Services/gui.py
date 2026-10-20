"""Tkinter desktop dashboard for the L'Occhio plant monitor."""

from datetime import datetime
import logging
import queue
import threading
import tkinter as tk
from tkinter import ttk

from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2Tk
from matplotlib.figure import Figure

from Scripts.config import load_settings
from Scripts.dashboard_service.chart import render_dashboard_chart
from Scripts.dashboard_service.plant_registry import PLANTS, PLANTS_BY_NAME
from Scripts.dashboard_service.provider import fetch_dashboard_data
from Services.calculation import calculation


class gui:
    """Configure and display one live plant chart with optional refresh timer."""

    def __init__(self, root=None):
        self.settings = load_settings()
        self.calculation = calculation()
        self.logger = logging.getLogger("ansia.gui")
        self.root = root or tk.Tk()
        self.root.title("L'Occhio | Monitoraggio impianti")
        self.root.geometry("1180x760")
        self.root.minsize(820, 560)
        self.root.protocol("WM_DELETE_WINDOW", self.close)
        self.results = queue.Queue()
        # Solo il thread Tk aggiorna i widget; il worker comunica i risultati tramite questa coda.
        self.busy = False
        self.refresh_job = None
        self.current_data = None
        self.plant_name = tk.StringVar(value="Ponte Giurino")
        self.auto_refresh = tk.BooleanVar(value=False)
        self.period_minutes = tk.StringVar(value=str(self.settings.interval_minutes))
        self.show_mean = tk.BooleanVar(value=False)
        self.section_one = tk.BooleanVar(value=True)
        self.section_two = tk.BooleanVar(value=True)
        self.status_text = tk.StringVar(value="In attesa di aggiornamento")
        self.efficiency_text = tk.StringVar(value="")
        self.last_update_text = tk.StringVar(value="Ultimo aggiornamento: —")
        self._build_window()
        self.root.after(150, self._poll_results)

    def _build_window(self):
        style = ttk.Style(self.root)
        if "clam" in style.theme_names():
            style.theme_use("clam")
        style.configure("Panel.TFrame", background="#f6f8fa")
        style.configure("Title.TLabel", background="#f6f8fa", font=("Segoe UI", 18, "bold"))
        style.configure("Muted.TLabel", background="#f6f8fa", foreground="#57606a")
        style.configure("Metric.TLabel", background="#f6f8fa", font=("Segoe UI", 12, "bold"))
        self.root.columnconfigure(1, weight=1)
        self.root.rowconfigure(0, weight=1)

        panel = ttk.Frame(self.root, padding=(18, 18), style="Panel.TFrame")
        panel.grid(row=0, column=0, sticky="nsw")
        chart_panel = ttk.Frame(self.root, padding=(8, 16, 18, 12))
        chart_panel.grid(row=0, column=1, sticky="nsew")
        chart_panel.rowconfigure(0, weight=1)
        chart_panel.columnconfigure(0, weight=1)

        ttk.Label(panel, text="L'OCCHIO", style="Title.TLabel").grid(row=0, column=0, sticky="w", pady=(0, 4))
        ttk.Label(panel, text="Monitoraggio impianti", style="Muted.TLabel").grid(row=1, column=0, sticky="w", pady=(0, 22))
        ttk.Label(panel, text="Impianto").grid(row=2, column=0, sticky="w")
        plants = ttk.Combobox(
            panel,
            textvariable=self.plant_name,
            values=[plant.name for plant in PLANTS],
            state="readonly",
            width=27,
        )
        plants.grid(row=3, column=0, sticky="ew", pady=(5, 13))
        plants.bind("<<ComboboxSelected>>", lambda _event: self.refresh())

        ttk.Label(panel, text="Aggiornamento automatico").grid(row=4, column=0, sticky="w")
        ttk.Checkbutton(
            panel,
            text="Attiva aggiornamento",
            variable=self.auto_refresh,
            command=self._toggle_auto_refresh,
        ).grid(row=5, column=0, sticky="w", pady=(4, 7))
        period_row = ttk.Frame(panel)
        period_row.grid(row=6, column=0, sticky="w", pady=(0, 13))
        ttk.Label(period_row, text="Ogni").pack(side="left")
        ttk.Spinbox(period_row, from_=1, to=1440, width=6, textvariable=self.period_minutes).pack(side="left", padx=6)
        ttk.Label(period_row, text="minuti").pack(side="left")

        ttk.Separator(panel).grid(row=7, column=0, sticky="ew", pady=10)
        ttk.Label(panel, text="Opzioni grafico").grid(row=8, column=0, sticky="w", pady=(2, 4))
        ttk.Checkbutton(panel, text="Mostra media del periodo", variable=self.show_mean, command=self._redraw).grid(
            row=9, column=0, sticky="w", pady=3
        )
        ttk.Label(panel, text="SCN - Pilota").grid(row=10, column=0, sticky="w", pady=(10, 2))
        ttk.Checkbutton(panel, text="Sezione 1", variable=self.section_one, command=self._scn_options_changed).grid(
            row=11, column=0, sticky="w", pady=2
        )
        ttk.Checkbutton(panel, text="Sezione 2", variable=self.section_two, command=self._scn_options_changed).grid(
            row=12, column=0, sticky="w", pady=2
        )

        ttk.Separator(panel).grid(row=13, column=0, sticky="ew", pady=13)
        self.status_canvas = tk.Canvas(panel, width=20, height=20, highlightthickness=0, bg="#f6f8fa")
        self.status_canvas.grid(row=14, column=0, sticky="w")
        self.status_lamp = self.status_canvas.create_oval(3, 3, 17, 17, fill="#8c959f", outline="")
        ttk.Label(panel, textvariable=self.status_text, wraplength=220).grid(row=14, column=0, sticky="w", padx=(28, 0))
        ttk.Label(panel, textvariable=self.efficiency_text, style="Metric.TLabel").grid(row=15, column=0, sticky="w", pady=(11, 2))
        ttk.Label(panel, textvariable=self.last_update_text, style="Muted.TLabel", wraplength=230).grid(
            row=16, column=0, sticky="w", pady=(2, 14)
        )
        self.refresh_button = ttk.Button(panel, text="Aggiorna ora", command=self.refresh)
        self.refresh_button.grid(row=17, column=0, sticky="ew", pady=(0, 8))
        ttk.Label(
            panel,
            text=f"Fonte dati: {self.settings.data_source.upper()}",
            style="Muted.TLabel",
        ).grid(row=18, column=0, sticky="w", pady=(8, 0))

        self.figure = Figure(figsize=(9, 5.5), dpi=100, layout="constrained")
        self.axes = self.figure.add_subplot(111)
        self.axes.set_title("Seleziona un impianto e aggiorna")
        self.canvas = FigureCanvasTkAgg(self.figure, master=chart_panel)
        self.canvas.get_tk_widget().grid(row=0, column=0, sticky="nsew")
        toolbar_frame = ttk.Frame(chart_panel)
        toolbar_frame.grid(row=1, column=0, sticky="ew")
        self.toolbar = NavigationToolbar2Tk(self.canvas, toolbar_frame, pack_toolbar=False)
        self.toolbar.update()
        self.toolbar.pack(side="left", fill="x")

    def refresh(self):
        if self.busy:
            return
        plant = PLANTS_BY_NAME[self.plant_name.get()]
        sections = tuple(
            name
            for name, enabled in (("Sezione 1", self.section_one.get()), ("Sezione 2", self.section_two.get()))
            if enabled
        )
        self.busy = True
        self.refresh_button.configure(state="disabled")
        self.status_text.set(f"Lettura dati: {plant.name}…")
        # Le chiamate a file/API possono bloccare: eseguirle fuori dal loop grafico mantiene la UI reattiva.
        threading.Thread(
            target=self._fetch_in_background,
            args=(plant, sections),
            daemon=True,
        ).start()

    def _fetch_in_background(self, plant, sections):
        try:
            self.results.put((plant, fetch_dashboard_data(plant, self.settings, sections), None))
        except Exception as error:
            self.results.put((plant, None, str(error)))

    def _poll_results(self):
        # after() esegue il consumo della coda nel thread Tk, sicuro per gli aggiornamenti dei widget.
        try:
            while True:
                plant, data, error = self.results.get_nowait()
                self.busy = False
                self.refresh_button.configure(state="normal")
                if error:
                    self.logger.warning("Could not refresh %s: %s", plant.name, error)
                    self.current_data = None
                    self.status_canvas.itemconfigure(self.status_lamp, fill="#8c959f")
                    self.status_text.set("Nessun collegamento / errore di lettura")
                    self.efficiency_text.set("")
                    self.last_update_text.set(error)
                    secondary = getattr(self.axes, "_occhio_secondary_axis", None)
                    if secondary is not None:
                        secondary.remove()
                        self.axes._occhio_secondary_axis = None
                    self.axes.clear()
                    self.axes.set_title(plant.name)
                    self.axes.text(0.5, 0.5, error, ha="center", va="center", wrap=True, transform=self.axes.transAxes)
                    self.canvas.draw_idle()
                    continue

                self.current_data = data
                status = self.calculation.calculate_dashboard_status(data, datetime.now(self.settings.timezone))
                self.status_canvas.itemconfigure(self.status_lamp, fill={"green": "#238636", "red": "#cf222e", "amber": "#bf8700", "gray": "#8c959f"}[status.color])
                self.status_text.set(status.message)
                self.efficiency_text.set(status.efficiency)
                stamp = status.last_seen.strftime("%d/%m/%Y %H:%M:%S") if status.last_seen else "—"
                self.last_update_text.set(f"Ultimo aggiornamento: {stamp}")
                self._redraw()
        except queue.Empty:
            pass
        self.root.after(150, self._poll_results)

    def _redraw(self):
        if self.current_data is None:
            return
        render_dashboard_chart(self.axes, self.current_data, self.show_mean.get())
        self.canvas.draw_idle()

    def _scn_options_changed(self):
        if PLANTS_BY_NAME[self.plant_name.get()].kind == "scn":
            self.refresh()
        else:
            self._redraw()

    def _toggle_auto_refresh(self):
        if self.refresh_job is not None:
            self.root.after_cancel(self.refresh_job)
            self.refresh_job = None
        if self.auto_refresh.get():
            self.refresh()
            self._schedule_refresh()

    def _schedule_refresh(self):
        if not self.auto_refresh.get():
            return
        try:
            interval = max(1, int(self.period_minutes.get()))
        except ValueError:
            interval = self.settings.interval_minutes
            self.period_minutes.set(str(interval))
        self.refresh_job = self.root.after(interval * 60_000, self._refresh_and_reschedule)

    def _refresh_and_reschedule(self):
        self.refresh_job = None
        self.refresh()
        self._schedule_refresh()

    def close(self):
        if self.refresh_job is not None:
            self.root.after_cancel(self.refresh_job)
        self.root.destroy()

    def run(self):
        self.root.mainloop()
