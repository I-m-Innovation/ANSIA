"""SMTP delivery of an HTML report with inline plots."""

from email.message import EmailMessage
import smtplib


def send_html_report(html, images, settings):
    if not settings.smtp_host or not settings.smtp_from or not settings.smtp_to:
        raise ValueError("SMTP_HOST, SMTP_FROM and SMTP_TO are required when SMTP_ENABLED=true")
    if settings.smtp_username and not settings.smtp_password:
        raise ValueError("SMTP_PASSWORD is required when SMTP_USERNAME is set")

    message = EmailMessage()
    message["Subject"] = settings.subject
    message["From"] = settings.smtp_from
    message["To"] = ", ".join(settings.smtp_to)
    message.set_content("Il report giornaliero degli impianti è disponibile in formato HTML.")
    message.add_alternative(html, subtype="html")
    html_part = message.get_body(preferencelist=("html",))
    for cid, filename, payload in images:
        html_part.add_related(
            payload,
            maintype="image",
            subtype="png",
            cid=f"<{cid}>",
            filename=filename,
            disposition="inline",
        )

    smtp_class = smtplib.SMTP_SSL if settings.smtp_use_ssl else smtplib.SMTP
    with smtp_class(settings.smtp_host, settings.smtp_port, timeout=30) as client:
        if not settings.smtp_use_ssl and settings.smtp_use_starttls:
            client.starttls()
        if settings.smtp_username:
            client.login(settings.smtp_username, settings.smtp_password)
        client.send_message(message)
