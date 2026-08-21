#!/usr/bin/env bash
#
# primeui-base — Docker imajını derler, çalıştırır ve DEPLOY.md'deki doğrulama
# listesinin tamamını uygular. Çıktıyı olduğu gibi paylaşabilirsiniz.
#
# Kullanım — Windows'ta Git Bash ile:
#   bash scripts/verify-docker.sh
#   PORT=9090 bash scripts/verify-docker.sh
#
# PowerShell'den (bash komutu WSL'e dusebilir, tam yol guvenli):
#   C:\"Program Files"\Git\bin\bash.exe scripts/verify-docker.sh
#
# Lisans anahtarı sırasıyla şuralardan aranır:
#   1) VITE_PRIMEVUE_LICENSE ortam değişkeni
#   2) proje kökündeki .env dosyası
#
set -uo pipefail

# Git Bash / MSYS altinda: MSYS "/" ile baslayan argumanlari Windows yoluna
# cevirir ve "docker exec ... ls /usr/share/nginx/html" cagrisi bozulur.
# Bu iki degisken donusumu kapatir. WSL veya Linux'ta zararsizdir.
case "$(uname -s 2>/dev/null)" in
  MINGW* | MSYS* | CYGWIN*)
    export MSYS_NO_PATHCONV=1
    export MSYS2_ARG_CONV_EXCL='*'
    ;;
esac

PORT="${PORT:-8099}"
IMAGE="primeui-base:verify"
NAME="primeui-base-verify"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pass=0
fail=0

c_ok=$'\033[32m'
c_no=$'\033[31m'
c_dim=$'\033[2m'
c_off=$'\033[0m'

say() { printf '\n%s== %s ==%s\n' "$c_dim" "$1" "$c_off"; }

check() { # check <ad> <beklenen> <gercek>
  if [[ "$3" == *"$2"* ]]; then
    printf '  %sPASS%s  %-34s %s\n' "$c_ok" "$c_off" "$1" "$3"
    pass=$((pass + 1))
  else
    printf '  %sFAIL%s  %-34s beklenen: %-28s alinan: %s\n' "$c_no" "$c_off" "$1" "$2" "$3"
    fail=$((fail + 1))
  fi
}

cleanup() {
  docker rm -f "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

cd "$ROOT" || exit 1

# --------------------------------------------------------------------------
say "0. Ön koşullar"

if ! docker info >/dev/null 2>&1; then
  echo "  HATA: Docker daemon'a erişilemiyor. Docker Desktop çalışıyor mu?"
  exit 1
fi
printf '  docker            : %s\n' "$(docker version --format '{{.Server.Version}}' 2>/dev/null)"

if [[ ! -f package-lock.json ]]; then
  echo "  HATA: package-lock.json yok. 'npm install' çalıştırın."
  exit 1
fi

# npm ci kilidi katı uygular; uyumsuzsa imaj derlemesi ortada patlar.
# Burada önceden yakalayıp net mesaj veriyoruz.
#
# DİKKAT: npm "var ama çalışmıyor" olabilir. WSL, Windows'un PATH'ini miras
# aldığı için `npm` bazen /mnt/c altındaki Windows shim'ine (Volta, nvm-windows)
# düşer ve WSL içinde hata verir. Bu durumu kilit uyumsuzluğuyla karıştırmamak
# için önce npm'in gerçekten çalıştığını sınıyoruz.
npm_check=skip
if command -v npm >/dev/null 2>&1; then
  if npm_version="$(npm --version 2>&1)"; then
    npm_check=run
  else
    echo "  UYARI: npm bulundu ama çalışmıyor — kilit kontrolü atlanıyor."
    printf '         npm yolu  : %s\n' "$(command -v npm)"
    printf '         npm hatası: %s\n' "$(printf '%s' "$npm_version" | head -2 | paste -sd' ' -)"
    case "$(command -v npm)" in
      /mnt/*) echo "         Sebep: bu, WSL içinden çağrılan bir WINDOWS npm'i." ;;
    esac
    echo "         Derlemeyi engellemez; kilit zaten imaj içinde uygulanacak."
  fi
fi

if [[ "$npm_check" == run ]]; then
  if npm_out="$(npm ci --dry-run 2>&1)"; then
    printf '  lockfile          : package.json ile uyumlu (npm %s)\n' "$npm_version"
  else
    echo "  HATA: 'npm ci' bu projede çalışmıyor. İlk satırlar:"
    printf '%s\n' "$npm_out" | head -6 | sed 's/^/        /'
    echo
    echo "        En sık sebep: package-lock.json ile package.json uyumsuz."
    echo "        Çözüm: npm install && git add package-lock.json"
    exit 1
  fi
else
  echo "  lockfile          : kontrol atlandı (npm yok veya çalışmıyor)"
fi

# WSL + Docker Desktop tuzagi: ~/.docker/config.json icinde
# "credsStore": "desktop.exe" varsa, Linux tarafindaki docker bir WINDOWS
# ikilisini exec etmeye kalkar ve "exec format error" verir. Interop bozuksa
# (ornegin systemd katmanlari yuzunden) derleme ilk imaj cozumlemesinde patlar.
if [[ "$(uname -r 2>/dev/null)" == *microsoft* ]] &&
  [[ -f "$HOME/.docker/config.json" ]] &&
  grep -q 'desktop\.exe' "$HOME/.docker/config.json" 2>/dev/null; then
  echo "  UYARI: ~/.docker/config.json icinde credsStore=desktop.exe var."
  echo "         WSL icinde bu, 'docker-credential-desktop.exe: exec format error'"
  echo "         hatasina yol acar ve imaj cekilemez. Duzeltme:"
  echo "           cp ~/.docker/config.json ~/.docker/config.json.bak"
  echo "           printf '{}\\n' > ~/.docker/config.json"
  echo "         (Yalnizca public imaj cekiliyor, kimlik bilgisi gerekmiyor.)"
fi

LICENSE="${VITE_PRIMEVUE_LICENSE:-}"
if [[ -z "$LICENSE" && -f .env ]]; then
  LICENSE="$(grep -E '^VITE_PRIMEVUE_LICENSE=' .env | head -1 | cut -d= -f2- | tr -d '\r')"
  # .env degeri tirnak icinde yazilmis olabilir; bastaki/sondaki tirnaklari at
  LICENSE="${LICENSE%\"}"
  LICENSE="${LICENSE#\"}"
  LICENSE="${LICENSE%\'}"
  LICENSE="${LICENSE#\'}"
fi
if [[ -z "$LICENSE" ]]; then
  echo "  HATA: Lisans anahtarı bulunamadı (ortam değişkeni veya .env)."
  exit 1
fi
printf '  lisans            : bulundu (%s karakter, %s...)\n' "${#LICENSE}" "${LICENSE:0:12}"

# --------------------------------------------------------------------------
say "1. Derleme"

if ! docker build --build-arg VITE_PRIMEVUE_LICENSE="$LICENSE" -t "$IMAGE" . ; then
  echo
  echo "  DERLEME BASARISIZ. Sik sebepler:"
  echo "   - 'docker-credential-desktop.exe: exec format error'"
  echo "         -> WSL icinde: printf '{}\\n' > ~/.docker/config.json"
  echo "   - 'docker/dockerfile:1' cozulemedi  -> Dockerfile'in 1. satirini silin"
  echo "   - 'Forbidden' / imaj cekilemiyor    -> proxy/registry erisimi"
  echo "   - 'npm ci ... not in sync'          -> npm install, kilidi commit edin"
  exit 1
fi

IMAGE_SIZE="$(docker image inspect "$IMAGE" --format '{{.Size}}' 2>/dev/null)"
printf '  imaj boyutu       : %s MB\n' "$((IMAGE_SIZE / 1024 / 1024))"

# --------------------------------------------------------------------------
say "2. Konteyner"

cleanup
docker run -d --name "$NAME" -p "$PORT:80" "$IMAGE" >/dev/null

# HEALTHCHECK'in healthy'ye gecmesini bekle (en fazla 60 sn)
state=""
for _ in $(seq 1 30); do
  state="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}(healthcheck yok){{end}}' "$NAME" 2>/dev/null)"
  [[ "$state" == "healthy" || "$state" == "(healthcheck yok)" ]] && break
  sleep 2
done
check "HEALTHCHECK durumu" "healthy" "$state"

# --------------------------------------------------------------------------
say "3. HTTP kontrolleri"

BASE="http://127.0.0.1:$PORT"

# Test edilecek hash'li varlığın adını imajın içinden al
ASSET="$(docker exec "$NAME" sh -c 'ls /usr/share/nginx/html/assets/*.js 2>/dev/null | head -1 | xargs -r basename')"
printf '  %shash li varlik: %s%s\n' "$c_dim" "${ASSET:-BULUNAMADI}" "$c_off"

hdr() { curl -s -o /dev/null -D - "$1" 2>/dev/null | tr -d '\r'; }
status() { curl -s -o /dev/null -w '%{http_code}' "$1" 2>/dev/null; }
cc() { hdr "$1" | grep -i '^cache-control:' | sed 's/^[^:]*: //' | paste -sd'~' -; }
cc_count() { hdr "$1" | grep -ic '^cache-control:'; }
xfo() { hdr "$1" | grep -ic '^x-frame-options:'; }

check "healthz durumu"        "200" "$(status "$BASE/healthz")"
check "healthz govdesi"       "ok"  "$(curl -s "$BASE/healthz" | tr -d '\n')"
check "ana sayfa durumu"      "200" "$(status "$BASE/")"
check "ana sayfa Cache-Ctrl"  "no-cache" "$(cc "$BASE/")"
check "ana sayfa CC adedi"    "1"   "$(cc_count "$BASE/")"
check "guvenlik basligi (/)"  "1"   "$(xfo "$BASE/")"

if [[ -n "$ASSET" ]]; then
  check "varlik durumu"       "200"       "$(status "$BASE/assets/$ASSET")"
  check "varlik Cache-Ctrl"   "immutable" "$(cc "$BASE/assets/$ASSET")"
  check "varlik CC adedi"     "1"         "$(cc_count "$BASE/assets/$ASSET")"
  check "varlik gzip"         "gzip"      "$(curl -s -o /dev/null -D - -H 'Accept-Encoding: gzip' "$BASE/assets/$ASSET" | tr -d '\r' | grep -i '^content-encoding:' | sed 's/^[^:]*: //')"
fi

check "favicon.ico durumu"    "200"          "$(status "$BASE/favicon.ico")"
check "favicon Cache-Ctrl"    "max-age=86400" "$(cc "$BASE/favicon.ico")"
check "favicon svg durumu"    "200"          "$(status "$BASE/primeui-favicon-dark.svg")"
check "apple-touch durumu"    "200"          "$(status "$BASE/apple-touch-icon.png")"

# SPA fallback: olmayan bir yol 404 degil, index.html donmeli
check "SPA fallback durumu"   "200"       "$(status "$BASE/ayarlar/profil")"
check "SPA fallback govdesi"  "<!doctype" "$(curl -s "$BASE/ayarlar/profil" | head -c 60 | tr 'A-Z' 'a-z' | tr -d '\n')"

# Olmayan varlik 404 donmeli ve immutable onbellek ALMAMALI
check "olmayan varlik durumu" "404" "$(status "$BASE/assets/yok-$RANDOM.js")"
check "olmayan varlik CC yok" "0"   "$(cc_count "$BASE/assets/yok-$RANDOM.js")"

# --------------------------------------------------------------------------
say "4. Lisans anahtari pakete gomuldu mu"

EMBEDDED="$(docker exec "$NAME" sh -c "grep -l -F '${LICENSE:0:24}' /usr/share/nginx/html/assets/*.js 2>/dev/null | wc -l" | tr -d ' \r')"
check "anahtar bundle icinde" "1" "$EMBEDDED"

# --------------------------------------------------------------------------
say "Sonuc"

printf '  gecen: %s   basarisiz: %s\n' "$pass" "$fail"
if [[ "$fail" -gt 0 ]]; then
  echo
  echo "  Konteyner loglarinin son 20 satiri:"
  docker logs --tail 20 "$NAME" 2>&1 | sed 's/^/    /'
  exit 1
fi
echo "  Tum kontroller gecti."
