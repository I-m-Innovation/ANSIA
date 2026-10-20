# `Scripts/dashboard_service/`

## Scopo

Fornisce a L’Occhio il registro degli impianti, l’accesso alle sorgenti remote, il modello grafico, lo stato operativo e le funzioni di disegno. La GUI in `Services/gui.py` orchestra le opzioni e mostra i risultati, ma non contiene le regole di acquisizione o rendering.

## Moduli

- `plant_registry.py`: `PLANTS` definisce ordine e configurazione dei nove elementi della selezione; `PLANTS_BY_NAME` consente la risoluzione della scelta della GUI. I tipi supportati sono `hydro`, `combined`, `pv`, `scn` e `hsi`.
- `models.py`: `DashboardPlant` descrive identità, tipo e parametri nominali; `DashboardData` associa l’impianto a `streams` e `units`.
- `provider.py`: `fetch_dashboard_data(plant, settings, scn_sections)` carica una vista. I dati idroelettrici riusano `calculator_service`; le altre sorgenti interrogano Higeco o HSI. Il provider trasforma i payload API in tabelle Polars con timestamp e colonne di misura.
- `status.py`: `calculate_dashboard_status(data, now)` determina colore, messaggio, ultimo campione e indicatore di efficienza/PR. La soglia di freschezza attualmente applicata è 20 minuti.
- `chart.py`: `render_dashboard_chart(axes, data, show_mean)` disegna i flussi, le unità, gli assi secondari e le opzioni specifiche dell’impianto. È riutilizzabile con un asse Matplotlib fornito dal chiamante.

## Struttura dei dati

`DashboardData.samples` è un unico DataFrame Polars: `timestamp` contiene l’asse temporale condiviso e ogni altra colonna è un flusso (ad esempio `Potenza`, `Portata`, `Irraggiamento`). La mappa `units` associa i nomi dei flussi alle unità. Per le sorgenti API i timestamp Unix sono convertiti in UTC e poi al fuso configurato; duplicati temporali conservano l’ultimo valore ricevuto.

- Idroelettrico: potenza kW, portata m³/s e pressione bar.
- Condotta combinata: energia oraria kWh di San Teodoro e Partitore; la frazione dell’ora corrente è ridotta in base al tempo trascorso.
- Fotovoltaico/SCN: potenza kW e irraggiamento W/m²; la selezione SCN limita le serie di potenza mostrate.
- HSI: quattro canali di potenza in kW (prelevata, prodotta, immessa, autoconsumo).

## Flusso e accesso alle API

La GUI seleziona un `DashboardPlant`; il provider individua l’adattatore dal suo `kind` e restituisce `DashboardData`; il metodo runtime `Services/calculation.py` calcola lo stato; `chart.py` converte le colonne necessarie in array per Matplotlib. Le chiamate HTTP usano timeout configurato e sessioni chiuse in un blocco `finally`. Le credenziali sono lette da `Settings` e non devono essere inserite nel registro o nei log.

Gli ID di impianto/dispositivo/log/variabile e i parametri richiesti sono specifici dell’istanza remota e sono cablati in `provider.py`. Prima di modificare gli endpoint, verificare l’unità e il significato dei dati restituiti, perché i grafici e gli indicatori si basano su tali convenzioni.

## Regole di stato e visualizzazione

Il calcolo considera il timestamp più recente tra i flussi. Nessun dato produce stato grigio; un dato più vecchio di 20 minuti produce stato ambra; alcune condizioni di produzione nulla impostano rosso. Per impianti idroelettrici il rendimento corrente è stimato da potenza, pressione e portata; per PV/SCN viene mostrato un PR usando potenza, irraggiamento e potenza nominale. Sono indicatori di monitoraggio basati sugli ultimi campioni, non una valutazione storica.

I grafici idroelettrici usano asse sinistro per potenza e asse destro per portata; PV/SCN usano asse destro per irraggiamento; la condotta combinata usa barre sovrapposte per energia oraria. Il renderer rimuove l’asse secondario del disegno precedente prima di ridisegnare lo stesso asse.
