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
- `public/icons/` — app-iconen (192, 512, maskable 512, Apple 180 en SVG).
- `public/_headers` — zorgt dat de service worker en het manifest niet lang in de browsercache blijven hangen.

Installeren op de iPad: open https://school.1394.nl/tafelheld.html in Safari → Deel → **Zet op beginscherm**.
Op Android/Chrome verschijnt een installatieknop in de adresbalk of het menu.

Pas je de lijst met vaste bestanden in de service worker aan, verhoog dan `VERSION` bovenin `tafelheld-sw.js`.
De voortgang van de kinderen staat in de browseropslag van `school.1394.nl` en blijft bij updates bewaard.
