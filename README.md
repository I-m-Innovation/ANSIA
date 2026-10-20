# ANSIA Python

Applicazione Python che riunisce due strumenti per il monitoraggio degli impianti:

- **ANSIA** produce il report idroelettrico giornaliero in HTML, con grafici e indicatori, e può inviarlo per email.
- **L’Occhio** è una dashboard desktop Tkinter per consultare serie temporali, stato della comunicazione ed efficienza/PR.

I due percorsi condividono configurazione e acquisizione dei dati idroelettrici. I dati tabellari sono gestiti con Polars; il nucleo numerico dell’integrazione idroelettrica usa Numba per la compilazione JIT con cache. Le classi in `Services/` espongono i punti d’ingresso usati a runtime; i moduli di supporto e presentazione sono raccolti in `Scripts/`.

## Requisiti e avvio

Usare Python compatibile con `zoneinfo` (Python 3.9 o successivo) e installare le dipendenze elencate in `requirements.txt`:

```powershell
python -m pip install -r requirements.txt
```

Creare `.env` copiando `.env.example`, quindi avviare dalla directory del progetto:

```powershell
python main.py --gui    # apre L’Occhio
python main.py --once   # crea un report ANSIA e termina
python main.py          # esegue lo scheduler ANSIA
```

Con `SMTP_ENABLED=false` il report singolo viene salvato in `output/ansia-report.html`, con i grafici PNG accanto. L’invio email richiede `SMTP_ENABLED=true` e i relativi parametri SMTP. Lo scheduler controlla l’intervallo configurato e genera il report solo nella finestra `REPORT_START_TIME`–`REPORT_END_TIME`.

## Configurazione e dati

`Scripts/config.py` carica `.env` e restituisce una configurazione immutabile. Le variabili sono descritte in `.env.example`; credenziali FTP, Higeco/HSI e SMTP vanno inserite solo nel file locale `.env`, che è escluso dal controllo versione.

- `DATA_SOURCE=local`: cerca i CSV sotto `DATA_DIR`, rispettando le sottocartelle `dati/...` indicate nel registro.
- `DATA_SOURCE=ftp`: scarica i file dal server configurato. `FTP_REMOTE_ROOT` è facoltativo e precede il percorso del file.
- Rubino e SCN usano le credenziali Higeco; la sorgente HSI usa le credenziali HSI.
- Gli endpoint di monitoraggio leggono i dati dalla mezzanotte locale all’ora corrente. Le serie idroelettriche sono filtrate al giorno locale corrente.

Non includere `.env` o credenziali nei log, negli screenshot o negli artefatti condivisi. Per lavorare senza servizi esterni, usare dati CSV locali e lasciare SMTP disattivato.

## Architettura e flussi

```text
main.py
├── --gui  → Services/gui.py → Scripts/dashboard_service + Services/calculation.py
├── --once → Services/mail_server.py → Scripts/calculator_service
│                                  → Services/calculation.py
│                                  → Scripts/mail_service
└── default → scheduler ANSIA (stesso flusso del report singolo)
```

- `Services/gui.py` costruisce la finestra, raccoglie le opzioni e delega lettura e disegno ai moduli specializzati. Il recupero dati avviene in un thread di lavoro; l’aggiornamento dei widget torna al thread Tk tramite una coda.
- `Services/calculation.py` è il punto runtime condiviso per le metriche idroelettriche e lo stato/efficienza della dashboard.
- `Services/mail_server.py` coordina acquisizione, calcolo, creazione delle sezioni HTML e consegna o salvataggio locale.
- `Scripts/` contiene configurazione, modelli normalizzati e i moduli di acquisizione/calcolo/presentazione. Dettagli: [documentazione di Scripts](Scripts/README.md).

## Convenzioni dei dati

Le sorgenti idroelettriche vengono convertite in un DataFrame Polars con schema comune: `timestamp` con fuso orario applicativo, `power_kw` in kW, `flow_m3_s` in m³/s e `pressure_bar` in bar. I layout CSV supportati sono `timeseries`, `plc` e `long`; il registro e le colonne attese sono definiti in `Scripts/calculator_service/data_sources.py`.

L’integrazione trapezoidale usa coppie di campioni consecutivi: potenza → kWh e portata → m³. Il tempo tra i campioni è quindi significativo; campioni mancanti o non numerici vengono esclusi dai calcoli. Il grafico dashboard riceve un `DashboardData` con una colonna `timestamp`, una colonna per ogni flusso e una mappa delle unità. Numba compila il loop numerico; la prima chiamata può includere il tempo di compilazione, mentre la cache riduce il costo nelle esecuzioni successive.

## Cartelle principali

- `Services/`: entry point runtime per email, calcolo e GUI.
- `Scripts/calculator_service/`: acquisizione CSV/FTP, normalizzazione e metriche idroelettriche.
- `Scripts/dashboard_service/`: registro impianti, adattatori API, stato e grafici di L’Occhio.
- `Scripts/mail_service/`: report HTML, anteprima locale e invio SMTP con immagini inline.
- `output/`: destinazione predefinita delle anteprime locali.

## Limiti operativi da considerare

- Il progetto presume file CSV coerenti con i layout configurati e dati espressi nelle unità dichiarate dal registro.
- Gli ID impianto, dispositivo, log e variabile delle API sono configurati nel provider dashboard; vanno verificati con l’istanza effettiva del servizio.
- I grafici e l’interfaccia richiedono un ambiente desktop con Tk disponibile; l’invio SMTP e le sorgenti remote richiedono rete e credenziali valide.
- Non è prevista persistenza storica applicativa: le viste sono costruite sui dati disponibili per il giorno corrente.
