ANNOTAZIONI MATERIALE TESI:
Qui sotto elencherò le caratteristiche di quello che si trova all’interno delle varie cartelle in maniera tale che sia agevole andare a trovare quello che si cerca analizzando il materiale elaborato.

1) EXPERIMENT: questa cartella contiene tutti i riferimenti per quanto riguarda l’esperimento con eye tracker che abbiamo effettuato sulle 30 immagini create da noi. Al suo interno ha tre cartelle:

	1.1) DIREZIONE: questa cartella contiene le informazioni per quanto riguarda il controllo della distribuzione dei punti nelle immagini verticali e orizzontali. E' suddivisa in due sottocartelle:

		1.1.1) DIREZIONE_GLOBALE:  questa cartella contiene le cartelle per il controllo di ogni singola coppia di immagini. Ad esempio la cartella “0_9” contiene il confronto diretto tra l’immagine 0 e quella a lei legata che è 		la numero 9. In ognuna di queste è contenuta una cartella per ognuna delle due immagini della coppia. Ad esempio in “0_9” è contenuta sia la cartella “0” che la cartella “9”. Ognuna di queste contiene le seguenti 		informazioni:

			1.1.1.1) FILE_TEXT_400_graph: l’immagine è stata suddivisa in 400 rettangoli uguali numerati orizzontalmente e in questo file viene riportato in ogni rettangolo quanti punti di fissazione sono contenuti all’interno di essi;

			1.1.1.2) FILE_TEXT_900_graph: l’immagine è stata suddivisa in 900 rettangoli uguali numerati orizzontalmente e in questo file viene riportato in ogni rettangolo quanti punti di fissazione sono contenuti all’interno di essi;

			1.1.1.3) graph: l’immagine originale;

			1.1.1.4) IMAGE_HEAT_MAP_62_graph: questa è l’immagine originale usata nell’esperimento alla quale è stata sovrapposta la mappa di calore mettendo insieme i dati di tutti gli osservatori;

			1.1.1.5) RETTANGOLO_400_30_graph: immagine contenente solo i 400 rettangoli in cui l’immagine è stata suddivisa con all’interno scritto il numero di punti di fissazione (solo per quelli che ne hanno almeno 30);

			1.1.1.6) RETTANGOLO_400_40_graph: immagine contenente solo i 400 rettangoli in cui l’immagine è stata suddivisa con all’interno scritto il numero di punti di fissazione (solo per quelli che ne hanno almeno 40);

			1.1.1.7) RETTANGOLO_900_10_graph: immagine contenente solo i 900 rettangoli in cui l’immagine è stata suddivisa con all’interno scritto il numero di punti di fissazione (solo per quelli che ne hanno almeno 10);

			1.1.1.8) RETTANGOLO_900_20_graph: immagine contenente solo i 900 rettangoli in cui l’immagine è stata suddivisa con all’interno scritto il numero di punti di fissazione (solo per quelli che ne hanno almeno 20);

			1.1.1.9) RETTANGOLO_900_30_graph: immagine contenente solo i 900 rettangoli in cui l’immagine è stata suddivisa con all’interno scritto il numero di punti di fissazione (solo per quelli che ne hanno almeno 30).

		1.1.2) DIREZIONE_PREATTENTIVE: questa cartella contiene le stesse informazioni di quella precedente concentrata solo nel primo secondo di fissazione, cioè per ogni osservatore abbiamo conservato solo i punti relativi al primo secondo di fissazione. Nelle singole cartelle di ogni immagine, non c’è l’informazione sulla mappa di calore, ma è inserita in più l’immagine “RETTANGOLO_900_graph0” che contiene l’informazione sulla distribuzione dei punti di fissazione senza tenere conto di nessuna soglia con cui scrivere nei rettangoli.

	1.2) EYETRACKER: questa cartella contiene una cartella per ognuna delle immagini dell’esperimento con i risultati dell’esperimento con l’eyetracker. Nella cartella di ogni immagine sono 	contenute le seguenti informazioni:

		1.2.1) Combination_graph: è la combinazione tra quello che genera Itti modificato e l’analisi del testo sull’immagine in questione. Da questa viene poi generata la mappa di calore di Matzen;

		1.2.2) FIRST_IMAGE_FIXATIONS_62_graph: è l’immagine originale con sovrapposti i punti di fissazione solo della fase pre-attentive, quindi solo i primi 2,5 s;

		1.2.3) FIRST_IMAGE_HEAT_MAP_62_graph: è l’immagine originale con sovrapposta la mappa di calore solo della fase pre-attentive;

		1.2.4) graph: è l’immagine originale;

		1.2.5) IMAGE_FIXATIONS_62_graph: è l’immagine originale con sovrapposti tutti i punti di fissazione;

		1.2.6) IMAGE_HEAT_MAP_62_graph: è l’immagine originale con sovrapposta la mappa di calore generata da tutti i punti di fissazione;

		1.2.7) ITTI_graph: è quello che l’algoritmo di Itti modificato genera;

		1.2.8) ITTI_OR_graph: è quello che l’algoritmo di Itti originale genera;

		1.2.9) mySalience_graph: è l’immagine originale con sovrapposta la mappa di calore generata da Matzen;

		1.2.10) una cartella “oss” per ognuno dei 62 osservatori che sono stati sottoposti all’esperimento: in ognuna di queste cartelle è contenuto il file di testo “subject…” che contiene tuti i punti di fissazione per quel determinato osservatore su quell’immagine, mentre il file excel “Cartel1” è la conversione in formato di tabella del file di testo precedente in maniera tale che sia agile importarlo in Matlab;

		1.2.11) TextSaliency_graph: è quello che viene generato solo dall’analisi del testo;

		1.2.12) Descrizione_graph: è un file di testo che contiene elencate le caratteristiche presenti nell'immagine ed usate per generarla tramite python;

	1.3) ORIGINALI: questa cartella contiene tutte e 30 le immagini usate per l’esperimento così come sono state create originariamente, da “graph0” a “graph29”.

2) MASSVIS: questa cartella contiene tutte le informazioni riguardanti al dataset di MASSVIS. Al suo interno contiene quattro sottocartelle:

	2.1) ANALISI_SEMANTICA: questa cartella contiene tutte le informazioni per quanto riguarda l’analisi semantica, quindi poligoni sovrapposti all’immagine, effettuata su ognuna delle 110 immagini di MASSVIS. All’interno di questa cartella abbiamo una cartella per ognuna delle immagini e all’interno troviamo le seguenti informazioni:

		2.1.1) “immagine”: file di testo fornito da MASSVIS che contiene le delimitazioni dei poligoni i quali rappresentano delle specifiche porzioni sull’immagine (titolo, parte grafica ecc.);

		2.1.2) “immagine”.txt: file di testo prodotto da noi in cui per ogni poligono abbiamo inserito il numero di punti di fissazione che cadono al suo interno;

		2.1.3) EyeTracking_: immagine che contiene l’immagine originale alla quale viene sovrapposta la mappa di calore in base ai punti di fissazione;

		2.1.4) POLY_AND_POINTS_: Immagine con solo i poligoni disegnati su sfondo bianco e con i punti di fissazione che sono stati rappresentati all’interno del poligono opportuno;

		2.1.5) POLY_ON_IMG_: immagine con i poligoni sovrapposti all’immagine.

	2.2) EYETRACKING: questa cartella contiene le analisi che abbiamo effettuato su MASSVIS relative alla mappa di calore vera generata dai punti di fissazione e relative a ciò che l’algoritmo di Itti, Itti modificato e Matzen producono graficamente. In particolare abbiamo:

		2.2.1) Combination_: è la combinazione tra quello che genera Itti modificato e l’analisi del testo sull’immagine in questione. Da questa viene poi generata la mappa di calore di Matzen;

		2.2.1) eventuali cartelle “CROP” dei tagli compiuti sull’immagine: se presenti, all’interno di queste cartelle si trovano le stesse identiche informazioni di questo elenco letterale a cui si aggiungono “CROP_” che rappresenta l’immagine originale tagliata e invece “OR_” è l’immagine originale;

		2.2.1) EyeTracking_: è l’immagine originale con sovrapposta la mappa di calore generata da tutti i punti di fissazione raccolti dagli osservatori;

		2.2.2) Final_: è l’immagine originale con sovrapposta la mappa di calore generata da Matzen;

		2.2.3) ITTI_: è quello che l’algoritmo di Itti modificato genera;

		2.2.4) ITTI_OR_: è quello che l’algoritmo di Itti originale genera;

		2.2.5) TextSaliency_: è quello che viene generato solo dall’analisi del testo;

	2.3) ORIGINALI: questa cartella contiene le 110 immagini originali che abbiamo conservato dal dataset di MASSVIS.

	2.4) PREATTENTIVE: questa cartella fa riferimento alla mappa di calore dei punti di fissazione della cartella precedente “EYETRACKING” dove però sono stati utilizzati solo i punti presenti nella fase pre-atttentive. In particolare abbiamo:

		2.4.1) EyeTracking_: è l’immagine originale con sovrapposta la mappa di calore generata da tutti i punti di fissazione raccolti dagli osservatori;

		2.4.2) EyeTracking_MOD250_: è l’immagine originale con sovrapposta la mappa di calore generata dai punti di fissazione raccolti dagli osservatori solo nei primi 250 ms;

		2.4.3) EyeTracking_MOD500_: è l’immagine originale con sovrapposta la mappa di calore generata dai punti di fissazione raccolti dagli osservatori solo nei primi 500 ms;

		2.4.4) EyeTracking_MODNOFIRST250_: è l’immagine originale con sovrapposta la mappa di calore generata dai punti di fissazione raccolti dagli osservatori escludendo i primi 250 ms e prendendo i 250 ms successivi a quelli esclusi;
	

3) METRICHE: questo file excel contiene informazioni riguardo i risultati sul calcolo delle metriche sulle varie saliency prodotte dagli algoritmi con cui abbiamo lavorato (Itti, Itti modificato e Matzen). Nella prima parte vengono analizzate le 110 immagini del dataset di MASSVIS che abbiamo conservato e vengono inseriti i valori delle 8 metriche per ognuno dei 3 algoritmi. Di fianco viene calcolata la differenza tra gli algoritmi. Nella parte sottostante al calcolo delle differenze ci sono delle tabelle riassuntive che permettono di avere risultati più compatti su quale algoritmo performi meglio degli altri.
Al di sotto di questa prima parte abbiamo i risultati dell’analisi sul testo, in cui 11 immagini di MASSVIS sono state tagliate e private di alcune porzioni di testo (per alcune immagini sono stati effettuati anche più tagli). Dopo aver eseguito i tagli, sono stati calcolati nuovamente i valori delle 8 metriche sui 3 algoritmi come in precedenza con sempre delle tabelle riassuntive per valutare le performance a confronto.
Dopodiché sono contenuti i risultati dell’esperimento sulle nostre immagini. Per ognuna delle 30 immagini sono stati calcolati i valori delle 8 metriche, calcolate le differenze e messe a confronto in tabelle per confrontare le prestazioni. 
Al fondo sono presenti due tabelle: la prima descrive la distribuzione delle caratteristiche tra le nostre immagini usate nell’esperimento; la seconda tabella riassume la distribuzione delle caratteristiche nelle mappe di saliency dopo aver analizzato tutti i dati raccolti sugli osservatori.

4) CODICI MATLAB: sono contenuti i codici Matlab relativi alle analisi sul nostro esperimento e sulle analisi compiute su MASSVIS.









