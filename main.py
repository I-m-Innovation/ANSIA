"""Command-line entry point for the ANSIA report service."""

import argparse
import logging

def main():
    parser = argparse.ArgumentParser(description="ANSIA reporting and L'Occhio monitoring")
    parser.add_argument(
        "--once",
        action="store_true",
        help="generate one report and exit (default: run the configured scheduler)",
    )
    parser.add_argument("--gui", action="store_true", help="open the L'Occhio Tkinter dashboard")
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s")
    if args.gui:
        # Import differito: il percorso CLI non carica Tkinter/Matplotlib finché non serve la GUI.
        from Services.gui import gui

        gui().run()
    elif args.once:
        # L'esecuzione singola produce una preview locale salvo abilitazione esplicita di SMTP.
        from Services.mail_server import mail_server

        service = mail_server()
        print(service.run_once())
    else:
        from Services.mail_server import mail_server

        mail_server().serve()


if __name__ == "__main__":
    main()
