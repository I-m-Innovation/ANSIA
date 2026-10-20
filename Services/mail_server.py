"""ANSIA report runtime: collect, calculate, render and deliver reports."""

import logging
import time
from datetime import datetime

from Scripts.config import load_settings
from Scripts.calculator_service.data_sources import PLANTS, fetch_hydro_data
from Scripts.mail_service.reports import build_daily_report, save_preview
from Scripts.mail_service.smtp_delivery import send_html_report
from Services.calculation import calculation


class mail_server:
    """Run ANSIA once or on a configured interval."""

    def __init__(self):
        self.settings = load_settings()
        self.calculation = calculation()
        self.logger = logging.getLogger("ansia")

    def run_once(self):
        """Build today's report; send only when SMTP is explicitly enabled."""
        sections = []
        inline_images = []

        for plant in PLANTS:
            try:
                # Un errore su un impianto genera una sezione NO LINK, senza interrompere il report completo.
                series = fetch_hydro_data(plant, self.settings)
                metrics = self.calculation.calculate_daily_metrics(series, plant)
                section, image = build_daily_report(plant, series, metrics)
                sections.append(section)
                if image:
                    inline_images.append(image)
            except Exception:
                self.logger.exception("Report generation failed for %s", plant.name)
                sections.append(build_daily_report(plant, None, None, unavailable=True)[0])

        html = "<h1 style='text-align:center'>Report giornaliero impianti</h1>" + "<hr>".join(sections)
        # SMTP è una scelta esplicita; in modalità predefinita il report resta consultabile in locale.
        if self.settings.smtp_enabled:
            send_html_report(html, inline_images, self.settings)
            self.logger.info("ANSIA report email sent")
            return "sent"

        destination = save_preview(html, inline_images, self.settings.output_dir)
        self.logger.info("SMTP disabled; preview saved to %s", destination)
        return str(destination)

    def serve(self):
        """Run at a fixed interval, respecting the configured local send window."""
        self.logger.info("ANSIA scheduler started (interval=%s minutes)", self.settings.interval_minutes)
        while True:
            now = datetime.now(self.settings.timezone)
            if self.settings.start_time <= now.time() <= self.settings.end_time:
                try:
                    self.run_once()
                except Exception:
                    self.logger.exception("ANSIA run failed")
            else:
                self.logger.info("Outside reporting window")
            time.sleep(self.settings.interval_minutes * 60)
