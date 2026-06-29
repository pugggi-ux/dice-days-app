# Dice Days App – Projekt-Briefing v2

Dieses Dokument fasst alle Entscheidungen aus der Konzept- und Design-Phase
(geführt mit Claude im Chat) zusammen. Es ersetzt eine frühere, erste
Version dieses Briefings vollständig.

## 0. Wichtiger Hinweis zum Projektstart

**Vor dem Import dieses Briefings muss das GitHub-Repo auf einen
sauberen Anfangszustand zurückgesetzt werden.** Es gab einen ersten,
abgebrochenen Anlauf in Claude Code mit einem älteren, unvollständigen
Briefing (React-Native-Stack, ohne die später getroffenen
Detail-Entscheidungen). Dieser Lauf wurde gestoppt, während er noch
Dateien erzeugte. Es ist nicht sicher, ob und welche Fragmente davon im
Repo zurückgeblieben sind. Bitte vor dem eigentlichen Projektstart:
- Alle Dateien außer `.git` aus dem Repo entfernen, ODER
- Das Repo komplett neu anlegen
So wird sichergestellt, dass kein halbfertiger Code aus dem ersten,
verworfenen Versuch mit dem neuen Stand kollidiert.

## 1. Hintergrund und Motivation

Dice Days ist ein wiederkehrendes mehrtägiges Spielewochenende einer festen
Freundesgruppe (mind. 11 Ausgaben bisher, intern "DD9", "DD10", "DD11" etc.
genannt). Die Organisation läuft aktuell komplett über ein selbstgebautes
Notion-System. Eine eigene App soll das ablösen.

**Warum keine reine Notion-Lösung mehr ausreicht:**
- Nicht jeder Mitspieler hat oder will einen Notion-Account
- Manche Mitspieler lehnen aus Datenschutzgründen einen Account-Zwang ab
- Datenpflege ist zu manuell, vor allem das Erfassen neuer Spiele
- Keine BoardGameGeek-Anbindung – Cover, Spieleranzahl, Dauer, Komplexität
  (Weight) müssen händisch eingetragen werden
- Mobile Notion-Ansicht ist für Gelegenheitsnutzer nicht intuitiv genug

**Vergleichbare existierende App (Referenz, kein Vorbild 1:1):**
"Spielatus" (Schweiz, Pascal Amberg) – Spielabend-Organizer mit Gruppen,
Terminfindung, BGG-Sammlung-Sync, Kalender-Export. Fokus liegt dort auf
spontanen Spielabenden mit beliebigen Gruppen, nicht auf einem strukturierten
mehrtägigen Event mit Rollen wie Erklärer/Lieferant. Dice Days unterscheidet
sich dadurch klar im Funktionsumfang.

## 2. Die Notion-Datenbank ist die fachliche Vorlage

**Wichtig für Claude Code:** Das bestehende Notion-System ist nicht nur
eine grobe Inspiration, sondern die **verbindliche fachliche Vorlage**
für Datenmodell und Geschäftslogik. Wo dieses Briefing Lücken lässt
(z.B. bei Packliste, Mitbringbuffet, Countdown, Zeitvolumen-Tracking),
soll Claude Code, wo möglich, die Struktur der Notion-Datenbank als
Referenz heranziehen bzw. beim Nutzer gezielt nachfragen, wie das
jeweilige Notion-Feld/-Modul fachlich funktioniert, statt frei zu
improvisieren. Die App übernimmt die fachliche Logik 1:1, nicht die
technische Umsetzung (Notion-Datenbanken/Relationen werden zu
eigenen Tabellen im neuen Backend, nicht per API eingebunden).

### Rollen pro Spiel
Erklärer, Lieferant, Interessent und Erklärbedarf sind **vier
unabhängige Eigenschaften**, die eine Person gleichzeitig haben kann:
- **Interessent** – möchte mitspielen
- **Erklärer** – bringt die Regelkenntnis mit. **Mehrere Personen
  gleichzeitig möglich** (z.B. wenn zwei Leute das Spiel gut kennen)
- **Lieferant/Besitzer** – bringt das Spiel physisch mit. **Ebenfalls
  mehrere Personen gleichzeitig möglich** (z.B. wenn ein Spiel mehrfach
  in der Gruppe vorhanden ist)
- **Erklärbedarf** – ist Interessent, braucht aber eine Regelerklärung.
  **Schließt sich mit der Erklärer-Rolle gegenseitig aus**: wird eine
  Person als Erklärer eingetragen, wird ihr eigener Erklärbedarf
  automatisch zurückgesetzt (siehe Abschnitt 4, Detailansicht)

Erklärer und Lieferant sind technisch **Mengen von Personen**, keine
einzelne Zuordnung – das Datenmodell muss das als n:m-Relation abbilden,
nicht als einzelnes Fremdschlüsselfeld.

### Statusfelder
- **Spielstand**: ungeplant → geplant → gespielt
- **Packstatus**: einpacken → give/get → erledigt

### Abgeleitete Werte
- **Sweet Spot**: Interesse-Anzahl ins Verhältnis zur maximalen
  Spieleranzahl gesetzt. Kann über 100% gehen (mehr Interessenten als
  Plätze) – visuell als "Hot"-Zustand markiert (siehe Abschnitt 4).
- **Engpass**: ein Spiel hat einen Engpass, wenn **kein Erklärer ODER
  kein Lieferant** eingetragen ist. Die Anzahl der Interessenten spielt
  dafür keine Rolle. Sweet Spot und Engpass sind unabhängige Größen.

### Bestehende Notion-Unterseiten (fachliche Vorbilder für App-Screens)
- **komplette Liste** – Gesamtübersicht aller Spiele, mit Filtertabs
- **Inbox** – reduzierte Sicht: alle Spiele, bei denen die Person weder
  Erklärer ist noch sie ausgeblendet hat
- **Mitspielen** – persönliche Sicht: alle Spiele, bei denen die Person
  Interessent oder Erklärer ist, inkl. Zeitleiste und
  Zeitvolumen-Tracking (verfügbare Spielzeit abzüglich
  Schlafzeiten/Abwesenheiten)
- **Erklären** – reduzierte Sicht nur auf Spiele, bei denen die Person
  Erklärer ist
- **Packliste**, **Mitbringbuffet**, **Countdown** – Logistik-Module,
  noch nicht im Detail spezifiziert; bei Bedarf Notion-Struktur als
  Referenz konsultieren

## 3. Zielarchitektur der App

### Plattform und Stack
- **Flutter**, eine Codebasis für iOS, Android **und Web**. Diese
  Drei-Plattform-Anforderung ist ein bewusstes, hartes Kriterium – die
  App soll auch direkt im Browser ohne Installation nutzbar sein, nicht
  nur als native Mobile-App. Sprache: Dart
- Backend: Supabase empfohlen (Postgres, Auth, Realtime) – Realtime ist
  wichtig, damit Interesse-Bekundungen etc. live bei allen Mitspielern
  ankommen
- BGG-Anbindung über die offene BoardGameGeek XML-API (kostenlos, kein
  Auth nötig)

### Arbeitsweise: durchgehende Live-Vorschau einfordern
**Der Nutzer möchte nach jedem nennenswerten Entwicklungsschritt sofort
eine laufende, sichtbare Version sehen können** – entweder direkt im
Browser (über Flutter Web, lokal gestartet mit einem aufrufbaren Link)
oder, wo technisch möglich, direkt als Artefakt/Vorschau in der
Entwicklungsumgebung selbst. Kein Entwicklungsschritt sollte über
längere Zeit "im Dunkeln" laufen, ohne dass der Nutzer das Ergebnis
zwischendurch sehen und kommentieren kann. Claude Code sollte daher:
- Flutter-Web als primäres Ziel für die laufende Entwicklung priorisieren
  (schnellster Weg zu einer sofort sichtbaren Vorschau im Browser)
- Nach jedem Screen/Feature aktiv anbieten oder direkt ausführen, den
  lokalen Dev-Server zu starten bzw. neu zu laden
- Native iOS/Android-Builds sind weiterhin das Ziel für die finale
  Veröffentlichung, aber nicht der primäre Weg für iteratives Feedback
  während der Bauphase

### Zugang ohne Account-Zwang
- **Kein Pflicht-Account.** Zugang über einen Event-Code (vergleichbar mit
  Kahoot/Jackbox-Codes): jede Anlage eines Dice-Days-Wochenendes erzeugt
  einen eigenen Code
- Beitritt: Code eingeben + Nickname wählen, kein Passwort, keine E-Mail
- Eine Person kann über denselben Nickname/Geräte-Token in mehreren
  Events gleichzeitig drin sein
- Cross-Device-Sync: per optionalem Account ODER per QR-Code-Scan, um ein
  zweites Gerät mit demselben Nutzer-Token zu verknüpfen
- Multi-Tenant von Anfang an gedacht (mehrere Gruppen/Events sollen die
  App grundsätzlich nutzen können, nicht nur diese eine Gruppe)

### BGG-Integration (zentrale Anforderung)
- Beim Hinzufügen eines Spiels: Namenssuche gegen BGG, Auswahl aus
  Vorschlägen, automatischer Import von Cover, Spieleranzahl, Spieldauer,
  Komplexität (Weight)
- Optional: eigenen BGG-Account hinterlegen, um die persönliche Sammlung
  direkt zu importieren

### Handelsbörse
- Eigenständiges Modul für getauschte/gehandelte Spiele
- Freitext-Eintrag ohne BGG-Pflichtverknüpfung – nur Name + Haken zum
  Abschließen, keine vollständigen Metadaten

### Packlisten-Guide
- Dreistufig: generische Event-Standardliste (z.B. Hausschuhe), eigene
  persönliche Zusätze (Medikamente etc.), automatisch generierte Punkte
  aus Mitbring-Zusagen und der Handelsbörse

## 4. UI/Interaktionsdesign – bereits final abgestimmte Mechaniken

Diese Punkte wurden im Chat iterativ mit interaktiven HTML/JS-Mockups
durchgespielt und sind fachlich/interaktionsdesignmäßig festgelegt. Die
technische Umsetzung in Flutter ist neu zu bauen, das **Verhalten**
soll aber genau diesem Vorbild folgen.

### Designsprache
- Akzentfarbe: Tan-Gold `#B8A082` (aus dem Dice-Days-Logo: graues "DICE" +
  goldenes "DAYS", Y im Wort "DAYS" ist ein stilisierter, umgedrehter
  Meeple)
- Logo-Originaldatei liegt vor und soll im echten Code als Bild-Asset
  eingebunden werden (nicht nachgezeichnet)
- Grundton: ruhig, flach, viel Weißraum, keine Schatten/Gradients
- Statusfarben: Grün = Erfolg/Interesse/Erklärbedarf (dezent), Gelb =
  Erklärer-Rolle (markant, höchste Priorität in der Farbhierarchie),
  Rot = fehlende Zuordnung/entfernende Aktion, Tan-Gold = "das bin ich"
  (eigene Identität), wird aber von der gelben Erklärer-Farbe
  überschrieben, falls man selbst Erklärer ist (Rollenstatus hat
  Vorrang vor reiner Identitätsmarkierung)

### Spieleliste (Kern-Screen)
- Jede Spielkarte zeigt: Cover (aus BGG), Name, Spieleranzahl/Dauer/
  Weight, und rechts oben ein **Sweet-Spot-Indikator**
- **Sweet-Spot-Indikator**: ein Fortschrittsring (grüner Kreis, der sich
  proportional zur Auslastung füllt). Bei Werten über 100% wechselt der
  Indikator zu einem Flammen-Icon in Grün (nicht Rot – Rot würde wie ein
  Alarm wirken, es soll "begehrt" bedeuten). Größe so gewählt, dass der
  untere "Bauch" der Flamme optisch denselben Durchmesser hat wie der
  Fortschrittsring (in den Tests: Tabler-Icon `ti-flame`, 30px
  Icon-Größe bei einem 18px-Ring-Durchmesser)
- **Engpass-Anzeige**: steht als kleine, rote Zeile **über** dem
  Spieltitel ("Kein Erklärer" / "Kein Lieferant"), nicht als Badge in der
  unteren Zeile
- **Untere Badge-Zeile**: zeigt nur tatsächlich vorhandene, positive
  Fakten – "X Interessenten" (grün eingefärbt, wenn man selbst dabei ist,
  sonst neutral) und "Person erklärt". Keine Badges für fehlende Dinge

### Inbox (Triage-Screen für neue Spiele)
- Zeigt alle Spiele, bei denen man sich noch nicht geäußert hat
- Bedienung **wahlweise** per Button oder per Swipe-Geste – als
  Einstellung pro Person wählbar
- Info-Hinweis zur Bedienung ist standardmäßig eingeklappt, über ein
  kleines Info-Icon neben dem Screen-Titel aufklappbar

#### Swipe-Logik im Detail
Vorbild: Outlook/Gmail-Mail-Swipe mit Zwischenrastung, erweitert um eine
dritte Dimension (Erklärbedarf), nach dem "Zugwaggon"-Prinzip (feste,
nicht überlappende Flächen, die sich gestaffelt aufdecken statt frei zu
überlagern).

- **Wisch nach links**: trägt "ausgeblendet" ein, Karte fliegt aus der
  Liste
- **Wisch nach rechts**, dreistufig:
  1. **Erste Phase**: Karte und grüner "Interesse"-Waggon schieben sich
     gemeinsam, fest aneinander gekoppelt, nach rechts
  2. **Zweite Phase**: zusätzlich deckt sich ein gelber
     "Erklärung"-Waggon auf, direkt links neben dem Interesse-Waggon,
     ebenfalls ohne Überlappung
  3. **Volle Durchziehschwelle**: trägt automatisch nur "Interesse" ein
     (ohne Erklärbedarf), Karte fliegt weg, kein Klick nötig
  4. Lässt man dazwischen los, **rastet** die Karte ein, beide Waggons
     sind als eigenständige, antippbare Flächen sichtbar – Tap auf
     "Interesse" trägt nur Interesse ein, Tap auf "Erklärung" trägt
     Interesse UND Erklärbedarf gleichzeitig ein
  5. Lässt man unterhalb der Mindestschwelle los, springt alles
     zurück auf die Ausgangsposition
- **Eingerastete Karte erneut anfassen**: Drag setzt ab der aktuellen
  Position fort
- **Andere Karte anfassen, während eine andere eingerastet ist**: die
  vorherige springt automatisch zurück
- **Nach jeder Aktion**: Toast mit Klartext + Rückgängig-Link, automatisches
  Verschwinden nach ca. 3,5 Sekunden
- **Rückgängig** muss den internen "eingerastet"-Zustand der Karte
  vollständig zurücksetzen, damit ein erneutes Anfassen wieder korrekt
  bei Position 0 beginnt

#### Geplante Erweiterung für die "Mitspielen"-Ansicht (noch nicht gebaut)
- Wisch nach **links**: Erklärbedarf an/aus umschalten (Toggle, kein
  Entfernen aus der Liste)
- Wisch nach **rechts**: "doch kein Interesse mehr" (entfernt die Person
  aus den Interessenten dieses Spiels)
- Eigene Farbgebung nötig, da hier Rechts-Wisch eine entfernende statt
  hinzufügende Aktion ist – angedacht: Rot für "kein Interesse mehr"

### Detailansicht eines Spiels (fertig spezifiziert)
Öffnet sich beim Antippen einer Spielkarte; der Karten-Header
transformiert sich nach oben in den Detail-Header (gleiches Layout wie
die Listenkarte, nur größer, plus BGG-Link).

**Aufbau von oben nach unten:**
1. Zurück-Navigation
2. Karten-Header (Cover, Name, Sweet-Spot/Hot-Icon, Kopfdaten, BGG-Link)
3. Engpass-Hinweis bzw. eigener Rollenstatus als Zeile darunter
   (z.B. "Du erklärst dieses Spiel", grün)
4. Beschreibungstext
5. **Erklärer- und Lieferant-Spalten, nebeneinander** (siehe unten)
6. **Interessentenliste**, eine einzige zusammengeführte Liste (siehe
   unten)
7. Aktionsbuttons (siehe Sichtbarkeitsregeln unten)

**Erklärer/Lieferant als zwei eigene Spalten nebeneinander:**
- Jede Spalte hat eine eigene Überschrift ("Erklärer" / "Lieferant")
- **Direkt neben jeder Überschrift sitzt von Anfang an ein kleines
  Plus-Icon (Kreis-Plus)** – unabhängig davon, ob die Spalte leer oder
  schon besetzt ist. Tap öffnet ein Auswahlmenü mit Checkbox-Liste aller
  Event-Teilnehmer (Mehrfachauswahl), inkl. der eigenen Person. Dieser
  Weg deckt explizit den Fall ab, dass man eine **andere** Person
  einträgt, ohne sich selbst zuerst eintragen zu müssen (z.B.: man
  spricht mit jemandem ab, dass er statt einem selbst erklärt/mitbringt,
  und trägt diese Person direkt über das Plus ein)
- **Ist die Spalte leer**, erscheint zusätzlich darunter ein großer
  Schnellzugriffs-Button ("Ich erkläre" / "Ich bringe es mit") für den
  eigenen, schnellen Fall. Dieser Button verschwindet vollständig, sobald
  mindestens eine Person in der Spalte steht
- **Mehrere Personen in einer Spalte** werden vertikal **untereinander
  gestapelt** (nicht nebeneinander), jede als eigene Chip-Zeile
- **Jeder einzelne Chip** (auch der eigene) hat ein eigenes
  Minus-im-Kreis-Icon zum direkten Entfernen dieser Person – kein
  Unterschied zwischen "mich selbst entfernen" und "andere entfernen"
- Trägt man sich selbst als Erklärer ein (über Plus-Menü, Schnellzugriff
  oder im Picker), wird der eigene Erklärbedarf-Status automatisch
  zurückgesetzt (siehe Erklärbedarf-Logik)
- Zieht man sein Interesse komplett zurück, wird man automatisch auch
  aus Erklärer- und Lieferant-Spalte entfernt (logische Konsequenz, man
  kann nicht Erklärer eines Spiels sein, an dem man kein Interesse hat)

**Interessentenliste:**
- **Eine einzige Liste**, keine separate zweite Liste für Erklärbedarf
  (frühere Idee einer eigenen Erklärbedarf-Liste wurde verworfen –
  wirkte redundant, da Erklärbedarf nur eine Zusatzeigenschaft von
  Interessenten ist, kein eigenständiger Personenkreis)
- Personen als kompakte Chip-Pillen (Mini-Avatar mit Initialen + Name),
  die bei Platzmangel umbrechen, keine "+N weitere"-Zusammenfassung –
  **alle Namen werden ausgeschrieben**
- Eigene Person farblich hervorgehoben (Tan-Gold), außer man ist
  zugleich Erklärer – dann gilt die gelbe Erklärer-Farbe (siehe oben)
- **Erklärbedarf wird nur durch ein kleines grünes Fragezeichen-Icon
  hinter dem Namen markiert**, der Chip-Hintergrund selbst bleibt sonst
  neutral/identisch zu allen anderen Chips (frühere Idee einer
  zusätzlichen Hintergrundfarbe für Erklärbedarf wurde verworfen – wirkte
  wie eine "fest zugesagt"-Bestätigung statt eines dezenten Hinweises)
- Überschrift zeigt Gesamtzahl plus Erklärbedarf-Teilzahl in Klammern,
  mit demselben Fragezeichen-Icon statt eines Worts:
  "Interessenten 6 (❔ 2)"

**Aktionsbuttons unten, mit klaren Sichtbarkeitsregeln:**
- **"Interesse zurückziehen"** (Icon: `ti-heart-off`, neutral grau) /
  **"Interesse bekunden"** (Icon: gefülltes Herz, grün) – Toggle-Paar,
  abhängig vom eigenen Interessenstatus. *Hinweis: ein Icon mit zwei
  wirklich sichtbar auseinanderdriftenden Herzhälften wurde gesucht,
  aber in der verfügbaren Icon-Bibliothek (Tabler) nicht gefunden;
  `ti-heart-broken` und `ti-heart-off` waren die einzigen Kandidaten,
  letzteres wurde gewählt. Bei Verfügbarkeit einer Icon-Bibliothek mit
  passenderem Symbol in Flutter gerne austauschen*
- **"Erklärbedarf an/aus"** – nur sichtbar, wenn man Interessent UND
  **nicht** selbst Erklärer ist (wer erklärt, braucht keine eigene
  Erklärung). Verschwindet automatisch, sobald man sich als Erklärer
  einträgt, und umgekehrt wieder sichtbar, falls man sich als Erklärer
  austrägt
- Es gibt **keinen** separaten "Ich erkläre"/"Ich bringe es mit"-Button
  in dieser unteren Button-Zeile – diese beiden Aktionen laufen
  ausschließlich über die Erklärer-/Lieferant-Spalten weiter oben (siehe
  dort)

## 5. Bekannte technische Einschränkungen aus der Mockup-Phase

Diese Punkte sind reine Artefakte der Chat-Umgebung und für die
Flutter-Entwicklung **nicht relevant**, werden hier nur zur
Vollständigkeit dokumentiert:
- Externe Bild-URLs (z.B. von BGG-CDN) konnten im Chat-Mockup-Tool nicht
  geladen werden (CSP-Domain-Whitelist). Im echten Code ist das kein
  Problem
- Interaktive HTML/JS-Mockups liefen im Chat nur im Browser zuverlässig,
  nicht in der nativen Claude-iOS-App (Plattform-Einschränkung von
  Claude selbst, hat nichts mit der späteren Dice-Days-App zu tun)

## 6. Offene Punkte / nächste Schritte für Claude Code

- [ ] Datenmodell konkret als SQL-Schema für Supabase ausarbeiten
  (Events, Participants, Games, Interest/Explainer/Supplier als
  n:m-Relationstabellen, Trade-Items, Packlist-Items)
- [ ] Event-Code-Generierung und Geräte-Token-Mechanismus konkret
  spezifizieren (Code-Format, Kollisionsvermeidung, QR-Code-Inhalt)
- [ ] BGG-XML-API-Anbindung technisch aufsetzen (Endpunkte, Caching,
  Rate-Limits)
- [ ] "Mitspielen"-Ansicht mit der umgedrehten Wisch-Logik bauen
  (siehe Abschnitt 4)
- [ ] "Erklären"-Ansicht (reduzierte Sicht nur für Erklärer-Rolle)
- [ ] Packlisten-Guide, Handelsbörse, Countdown-Modul im Detail
  spezifizieren – Notion-Struktur als Referenz konsultieren (siehe
  Abschnitt 2), im Zweifel beim Nutzer nachfragen
- [ ] Zeitvolumen-Tracking (verfügbare Spielzeit abzüglich Schlafzeiten)
  aus dem Notion-Vorbild übernehmen oder bewusst für V1 weglassen
- [ ] Passendes Icon-/Symbol-Set für Flutter festlegen (Vorbild war
  Tabler Icons im Web-Mockup; in Flutter z.B. Material Icons,
  Cupertino Icons, oder ein Icon-Font-Paket mit ähnlichem Umfang)
- [ ] Store-Vertrieb klären: Apple Developer Program ist ein
  Jahresabo (99 USD/Jahr) – bei Nichtverlängerung verschwindet die App
  aus dem Store für Neuinstallationen, bestehende Installationen
  funktionieren weiter. Google Play Console ist eine einmalige Gebühr
  (25 USD), kein Jahresabo. Web-Version (Flutter Web) ist davon ohnehin
  unabhängig nutzbar. Für eine geschlossene Gruppe ohne Store-Zwang
  kämen auch TestFlight/internes Testing in Frage – noch nicht
  entschieden
