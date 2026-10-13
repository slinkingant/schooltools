#!/usr/bin/env bash
# Zet de geteste dev-versie live: dev_<app>.html -> <app>.html en dev_<app>-sw.js -> <app>-sw.js.
# Het manifest wordt niet overgezet (naam en adres verschillen); pas dat zo nodig met de hand aan.
# Gebruik: scripts/promote.sh tafelheld
set -euo pipefail
app="$1"; cd "$(dirname "$0")/../public"
Name="$(tr '[:lower:]' '[:upper:]' <<<"${app:0:1}")${app:1}"
sed -e '/<!--DEV-->.*<!--\/DEV-->/d' -e "s#dev_${app}#${app}#g" -e "s#content=\"${Name} dev\"#content=\"${Name}\"#" "dev_${app}.html" > "${app}.html"
sed -e "s#dev_${app}#${app}#g" "dev_${app}-sw.js" > "${app}-sw.js"
if grep -q "dev_\|<!--DEV-->\|${Name} dev" "${app}.html" "${app}-sw.js"; then echo "FOUT: er staat nog dev-code in de productieversie" >&2; exit 1; fi
echo "${app} bijgewerkt vanuit dev_${app}. Bekijk 'git diff' en commit."
