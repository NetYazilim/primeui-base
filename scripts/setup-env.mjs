// .env dosyasini .env.example'dan olusturur (varsa dokunmaz).
// Calis: npm run setup:env
import { copyFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const target = join(root, '.env');
const source = join(root, '.env.example');

if (existsSync(target)) {
  console.log('.env zaten var, dokunulmadi.');
  process.exit(0);
}

if (!existsSync(source)) {
  console.error('.env.example bulunamadi.');
  process.exit(1);
}

copyFileSync(source, target);
console.log('.env olusturuldu. VITE_PRIMEVUE_LICENSE degerini doldurun.');
