# ANSIA Python

Port Python della pipeline **ANSIA** in `ANSIA Matlab/Ansia/Script`: acquisisce i cinque impianti attivi, calcola le metriche idroelettriche e genera il report HTML con grafici inline. La dashboard L’Occhio e le pipeline PV commentate nel sorgente MATLAB non fanno parte di questa implementazione.

## Configurazione

1. Installa le dipendenze da `requirements.txt`.
2. Compila `.env` (è escluso da Git; `.env.example` è il modello).
3. Per l’uso locale, colloca i CSV sotto `DATA_DIR` mantenendo il percorso relativo `dati/...` riportato nelle specifiche in `Scripts/data_sources.py`.
4. Per l’acquisizione FTP imposta `DATA_SOURCE=ftp`, host, utente, password ed eventuale `FTP_REMOTE_ROOT`.
5. L’invio email è disattivato finché `SMTP_ENABLED=false`. Per abilitarlo configura host, mittente, destinatari e credenziali SMTP.

## Avvio

Da questa cartella:

```powershell
python main.py --once
```

Genera un singolo report. Con SMTP disattivato salva un’anteprima in `output/ansia-report.html`. Per il ciclo pianificato configurato in `.env`:

```powershell
python main.py
```

Il servizio applica la finestra oraria e l’intervallo configurati; ciascun impianto fallito compare nel report come **NO LINK** e non blocca gli altri.

## Struttura

- `Services/mail_server.py`: coordinamento runtime, gestione errori per impianto e scheduler.
- `Services/calculation.py`: punto d’ingresso runtime per i calcoli.
- `Scripts/`: configurazione `.env`, modelli normalizzati, fetch/parsing CSV, metriche, rendering HTML/grafici e invio SMTP.
