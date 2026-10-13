# schooltools

Kleine oefentools voor school, gehost op https://school.1394.nl via Cloudflare Workers (static assets).

## Nieuwe tool toevoegen
1. Zet het `.html`-bestand in `public/`.
2. Voeg een regel toe aan de `TOOLS`-lijst onderaan `public/index.html`.
3. Commit en push naar `main` — Cloudflare deployt automatisch.

## Dev-versies (testen vóór livegang)
- https://school.1394.nl/dev_tafelheld.html en https://school.1394.nl/dev_sommenheld.html
- Niet gelinkt vanaf de startpagina, `noindex` voor zoekmachines, rood **DEV**-label rechtsboven.
- Eigen opslag (`dev_tafelheld.v1`, `dev_sommenheld.v1`): bij het eerste openen wordt de echte voortgang éénmalig gekopieerd, daarna staan dev en productie volledig los. Testen kan de echte voortgang dus niet kapotmaken.
- Eigen service worker, cache en manifest: dev en productie kunnen naast elkaar als app geïnstalleerd zijn.

Werkwijze:
1. Wijzig `public/dev_<app>.html` (en eventueel `dev_<app>-sw.js`), push, test op de dev-URL.
2. Goed? `scripts/promote.sh <app>` zet de dev-versie over naar productie (haalt de dev-regel weg en zet de namen terug). Controleer `git diff`, commit, push.
3. Productie met de hand aangepast? `scripts/make-dev.sh <app>` maakt de dev-versie opnieuw vanuit productie (overschrijft dev).

Dev-voortgang opnieuw kopiëren vanuit productie: in de browserconsole `localStorage.removeItem('dev_tafelheld.v1')` en de pagina herladen.

## Bouwen en versies
`wrangler deploy` (ook bij Cloudflare na elke push) voert eerst `node scripts/build.mjs` uit:
- `public/` wordt gekopieerd naar `dist/` (niet in git); Cloudflare publiceert `dist/`.
- In elke app met `__BUILD__` komt de versie: de eerste 8 tekens van een hash over de app en zijn service worker, plus de datum van de laatste commit van die app. Alleen een app die echt veranderd is krijgt dus een nieuwe versie.
- `dist/version.json` bevat per app de nieuwste versie.

## Updates (nu alleen in de dev-versies)
- De app vergelijkt zijn eigen versie met `/version.json`: 3 s na het starten, bij terugkomen op de voorgrond, als er weer internet is en elk halfuur (hoogstens één keer per minuut).
- Nieuwere versie → balk onderin **"Er is een nieuwe versie — Bijwerken / Later"**. Tijdens het oefenen (scherm `s-play`) blijft de balk weg tot het kind klaar is. Bijwerken laat de service worker bijwerken en herlaadt de app; de voortgang blijft staan.
- Bij Statistieken → Profiel beheren staan de geïnstalleerde versie en datum, met een knop **Zoek naar update**.
- Lokaal zonder bouwen (bijv. `public/` direct openen) staat er "lokale kopie" en wordt niet gecontroleerd.

## Voortgang overzetten (QR-code) — nu alleen in de dev-versies
Knop **📲 Voortgang overzetten** op het profielenscherm (alle kinderen geselecteerd), op de kindpagina (**📲 Overzetten**, alleen dat kind geselecteerd) en bij Statistieken → Profiel beheren.
- **Versturen**: kies de kinderen; de voortgang wordt compact gemaakt en gecomprimeerd en getoond als QR-code. Past het niet in één code, dan wisselen meerdere codes elkaar af (elke 0,5 s) en verzamelt de ontvanger alle delen.
  - Compact formaat (v2): lijsten van gelijke objecten als kolommen, sleutels gesorteerd en front-coded, tijdstippen in minuten, bedenktijd in tienden van seconden, kommagetallen op 2 decimalen; `sched` en `elapsed` (worden nergens gelezen) gaan niet mee.
  - Daarna deflate en **base45** in de alfanumerieke QR-modus: `OV2<T|S><Z|J>:<id>:<deel>:<aantal>:<data>`, max. 470 bytes per code (QR-versie 17, foutcorrectie M).
  - Resultaat met het voorbeeldprofiel: Tafelheld 7 → 3 codes, Sommenheld 9 → 4 voor twee kinderen.
- **Ontvangen**: de camera gaat pas aan na een tik op **Camera openen** (ook na annuleren of een fout eerst weer die vraag). Scannen met BarcodeDetector waar beschikbaar, anders jsQR. Zonder camera: plak de tekst van "Kopieer als tekst"; dat is een link (`…#ov=<id>.1.1.y<base64url>`) die ook direct te openen is. De QR-code zelf is geen link, dus scannen kan alleen in de app. Alleen het huidige formaat (v2) wordt ondersteund.
- **Samenvoegen** in plaats van overschrijven, per kind (zelfde id of zelfde naam):
  - sommen (`facts`, `lvs`): de stand met de meeste pogingen;
  - herhaalplanning (`tables`, `lv`): de laatst herhaalde; sterren, `passed` en `best` gaan nooit omlaag;
  - niveaus/stappen, records, oefentijd: het hoogste;
  - sessies: samengevoegd op tijdstip (max. 60); naam, kleur en instellingen van het ontvangende apparaat blijven staan.
  Nogmaals dezelfde code ontvangen verandert niets.
- Er gaat niets via internet: de QR-bibliotheken staan in `public/vendor/` (qrcode-generator, MIT; jsQR, Apache-2.0) en zitten in de cache van de service worker.
- Handig op de iPad: voortgang die in Safari is opgebouwd kan zo ook naar de app op het beginscherm (die hebben gescheiden opslag).

## Privacy
Alle voortgang staat in de browseropslag (localStorage) van het apparaat; er zijn geen cookies, geen accounts, geen analytics en geen verbindingen met andere websites.
De lettertypes (Baloo 2 en Lexend, SIL Open Font License) staan daarom in `public/fonts/` in plaats van bij Google Fonts. Gebruik in nieuwe tools ook die bestanden.

## Tafelheld als app (PWA)
Tafelheld is installeerbaar als app en werkt ook zonder internet.

- `public/tafelheld.webmanifest` — naam, kleuren, iconen; start op `/tafelheld.html`.
- `public/tafelheld-sw.js` — service worker: de app wordt eerst via het netwerk geladen (zodat updates direct binnenkomen) en valt offline terug op de bewaarde versie; iconen en lettertypes komen uit de cache.
- `public/icons/` — het Tafelheld-logo als app-icoon (192, 512, maskable 512, Apple 180, favicon 64) en als kaartplaatje voor de startpagina (`tafelheld-logo-256.webp`).
- `public/_headers` — zorgt dat de service worker en het manifest niet lang in de browsercache blijven hangen.

Installeren op de iPad: open https://school.1394.nl/tafelheld.html in Safari → Deel → **Zet op beginscherm**.
Op Android/Chrome verschijnt een installatieknop in de adresbalk of het menu.

Pas je de lijst met vaste bestanden in de service worker aan, verhoog dan `VERSION` bovenin `tafelheld-sw.js`.
De voortgang van de kinderen staat in de browseropslag van `school.1394.nl` en blijft bij updates bewaard.

## Sommenheld (optellen en aftrekken)
Zelfde opzet als Tafelheld: profielen, niveaus met sterren, herhalen met FSRS per niveau, meestertoets (30 sommen), Door elkaar, Minuut-quiz en statistieken.
Eigen PWA-bestanden: `public/sommenheld.webmanifest`, `public/sommenheld-sw.js` en `public/icons/sommenheld-*`. De voortgang staat los van Tafelheld (`sommenheld.v1` in de browseropslag).

| Groep | Niveaus |
|---|---|
| 3 | Plus tot 10 · Min tot 10 · Samen 10 · Tot 20, niet over de 10 · Over de 10 |
| 4 | Tientallen tot 100 · Tot 100, niet over het tiental · Tot 100, over het tiental |
| 5 | Tot 100, twee grote getallen · Welk getal mist er? · Tot 1000, ronde getallen |
| 6 | Tot 1000, met overstap |

Bedenktijd per som (bepaalt de beoordeling voor herhalen, de tempo-sterren en de limieten van de meestertoets):

| Som | Bedenktijd |
|---|---|
| tot 10 | 2,5 s |
| tot 20 | 3,5 s, over de 10 +1 s |
| tot 100 | 5 s, over het tiental +2 s, twee getallen boven de 10 +1,5 s |
| boven 100 | 8 s, over het tiental +3 s, over het honderdtal +3 s, twee getallen van drie cijfers +2 s |
| ronde getallen (30 + 40, 560 + 30) | 60% van de tijd, minstens 3 s |
| ontbrekend getal (? + 26 = 73) | +2 s |

Elk niveau heeft 3 stappen: Oefenen (met hulpknop), Zonder hulp en Op tempo. De hulp toont kralen in rijen van 10 (tot 20) of de tussenstappen ("eerst de grote stukken"). Hulp gebruiken telt als "Moeilijk" voor de planning.
