# `Scripts/mail_service/`

## Scopo

Contiene la presentazione e la consegna del report ANSIA. Non scarica dati e non calcola le metriche: riceve oggetti normalizzati dal flusso orchestrato in `Services/mail_server.py`.

## Moduli e interfacce

- `reports.py`
  - `build_daily_report(plant, series, metrics, unavailable=False)` restituisce una sezione HTML e, se i dati sono disponibili, una tupla immagine `(cid, filename, bytes)`.
  - Il grafico è reso PNG in memoria con Matplotlib in modalità `Agg`, adatta a esecuzione senza display grafico.
  - `save_preview(html, images, output_dir)` salva HTML e immagini in locale, sostituendo i riferimenti `cid:` con i nomi dei file.
- `smtp_delivery.py`
  - `send_html_report(html, images, settings)` costruisce un messaggio alternativo testo/HTML, incorpora i PNG con Content-ID e lo invia usando SMTP o SMTP SSL secondo `Settings`.

## Contenuto del report

Per ogni impianto, il report include ultimo orario, portata e potenza correnti, rendimento, volume ed energia giornalieri, rendimento giornaliero, confronto della portata con il valore di progetto e numero di campioni. Se l’acquisizione o il calcolo fallisce, l’orchestratore aggiunge una sezione `NO LINK` per quell’impianto e continua con gli altri.

I valori sono formattati con separatori italiani e le stringhe mostrate in HTML sono escaped. Le immagini usano ID `ansia-<chiave>` e sono collegate al messaggio tramite `cid:` quando inviato per email.

## Modalità di consegna

`Services/mail_server.py` decide la modalità: con `SMTP_ENABLED=true` chiama il trasporto SMTP; altrimenti salva un’anteprima in `REPORT_OUTPUT_DIR` (predefinito `output/`). L’invio richiede host, mittente e destinatari; autenticazione e STARTTLS/SSL sono opzionali secondo configurazione. Non aggiungere password ai messaggi di errore o ai log.

## Estensioni

Per modificare layout o indicatori, aggiornare `build_daily_report` mantenendo il contratto della tupla immagine, in modo che sia anteprima e invio inline continuino a funzionare. Per cambiare trasporto o gestione dei destinatari intervenire nel modulo SMTP/configurazione senza aggiungere acquisizione dati alla presentazione.
