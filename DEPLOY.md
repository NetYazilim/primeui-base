# Deploy — Docker konteyner

`primeui-base` derlendiğinde ortaya **statik dosyalar** çıkar (HTML, JS, CSS, ikonlar).
Node.js sunucusu gerekmez. Bu doküman iki aşamalı bir Docker imajı ile nginx üzerinden
sunumu anlatır. Uygulama alan adının **kökünde** çalışacak varsayımıyla yazıldı
(`https://app.ornek.com/`); alt yol için sondaki _Alt yolda çalıştırmak_ bölümüne bakın.

Genel proje dokümanı için [README.md](./README.md).

---

## İçindekiler

- [Önce anlaşılması gereken tek şey](#önce-anlaşılması-gereken-tek-şey)
- [Dosyalar](#dosyalar)
- [Derleme ve çalıştırma](#derleme-ve-çalıştırma)
- [Ön hazırlık: `package-lock.json`'ı güncelleyin](#ön-hazırlık-package-lockjsonı-güncelleyin)
- [nginx yapılandırmasında beş önemli nokta](#nginx-yapılandırmasında-beş-önemli-nokta)
  - [Root olmayan kullanıcı](#root-olmayan-kullanıcı)
- [CI ile derleme (GitHub Actions örneği)](#ci-ile-derleme-github-actions-örneği)
- [Doğrulama listesi](#doğrulama-listesi)
  - [Tek komutla tüm liste](#tek-komutla-tüm-liste)
  - [Ne zaman çalıştırmalı](#ne-zaman-çalıştırmalı)
  - [Kör nokta: `public/` altındaki uzantılar](#kör-nokta-public-altındaki-uzantılar)
- [Sorun giderme](#sorun-giderme)
- [Alt yolda çalıştırmak](#alt-yolda-çalıştırmak)
- [Notlar](#notlar)

---

## Önce anlaşılması gereken tek şey

**Lisans anahtarı derleme zamanında gömülür, çalışma zamanında okunmaz.**

Vite, `VITE_` önekli değişkenleri derleme sırasında kaynak koda **metin olarak yazar**.
`import.meta.env.VITE_PRIMEVUE_LICENSE` çalışan bir kodda ortam değişkeni aramaz; o
noktada anahtar zaten JavaScript paketinin içindedir.

Pratik sonuçları:

- Konteyneri `-e VITE_PRIMEVUE_LICENSE=...` ile çalıştırmak **hiçbir işe yaramaz**.
  Anahtar `--build-arg` olarak verilmelidir.
- Anahtar değiştiğinde imajı **yeniden derlemek** gerekir; konteyneri yeniden başlatmak
  yetmez.
- Aynı imaj her ortamda aynı anahtarı taşır. Ortam başına farklı anahtar kullanacaksanız
  ortam başına ayrı imaj derlenir.

> Doğrulama: `VITE_PRIMEVUE_LICENSE=SENTINEL_ABC123 npx vite build` çalıştırıp
> `grep SENTINEL_ABC123 dist/assets/*.js` dediğinizde 1 eşleşme çıkar. Değişken
> verilmediğinde 0 çıkar.

Bu bir güvenlik zafiyeti değil — PrimeVue'nun lisans doğrulaması istemci tarafında
çalışır ve anahtarın istemciye ulaşması tasarım gereğidir (bkz. README, _Lisans
yapılandırması_). Ama anahtarın **gizli bir sır olmadığını** bilerek davranın: imaja,
`docker history` çıktısına ve tarayıcıya inen paketin içine girer.

---

## Dosyalar

| Dosya                          | Rolü                                                       |
| ------------------------------ | ---------------------------------------------------------- |
| `Dockerfile`                   | İki aşamalı derleme: node ile build, nginx ile sun         |
| `docker/nginx.conf`            | SPA fallback, önbellek başlıkları, gzip, /healthz          |
| `docker/security-headers.conf` | Her `location` bloğunun include ettiği güvenlik başlıkları |
| `.dockerignore`                | `node_modules`, `.env`, `.git` derleme bağlamı dışı        |
| `docker-compose.yml`           | Yerel deneme için kısayol                                  |

---

## Derleme ve çalıştırma

```sh
# Derle — anahtar build-arg olarak verilir
docker build --build-arg VITE_PRIMEVUE_LICENSE="$VITE_PRIMEVUE_LICENSE" -t primeui-base:1.0.0 .

# Çalıştır
docker run --rm -p 8080:80 primeui-base:1.0.0

# http://localhost:8080 açılır
```

Compose ile:

```sh
# .env dosyasındaki VITE_PRIMEVUE_LICENSE otomatik okunur
docker compose up --build
```

`docker-compose.yml` içinde `${VITE_PRIMEVUE_LICENSE:?...}` yazımı, değişken tanımsızsa
derlemeyi sessizce lisanssız tamamlamak yerine **hata verdirir**. Lisanssız imaj üretmenin
en sinsi hâli budur: derleme başarılı görünür, hata ancak tarayıcıda kırmızı
"Invalid PrimeUI License" kutusu olarak ortaya çıkar.

---

## Ön hazırlık: `package-lock.json`'ı güncelleyin

`Dockerfile` içinde `npm ci` kullanılır — `npm install` değil. `npm ci` kilidi
`package.json` ile **tam uyumlu** olmadığında derlemeyi hatayla keser:

```
npm error `npm ci` can only install packages when your package.json and
npm error package-lock.json are in sync.
```

Bu şablonun kilidi, ESLint / Prettier / Vitest eklendikten sonra **yenilenmediyse**
eskidir. Bir kez düzeltin ve kilidi commit edin:

```sh
npm install          # kilidi package.json ile eşitler
git add package-lock.json
git commit -m "chore: refresh lockfile"
```

`npm ci`'nin tercih edilme sebebi tam olarak bu katılık: kilidi birebir uygular, yani
imaj bugün de altı ay sonra da aynı bağımlılık ağacıyla derlenir.

---

## nginx yapılandırmasında beş önemli nokta

**SPA fallback.** `try_files $uri $uri/ /index.html;` olmadan uygulamanın kökü çalışır
ama `/ayarlar` gibi bir adrese doğrudan girip yenilediğinizde nginx 404 verir. Router
eklediğinizde bu kural hayat kurtarır; şimdi tek sayfa olsa da yerinde durması iyidir.

**`index.html` önbelleklenmemeli.** İçinde hash'li varlık adları (`index-BgKdb_GZ.js`)
geçtiği için önbelleğe alınırsa kullanıcı yeni sürümü değil, artık var olmayan eski
dosyaları isteyen eski HTML'i görür. Sonuç: boş sayfa. `Cache-Control: no-cache`.

**Hash'li ve hash'siz varlıklar farklı davranır.** `/assets/` altındaki dosyalar içerik
hash'i taşır, `immutable` ile bir yıl önbelleklenebilir. Ama `public/` altındaki
`favicon.ico`, `primeui-favicon-*.svg`, `apple-touch-icon.png` **hash almaz** — bunlara
`immutable` verirseniz ikonu değiştirdiğinizde kullanıcılar aylarca eskisini görür.
Yapılandırma bu ikisini ayrı `location` bloklarında ele alır (1 yıl / 1 gün).

**`add_header` kalıtımı yoktur — EZER.** nginx'te bir `location` bloğunda tek bir
`add_header` varsa, `server` seviyesindeki **tüm** `add_header` direktifleri o blok için
geçersiz olur. İlk yazdığım yapılandırmada güvenlik başlıkları `server` seviyesindeydi ve
her `location` bir önbellek başlığı eklediği için **hiçbir yanıtta görünmüyorlardı**.
Çözüm: başlıklar `docker/security-headers.conf` dosyasına alındı ve her `location` bu
dosyayı `include` ediyor. Yeni bir `location` eklerseniz include satırını da eklemeyi
unutmayın.

**Önbellek başlığında `always` kullanmayın.** `add_header ... always` başlığı hata
yanıtlarına da ekler. Önbellek başlığı için bu istenmez: `/assets/olmayan.js` isteği 404
dönerken bir yıllık `immutable` başlık alır ve tarayıcı/CDN "bu dosya yok" bilgisini bir
yıl saklayabilir. `always` yalnızca güvenlik başlıklarında var; `Cache-Control`
direktiflerinde kasıtlı olarak yok. `expires` direktifi de kaldırıldı — `add_header` ile
birlikte kullanıldığında **iki tane** `Cache-Control` başlığı üretiyordu.

### Root olmayan kullanıcı

Kurumsal politikanız konteynerin root ile başlamasını yasaklıyorsa resmî imaj yerine
`nginxinc/nginx-unprivileged:alpine` kullanın; 80 yerine **8080** dinler:

```dockerfile
FROM nginxinc/nginx-unprivileged:alpine AS runtime
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
```

`nginx.conf` içindeki `listen 80;` satırını `listen 8080;` yapmayı ve `HEALTHCHECK`
adresini güncellemeyi unutmayın.

---

## CI ile derleme (GitHub Actions örneği)

```yaml
name: build-and-push

on:
  push:
    tags: ['v*']

jobs:
  docker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version-file: .nvmrc
          cache: npm

      # Kalite kapıları imaj derlemeden önce çalışsın
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm test

      - uses: docker/setup-buildx-action@v3

      - uses: docker/build-push-action@v6
        with:
          context: .
          push: false # kendi kayıt defterinize göre değiştirin
          tags: primeui-base:${{ github.ref_name }}
          build-args: |
            VITE_PRIMEVUE_LICENSE=${{ secrets.PRIMEVUE_LICENSE }}
```

Anahtarı repository secret olarak tutun (`PRIMEVUE_LICENSE`). Secret'lar iş akışı
günlüklerinde maskelenir; ancak yukarıda anlatıldığı gibi üretilen **paketin içinde
görünür** — bu beklenen davranıştır.

---

## Doğrulama listesi

Aşağıdaki tablo **gerçekten ölçülmüş** sonuçlardır: `docker/nginx.conf` bu şablonun
derlenmiş `dist/` çıktısıyla nginx 1.24 üzerinde çalıştırılıp `curl` ile denetlendi.
Kendi dağıtımınızda aynı değerleri görmelisiniz.

| Kontrol        | İstek                       | Durum | `Cache-Control`                       | Güvenlik başlıkları |
| -------------- | --------------------------- | ----- | ------------------------------------- | ------------------- |
| Sağlık         | `/healthz`                  | 200   | `no-store`                            | var                 |
| Ana sayfa      | `/`                         | 200   | `no-cache, must-revalidate`           | var                 |
| Hash'li varlık | `/assets/index-<hash>.js`   | 200   | `public, max-age=31536000, immutable` | var                 |
| Favicon (.ico) | `/favicon.ico`              | 200   | `public, max-age=86400`               | var                 |
| Favicon (.svg) | `/primeui-favicon-dark.svg` | 200   | `public, max-age=86400`               | var                 |
| SPA fallback   | `/ayarlar/profil`           | 200   | `no-cache, must-revalidate`           | var                 |
| Olmayan varlık | `/assets/yok.js`            | 404   | **yok** (bilinçli)                    | var                 |

Ek olarak doğrulananlar:

- `/healthz` gövdesi `ok`
- `Accept-Encoding: gzip` ile JS paketi gzip'lenerek dönüyor
- SPA fallback gövdesi gerçekten `index.html` (`<!doctype html>` ile başlıyor)
- Her yanıtta `Cache-Control` **tam olarak bir** kez var (çift başlık yok)
- Lisans anahtarı derlenmiş pakette gömülü (`grep` ile 1 eşleşme)
- `nginx -t` sözdizimi denetimi başarılı

### Tek komutla tüm liste

`scripts/verify-docker.sh` yukarıdaki tablonun tamamını otomatik uygular: ön koşulları
denetler (daemon, kilit dosyası, lisans anahtarı, `credsStore` tuzağı), imajı derler,
konteyneri kaldırır, `HEALTHCHECK`'in `healthy`'ye geçmesini bekler, 20 kontrolü yapar,
konteyneri temizler ve `geçen / başarısız` özeti basar. Başarısız kontrol varsa konteyner
loglarının son 20 satırını da ekler ve sıfırdan farklı bir kodla çıkar — yani CI adımı
olarak da kullanılabilir.

Windows'ta **Git Bash** ile çalıştırılır. PowerShell'den tam yolla çağırmak en güvenlisi,
çünkü `bash` komutu `C:\Windows\System32\bash.exe` üzerinden WSL'e düşebilir:

```powershell
C:\"Program Files"\Git\bin\bash.exe scripts/verify-docker.sh
```

Git Bash penceresinin içinden:

```sh
cd /c/Proje/primeui-base
bash scripts/verify-docker.sh
PORT=9090 bash scripts/verify-docker.sh   # port çakışırsa
```

Git Bash tercih edilmesinin sebebi: Windows `docker.exe` daemon'a named pipe ile bağlanır,
`npm` doğal ortamında çalışır, Docker Desktop'ta **WSL integration ayarına gerek kalmaz.**
WSL içinden çalıştırmak ek engeller getirir — `~/.docker/config.json` içindeki
`credsStore: desktop.exe` yüzünden `docker-credential-desktop.exe: exec format error`
hatası ve dağıtım başına WSL integration anahtarı. Gerekmedikçe girmeyin.

Lisans anahtarını `VITE_PRIMEVUE_LICENSE` ortam değişkeninden, yoksa `.env` dosyasından
alır. Derleme başarısız olursa en sık sebepleri çözüm önerisiyle yazdırır.

### Ne zaman çalıştırmalı

Kısa kural: **uygulama kodunu değiştirdiğinizde değil, uygulamanın nasıl sunulduğunu
değiştirdiğinizde.** Script Vue kodunuz hakkında `npm test` / `npm run lint` /
`npm run type-check`'in söylemediği hiçbir şey söylemez. Onun alanı sunum katmanı: nginx
kuralları, önbellek başlıkları, SPA fallback, lisans anahtarının pakete gömülmesi.

| Durum                                                                                  | Neden                                                                                                                                                                       |
| -------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Dockerfile`, `docker/nginx.conf`, `security-headers.conf`, `.dockerignore` düzenlendi | Script tam olarak bunları test ediyor. Buradaki her değişiklik doğrulanmalı.                                                                                                |
| Dağıtım öncesi                                                                         | İmajı yayınlamadan atılacak son kapı.                                                                                                                                       |
| Lisans anahtarı değişti / yenilendi                                                    | Yeni anahtar gerçekten pakete gömüldü mü?                                                                                                                                   |
| `vite.config.ts`'te build ayarı değişti                                                | `base`, `build.assetsDir`, çıktı dizini… nginx'in `/assets/` bloğu Vite'ın çıktı düzenine bağlı. Dizin adını değiştirirseniz `immutable` kuralı sessizce eşleşmeyi bırakır. |
| Tailwind eklendi                                                                       | CSS katmanları ve çıktı dosya adları değişiyor.                                                                                                                             |
| `vue-router` eklendi                                                                   | SPA fallback o an teorik olmaktan çıkıp hayati hâle geliyor.                                                                                                                |
| `public/` altına yeni dosya eklendi                                                    | Önbellek politikası uzantıya göre seçiliyor (aşağıdaki kör noktaya bakın).                                                                                                  |
| Temel imaj sürümü yükseltildi                                                          | `node:24-alpine` veya `nginx:alpine` güncellemesi.                                                                                                                          |
| Yeni makine / yeni geliştirici / Docker Desktop yükseltmesi                            | Bir dakikalık ortam sağlık testi.                                                                                                                                           |
| CI adımı olarak                                                                        | Başarısızlıkta sıfırdan farklı kod döner.                                                                                                                                   |

**Gerekmediği durum:** gündelik geliştirme. Bileşen yazarken, stil düzenlerken, test
eklerken `npm run dev` ve `npm test` yeterli. Her commit'te bu script'i çalıştırmak bir
dakikayı boşa harcamak olur — çünkü değişen şey script'in baktığı katman değil.

### Kör nokta: `public/` altındaki uzantılar

`public/` dosyalarının önbellek kuralı uzantıya göre seçiliyor:

```nginx
location ~* \.(ico|svg|png|webmanifest|txt)$ { ... 1 gün ... }
```

Bu listede olmayan bir uzantı `location /` bloğuna düşer ve `no-cache` alır. Örneğin
`public/fonts/inter.woff2` koyarsanız fontlar **her istekte yeniden indirilir**. Script
bunu yakalamaz, çünkü o dosya için bir kontrol yok. Aynısı `sitemap.xml`,
`manifest.json`, `.avif`, `.webp` için de geçerli.

Böyle bir dosya eklerseniz iki şey yapın:

1. Uzantıyı `docker/nginx.conf` içindeki regex'e ekleyin (fontlar için `immutable` bile
   uygun olabilir — dosya adı değişmiyorsa 1 gün daha güvenli).
2. `scripts/verify-docker.sh` içine o dosya için bir `check` satırı ekleyin, ki bir
   dahaki sefere kör nokta olmasın.

Elle hızlı kontrol için:

```sh
curl -i localhost:8080/healthz
curl -I localhost:8080/
curl -I localhost:8080/olmayan-yol          # 200 + HTML dönmeli
docker run --rm primeui-base:1.0.0 \
  sh -c 'grep -c eyJ /usr/share/nginx/html/assets/*.js'   # 1 dönmeli
```

Son komut, lisanssız imajı **dağıtmadan önce** yakalamanın en hızlı yolu.

---

## Sorun giderme

| Belirti                                                               | Sebep                                                                                                                                                  |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `npm ci can only install packages when ... in sync`                   | `package-lock.json` eski. Yerelde `npm install` çalıştırıp kilidi commit edin.                                                                         |
| Tarayıcıda kırmızı "Invalid PrimeUI License"                          | `--build-arg` verilmemiş veya boş. `-e` ile vermek işe yaramaz — imajı yeniden derleyin.                                                               |
| Alt sayfada yenilerken 404                                            | `try_files ... /index.html` kuralı yok ya da başka bir `location` bloğu önce eşleşiyor.                                                                |
| Yeni sürüm yayınlandı, kullanıcılar eskisini görüyor                  | `index.html` önbelleklenmiş. `Cache-Control: no-cache` başlığını doğrulayın.                                                                           |
| Boş beyaz sayfa, konsolda 404 chunk hataları                          | Eski `index.html` + yeni varlıklar. Aynı sebep: HTML önbelleği.                                                                                        |
| İkon değiştirdim ama güncellenmiyor                                   | `public/` dosyalarına `immutable` verilmiş. 1 günlük bloğun eşleştiğini kontrol edin.                                                                  |
| `docker build` çok yavaş                                              | `.dockerignore` içinde `node_modules` yok; yerel kurulum bağlama kopyalanıyor.                                                                         |
| `failed to resolve source metadata for docker.io/docker/dockerfile:1` | Ağ Docker Hub'a çıkamıyor. `Dockerfile`'ın ilk satırındaki `# syntax=docker/dockerfile:1` satırını silin; BuildKit'in gömülü frontend'i kullanılır.    |
| `Forbidden` / `failed to do request` — imaj çekilemiyor               | Kurumsal ağ registry'yi engelliyor. Temel imajları (`node:24-alpine`, `nginx:alpine`) iç registry'nize aynalayıp `FROM` satırlarını oraya yönlendirin. |
| Güvenlik başlıkları yanıtta görünmüyor                                | Yeni eklediğiniz `location` bloğunda `include .../security-headers.conf` satırı yok. nginx'te `add_header` kalıtımı ezer.                              |

---

## Alt yolda çalıştırmak

Uygulama `https://ornek.com/primeui/` gibi bir alt yolda duracaksa `vite.config.ts`
içine `base` eklemek gerekir:

```ts
export default defineConfig({
  base: '/primeui/',
  // ...
});
```

Bu ayar hem varlık yollarını hem `index.html` içindeki favicon bağlantılarını (`/favicon.ico`
→ `/primeui/favicon.ico`) düzeltir. `base`'i ortam değişkeninden okumak isterseniz
`defineConfig(({ mode }) => ({ base: process.env.VITE_BASE ?? '/' }))` biçimini kullanın
ve `Dockerfile`'a ikinci bir `ARG` ekleyin. nginx tarafında da `location /primeui/` bloğu
ve `try_files ... /primeui/index.html` gerekir.

---

## Notlar

- `nginx:alpine` etiketi hareketlidir. Üretimde `nginx:1.29-alpine` gibi sabit bir sürüme
  ya da digest'e sabitleyip yükseltmeyi bilinçli yapın. Aynısı `node:24-alpine` için de
  geçerli.
- Derlenen çıktı tamamen statiktir; Docker zorunlu değil. `dist/` klasörünü herhangi bir
  statik sunucuya (IIS, Apache, S3 + CDN, Vercel) koyabilirsiniz. Tek koşul aynıdır:
  SPA fallback ve `index.html`'in önbelleklenmemesi.
- **Neyin test edildiği, neyin edilmediği.** `docker/nginx.conf` gerçek nginx 1.24
  üzerinde bu şablonun `dist/` çıktısıyla çalıştırıldı ve _Doğrulama listesi_'ndeki tüm
  satırlar `curl` ile ölçüldü; bu süreçte üç kusur bulunup düzeltildi (çift
  `Cache-Control`, 404'lere `immutable`, kaybolan güvenlik başlıkları). Lisans anahtarının
  derleme zamanında gömülmesi de doğrulandı. `Dockerfile` BuildKit tarafından hatasız
  ayrıştırıldı (`docker build --check`). **Ancak imaj derlenip çalıştırılamadı**: doküman
  hazırlanan ortamın ağı container registry'lerine (Docker Hub, GCR, ECR, GHCR) kapalı
  olduğu için `node:24-alpine` ve `nginx:alpine` çekilemedi. Yani `npm ci` / `npm run
build` adımlarının imaj içinde çalıştığı ve `HEALTHCHECK`'in geçtiği ilk gerçek
  derlemede teyit edilmelidir.
