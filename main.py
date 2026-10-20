"""Command-line entry point for the ANSIA report service."""

import argparse
import logging

from Services.mail_server import mail_server


def main():
    parser = argparse.ArgumentParser(description="ANSIA daily plant report service")
    parser.add_argument(
        "--once",
        action="store_true",
        help="generate one report and exit (default: run the configured scheduler)",
    )
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s")
    service = mail_server()
    if args.once:
        print(service.run_once())
    else:
        service.serve()


if __name__ == "__main__":
    main()
