#!/usr/bin/env bash
# Maakt dev_<app>.html, dev_<app>-sw.js en dev_<app>.webmanifest vanuit de productieversie.
# Gebruik: scripts/make-dev.sh tafelheld   (overschrijft de bestaande dev-versie!)
set -euo pipefail
app="$1"; cd "$(dirname "$0")/../public"
Name="$(tr '[:lower:]' '[:upper:]' <<<"${app:0:1}")${app:1}"

# Dev-only blok: voortgang éénmalig kopiëren uit productie, titel + DEV-label.
# Staat op één regel tussen <!--DEV--> en <!--/DEV--> zodat promote.sh hem kan weghalen.
devblock="<!--DEV--><script>try{if(!localStorage.getItem('dev_${app}.v1')&&localStorage.getItem('${app}.v1'))localStorage.setItem('dev_${app}.v1',localStorage.getItem('${app}.v1'))}catch(e){}addEventListener('DOMContentLoaded',function(){document.title+=' (dev)';var b=document.createElement('div');b.textContent='DEV';b.style.cssText='position:fixed;top:calc(env(safe-area-inset-top,0px) + 6px);right:6px;z-index:99999;background:#e11d48;color:#fff;font:700 12px/1 system-ui,sans-serif;padding:5px 8px;border-radius:6px;pointer-events:none;letter-spacing:.05em';document.body.appendChild(b)})</script><!--/DEV-->"

sed -e "s#href=\"/${app}.webmanifest\"#href=\"/dev_${app}.webmanifest\"#" \
    -e "s#'/${app}-sw.js',{scope:'/${app}'}#'/dev_${app}-sw.js',{scope:'/dev_${app}'}#" \
    -e "s#const KEY='${app}.v1'#const KEY='dev_${app}.v1'#" \
    -e "s#<meta name=\"apple-mobile-web-app-title\" content=\"${Name}\">#<meta name=\"apple-mobile-web-app-title\" content=\"${Name} dev\">#" \
    "${app}.html" | DEVBLOCK="$devblock" awk '{print} /apple-mobile-web-app-title/ && !done {print ENVIRON["DEVBLOCK"]; done=1}' > "dev_${app}.html"

# Service worker: eigen cache, eigen paden; ruimt alleen de eigen caches op.
sed -e "s#const VERSION = '${app}-v\([0-9]*\)'#const VERSION = 'dev_${app}-v\1'#" \
    -e "s#'/${app}\.#'/dev_${app}.#g" \
    -e "s#url.pathname === '/${app}'#url.pathname === '/dev_${app}'#" \
    -e "s#keys.filter(k => k !== VERSION)#keys.filter(k => k.startsWith('dev_${app}-') \&\& k !== VERSION)#" \
    "${app}-sw.js" > "dev_${app}-sw.js"

sed -e "s#\"/${app}#\"/dev_${app}#g" \
    -e "s#\"name\": \"${Name}\"#\"name\": \"${Name} (dev)\"#" \
    -e "s#\"short_name\": \"${Name}\"#\"short_name\": \"${Name} dev\"#" \
    "${app}.webmanifest" > "dev_${app}.webmanifest"

# Controle: alle vervangingen moeten gelukt zijn
for pat in "/dev_${app}.webmanifest" "/dev_${app}-sw.js" "dev_${app}.v1" "<!--DEV-->"; do
  grep -q -- "$pat" "dev_${app}.html" || { echo "FOUT: '$pat' niet gevonden in dev_${app}.html" >&2; exit 1; }
done
grep -q "VERSION = 'dev_${app}-v" "dev_${app}-sw.js" || { echo "FOUT: VERSION niet aangepast" >&2; exit 1; }
grep -q "startsWith('dev_${app}-')" "dev_${app}-sw.js" || { echo "FOUT: cache-opruiming niet aangepast" >&2; exit 1; }
echo "dev_${app} aangemaakt."
