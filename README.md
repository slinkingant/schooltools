# schooltools

Kleine oefentools voor school, gehost op https://school.1394.nl via Cloudflare Workers (static assets).

## Nieuwe tool toevoegen
1. Zet het `.html`-bestand in `public/`.
2. Voeg een regel toe aan de `TOOLS`-lijst onderaan `public/index.html`.
3. Commit en push naar `main` — Cloudflare deployt automatisch.

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

Elk niveau heeft 3 stappen: Oefenen (met hulpknop), Zonder hulp en Op tempo. De hulp toont kralen in rijen van 10 (tot 20) of de tussenstappen ("eerst de grote stukken"). Hulp gebruiken telt als "Moeilijk" voor de planning.
