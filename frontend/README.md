# MINT 2015 Leizig

## Frontend Benutzung

Die Anwendung "Mint 2015 Leipzig" ist eine Webseite mit dem Angular-Framework. Sie funktioniert als Standalone Version und benötigt weder Datenbank noch bestimmt Umgebungen.

### Produktiv

Das Frontend kann allein per Standard-Server ausgeliefert werden. Dabei sollte der Ordner `frontend/dist` als Webroot angegeben und die `index.html` aufgerufen werden.

### Development

Für das Entwickeln werden die folgenden Anwendungen benötigt:

* node.JS
* npm (NodePackageManager als Packagemanager)
* gulp (als build-Tools) `npm install -g gulp`
* bower (als Packagemanager für die Webanwendung) `npm install -g bower`

Diese Anwendungen sollten global installiert werden.

Weiter werden per `npm install` die notwendigen Packetabhängigkeiten installiert.

Nun kann per `gulp watch` ein endloser Task angestoßen werden, welcher einen kleinen lokalen Webserver, einen Livereloadserver und einen Watch auf alle relevanten Dateien zur Verfügung stellt.

Den Webserver ist dann unter [http://localhost:3000](http://localhost:3000) erreichbar.
Eine entsprechende Erweiterung für die Funktionalität von Livereload ist für diverse Browser verfügbar.


# Webseiten Aufbau:

Wie bei Angular.JS üblich, besteht die Webseite aus einer HTML-Seite. Diese wird mit diversen JavaScript-Teilen erweitert und bietet dadurch den vorliegenden Funktionsumfang an.

In unserem Fall besteht die Anwendung aus zwei Dateien: `frontend/dist/js/app.min.js` und `frontend/dist/js/app.tmpl.min.js`. Diese Dateien beinhalten die Anwendungslogik.

Die zwei Dateien werden über einen Build-Prozess erzeugt. Ausgangspunkt für die Dateien finden sich im Order `frontend/src`. Die Struktur der Dateien und deren Verwendung ist im Folgenden zu erkennen.

	src/                             ──> Ausgangspunkt
	├── angular/                     ──> Angular.JS Anwendung
	|   ├── app/                     ──> globale Angular.JS Struktur
	|   |   ├── app.coffee           ──> App-Deklaration, Routen
	|   |   ├── json.factory.coffee  ──> Factory zum Laden und Verarbeiten von JSON-LD-Dateien
	|   |   └── json.filter.coffee   ──> Filter-Implementierung
	|   |
	|   ├── controller/              ──> Angular.JS Controller (Logik)
	|   |   ├── home.coffee          ──> Home/Landingpage             (#/home)
	|   |   ├── info.coffee          ──> Informationsseite            (#/info)
	|   |   ├── internal.coffee      ──> Qualitätsicherungsseite      (#/internal)
	|   |   ├── navi.coffee          ──> Navigationslogik
	|   |   ├── place.coffee         ──> Detailseite eines MINT-Ortes (#/p/{Mint-Ort-ID})
	|   |   └── search.coffee        ──> Suchseite für MINT-Orte      (#/search)
	|   |
	|   └── views/                   ──> Angular.JS Templates
	|       ├── home.jade            ──> Home/Landingpage             (#/home)
	|       ├── info.jade            ──> Informationsseite            (#/info)
	|       ├── internal.jade        ──> Qualitätsicherungsseite      (#/internal)
	|       ├── place.jade           ──> Detailseite eines MINT-Ortes (#/p/{Mint-Ort-ID})
	|       └── search.jade          ──> Suchseite für MINT-Orte      (#/search)
	|
	├── jade/                         ──> Jade-Files
	|   └── index.jade                ──> results later in index.html
	|
	└── less/                         ──> Less-Files
	    ├── bootstrap.less            ──> Twitter-Bootstrap for basic Styling
	    ├── jumbotron-narrow.less     ──> Twitter-Bootstrap-Jumbotron inspired base template CSS
	    └── style.less                ──> Custom CSS rules


# Backend Aufbau:

Das Backend der Anwendung besteht grundlegend aus 2 Dateien im RDF Triple Language Format: `RDFDaten/MINTBroschuere2014.ttl` und `LeipzigDataExtract.ttl`.
Der `LeipzigDataExtract` Datensatz stellt einen Auschnitt der Inhalte von http://leipzig-data.de/ dar und bildet die grundlegenden Strukturen der Daten für die Broschüre.
Er beinhaltet die, im Folgenden aufgeführten Datenobjekte:

* ld:Adresse
* ld:ExterneAdresse
* ld:Ort
* ld:Ortsteil
* ld:Stadtbezirk
* ld:Tag

Basierend auf diesen Daten setzt sich der `MINTBroschuere2014` Datensatz parallel zum Inhalt der MINT Broschüre des Jahres 2014 zusammen.
Innerhalb der Broschüre stehen die verschiedenen MINT-Orte Leipzigs, mit deren Angeboten, Schwerpunkten und weiteren Eigenschaften beschrieben.
Diese Informationen finden sich dementsprechend in der `MINTBroschuere2014.ttl` wieder und sind im Folgenden schemenhaft aufgeführt:

Ortsbeschreibungen:

	mint2014:"kürzel für einen MINT-Ort aus Leipzig Data"
		rdfs:label "Voller Name des MINT-Ortes" ;
		mint2014:Kurzinformation "Eine in der Broschüre gegebene Kurzinformation des MINT-Ortes" ;
		mint2014:Leistungsangebot "In der Broschüre gegebene Beschreibung der erbrachten Leistungen" ;
		mint2014:Oeffnungszeiten "In der Broschüre gegebene Öffnungszeiten" ;
		mint2014:OePNV-Anbindung "In der Broschüre gegebene Verkehrsanbindung" ;
		mint2014:Telefon "In der Broschüre gegebene Telefonnummer" ;
		mint2014:Fax "In der Broschüre gegebene Fax Nummer" ;
		mint2014:Mail "In der Broschüre gegebene Mail Adresse" ;
		mint2014:Internet "In der Broschüre gegebene Internet Adresse" ;
		a mint2014:Ortsbeschreibung ;	(weist das Datenobjekt als Ortsbeschreibung aus)
		mint2014:hasTag ldTag:"Ein Tag der Leipzig Data";	(Alle Tags, die der MINT-Ort inne hat)
		mint2014:hasImage "Name des Bildes des MINT-Ortes.jpg" ;
		mint2014:hasLogo "Name des Logos des MINT-Ortes.png" ;
		mint2014:describes ldo:"kürzel für einen MINT-Ort aus Leipzig Data" .	(weist die Beschreibung einem Ort der Leipzig Data zu)
		
Angebote:

	<http://leipzig-data.de/Data/MINT-2014/Angebot/"Name des Angebots">	(Adresse des Angebots in Leipzig Data)
		ld:Lernziele "In der Broschüre gegebene Lernzieke des Angebots" ;
		ld:Zielgruppen "In der Broschüre gegebene Lernziele des Angebots" ;
		ld:Kosten "In der Broschüre gegebene Kosten des Angebots" ;
		ld:Veranstaltungsort "In der Broschüre gegebener Veranstaltungsort des Angebots" ;
		ld:Hinweise "In der Broschüre gegebene weitere Hinweise zum Angebot" ;
		ld:Laufzeit "In der Broschüre gegebene Laufzeit des Angebots" ;
		ld:relatedBundle mint2014:AnglerverbandLeipzig ; (zuweisung des Angebots zu einer gegebenen Ortsbeschreibung)
		a mint2014:Angebot ; (weist das Datenobjekt als Angebot aus)
		rdfs:label "Voller Name des Angebots" .
		
Schwerpunkte:

	<http://leipzig-data.de/Data/MINT-2014/Schwerpunkt/"Name des Schwerpunkts"> (Adresse des Schwerpunkts in Leipzig Data)
		ld:Zielgruppen "In der Broschüre gegebene Zielgruppen für die Angebote" ;
		ld:Kosten "In der Broschüre gegebene Kosten der Angebote" ;
		ld:Teilnehmerzahl "In der Broschüre gegebene Teilnehmerzahl für Angebote" ;
		ld:GTA "In der Broschüre gegebene Möglichkeit für Ganztagsangebote" ;
		ld:relatedBundle mint2014:UFZ ;	(zuweisung des Schwerpunkts zu einer gegebenen Ortsbeschreibung)
		a mint2014:Schwerpunkt ; (weist das Datenobjekt als Schwerpunkt aus)
		rdfs:label "Voller Name des Schwerpunkts" .	


# Verwendung der Daten:

Damit die beschriebenen Daten vom Frontend genutzt werden können, müssen diese zunächst in das .json Format portiert werden.
Hierfür steht unter https://morulia.de/convert/easyrdf/examples/converter.php ein Converter zur verfügung. Dieser basiert auf dem EasyRDF Converter der Website http://www.easyrdf.org/
und ermöglicht ein einfaches Umwandeln der Daten.
Die erstellten `.json` Datensätze müssen im Verzeichnis des Frontends als `frontend/dist/data/MINTBroschuere2014.json` und `frontend/dist/data/LeipzigDataExtract.json` hinterlegt werden.
Die Anwendung wird die Daten nun verwenden können. Dieser Vorgang muss für jede Aktualisierung der Daten wiederholt werden.




