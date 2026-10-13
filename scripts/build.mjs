// Bouwt de site voor Cloudflare: kopieert public/ naar dist/ en zet in elke app met __BUILD__
// een versie (korte hash van de app + service worker) en de datum van de laatste commit.
// dist/version.json bevat per app de nieuwste versie; de apps vergelijken die met hun eigen versie.
// Wordt automatisch uitgevoerd door `wrangler deploy` (zie "build" in wrangler.jsonc).
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execSync } from 'node:child_process';

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const src = path.join(root, 'public'), out = path.join(root, 'dist');
fs.rmSync(out, { recursive: true, force: true });
fs.cpSync(src, out, { recursive: true });

const gitDate = files => {
  try { return execSync(`git log -1 --format=%cI -- ${files.join(' ')}`, { cwd: root, stdio: ['ignore', 'pipe', 'ignore'] }).toString().trim(); }
  catch { return ''; }
};

const versions = {};
for (const f of fs.readdirSync(out).filter(f => f.endsWith('.html'))) {
  const name = f.slice(0, -5), file = path.join(out, f);
  const html = fs.readFileSync(file, 'utf8');
  if (!html.includes('__BUILD__')) continue;
  const swFile = path.join(out, `${name}-sw.js`);
  const sw = fs.existsSync(swFile) ? fs.readFileSync(swFile, 'utf8') : '';
  const v = crypto.createHash('sha256').update(html).update(sw).digest('hex').slice(0, 8);
  const date = gitDate([`public/${f}`, `public/${name}-sw.js`]) || gitDate([]) || new Date().toISOString();
  fs.writeFileSync(file, html.replaceAll('__BUILD__', `${v}|${date}`));
  versions[name] = { v, date };
}
fs.writeFileSync(path.join(out, 'version.json'), JSON.stringify(versions, null, 1));
console.log('build:', Object.entries(versions).map(([k, x]) => `${k} ${x.v}`).join(', ') || 'geen apps met versie');
