# `Scripts/calculator_service/`

## Scopo

Carica i CSV idroelettrici da disco o FTP, li converte in uno schema comune per ANSIA e L’Occhio e calcola gli indicatori giornalieri. È l’unico punto del progetto che interpreta i layout dei CSV idroelettrici.

## Moduli e interfacce

- `data_sources.py`
  - `PLANTS`: registro dei cinque impianti ANSIA con chiave, file remoto/locale, layout, unità di origine, portata di progetto e potenza massima.
  - `fetch_hydro_data(plant, settings) -> HydroSeries`: acquisisce e normalizza i dati del giorno locale corrente.
  - I helper privati scaricano, leggono, convertono e filtrano i CSV. `timeseries` usa `t/P/Q/Bar`, `plc` usa i nomi dei segnali PLC e `long` trasforma righe `VarName/TimeString/VarValue` in colonne.
- `metrics.py`
  - `calculate_hydro_metrics(series, plant) -> HydroMetrics`: deduplica i timestamp, scarta misure incomplete/non finite e integra potenza e portata con il metodo dei trapezi.
  - Il kernel `_integrate_hydro` è compilato con `numba.njit(cache=True)`. Lavora su array NumPy contigui estratti dalla tabella Polars; il parsing, la validazione e la costruzione del risultato restano in Python.

Il livello runtime che richiama questi metodi è `Services/calculation.py`; il report usa il fetcher attraverso `Services/mail_server.py`, mentre la dashboard lo riutilizza nel provider.

## Schema normalizzato

`HydroSeries.samples` contiene un DataFrame Polars ordinato con colonne:

| Colonna | Tipo/Unità | Significato |
| --- | --- | --- |
| `timestamp` | datetime con timezone | ora locale del campione |
| `power_kw` | kW | potenza attiva |
| `flow_m3_s` | m³/s | portata, convertita da l/s quando richiesto dal registro |
| `pressure_bar` | bar | pressione usata per ricavare il salto |

I valori CSV possono avere virgola decimale. Timestamp ambigui/non esistenti sono gestiti durante la localizzazione al fuso configurato. Il filtro mantiene solo la data locale odierna; se non restano campioni viene restituito un errore esplicito.

## Metriche

- Energia: integrazione trapezoidale della potenza nel tempo, convertendo i secondi in ore.
- Volume: integrazione trapezoidale della portata nel tempo.
- Salto: pressione in bar moltiplicata per il fattore di conversione configurato nel calcolo.
- Rendimento attuale e giornaliero: rapporto tra energia/potenza e potenza idraulica derivata da salto e portata/volume.
- Portata rispetto al progetto: volume giornaliero diviso per la portata di progetto su 24 ore.

Con un solo campione energia e volume integrati sono zero. La compilazione JIT avviene al primo calcolo e viene memorizzata nella cache locale, per ridurre l’overhead nelle esecuzioni successive. I risultati dipendono da campionamento, completezza dei segnali, unità configurate e correttezza degli orari; non interpolare implicitamente dati mancanti durante un porting senza aver definito prima una regola equivalente.

## Configurazione e manutenzione

`DATA_SOURCE=local` legge `DATA_DIR/<remote_file>`; `DATA_SOURCE=ftp` usa le credenziali FTP in `Settings` e l’eventuale `FTP_REMOTE_ROOT`. Il contenuto FTP viene anche salvato nel percorso locale corrispondente. Per aggiungere un layout, introdurre una mappatura esplicita nel registro e nel normalizzatore, e mantenere invariato lo schema normalizzato a valle.
