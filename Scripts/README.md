# Documentazione di `Scripts/`

Questa directory raccoglie moduli di supporto importati dai servizi runtime in `Services/`. Polars fornisce le tabelle colonnari per CSV, serie temporali e dashboard; Numba compila il kernel numerico delle metriche idroelettriche. La distinzione mantiene brevi i punti d’ingresso e separa acquisizione, regole di calcolo e presentazione.

## Moduli comuni

- `config.py`: individua la root dell’applicazione, carica `.env` e costruisce `Settings` con credenziali, sorgenti, orari, timeout e percorsi. `load_settings()` è il punto da usare per ottenere la configurazione; i percorsi relativi sono risolti rispetto alla root del progetto.
- `models.py`: definisce i record condivisi `Plant`, `HydroSeries` e `HydroMetrics`. `HydroSeries.samples` è un DataFrame Polars nello schema idroelettrico normalizzato descritto nel README principale.
- `__init__.py`: identifica il package. Gli import nel progetto sono assoluti, per esempio `from Scripts.models import HydroSeries`.

## Aree funzionali

- [`calculator_service/`](calculator_service/README.md): file CSV, normalizzazione idroelettrica e metriche.
- [`dashboard_service/`](dashboard_service/README.md): registro e provider dati per L’Occhio, indicatori di stato e grafici.
- [`mail_service/`](mail_service/README.md): composizione del report ANSIA, anteprime e consegna SMTP.

## Direzione delle dipendenze

`Services/` chiama i moduli di queste cartelle. `dashboard_service` riusa il downloader idroelettrico di `calculator_service`; `mail_service` riceve dati e metriche già calcolati e non acquisisce i CSV. I modelli e la configurazione comuni restano al livello `Scripts/` per evitare schemi duplicati.

## Indicazioni per estensioni e porting

Conservare i contratti tra moduli: convertire una nuova sorgente allo schema normalizzato prima di calcolare o disegnare; mantenere le unità esplicite; tenere credenziali e parametri esterni nella configurazione; isolare la presentazione dalla logica numerica. Per aggiungere un impianto idroelettrico aggiornare il registro `PLANTS` e fornire il relativo layout CSV, verificando che sia compatibile con `_normalize()`.
