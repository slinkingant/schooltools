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
