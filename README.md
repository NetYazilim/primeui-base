# primeui-base

Vue 3 + Vite + TypeScript üzerinde **PrimeVue 5** için hazır başlangıç şablonu.
Bu şablonda dört şey önceden yapılandırılmıştır:

1. **Auto-import** — PrimeVue bileşenleri ve direktifleri `import` yazmadan kullanılır.
2. **PrimeIcons auto-import** — ikonlar `Icon` sonekiyle (`<CheckIcon />`) import'suz kullanılır.
3. **Lisans (license key)** — PrimeUI ticari lisans anahtarı `.env` üzerinden okunur,
   tipi `env.d.ts` içinde tanımlıdır ve `.gitignore` ile repo dışında tutulur.
4. **Test** — Vitest + Vue Test Utils + jsdom kurulu. `vitest.config.ts`, `vite.config.ts`
   ile birleştiği için **auto-import testlerde de çalışır**: mount edilen bileşen içindeki
   `<Tag />` ve `<CheckIcon />` için ek bir şey yapmanız gerekmez. Testler bileşenin
   yanındaki `__tests__` klasöründe `*.spec.ts` olarak durur; `npm test` ile bir kez,
   `npm run test:unit` ile izleme modunda çalışır. Şablonla gelen 5 örnek test hem bir
   bileşeni (`VerifyLicence`) hem bir composable'ı (`useColorScheme`) kapsar.

Ayrıca ESLint + Prettier + EditorConfig kurulu, Node sürümü `.nvmrc` ile sabit, üç durumlu
(sistem / açık / koyu) bir tema değiştirici hazır.
CSS için ek bir framework (Tailwind vb.) **kullanılmaz**; düzen düz CSS ile kurulur ve
renkler PrimeVue tasarım token'larından okunur. Tailwind eklemek isterseniz
_Tailwind CSS eklemek_ bölümüne bakın.

Dağıtım (Docker + nginx) ayrı bir dokümanda: **[DEPLOY.md](./DEPLOY.md)**.

---

## İçindekiler

- [Teknoloji yığını](#teknoloji-yığını)
- [Kurulum](#kurulum)
- [Komutlar](#komutlar)
- [Bu şablondan yeni proje başlatmak](#bu-şablondan-yeni-proje-başlatmak)
- [1. Lisans yapılandırması](#1-lisans-yapılandırması)
- [2. Auto-import yapılandırması](#2-auto-import-yapılandırması)
  - [PrimeVue bileşenleri ve direktifleri](#primevue-bileşenleri-ve-direktifleri)
  - [PrimeIcons — `Icon` sonekli auto-import](#primeicons--icon-sonekli-auto-import)
  - [`components.d.ts`](#componentsdts)
  - [`src/components` altındaki kendi bileşenleriniz](#srccomponents-altındaki-kendi-bileşenleriniz)
- [3. Tema ve stil](#3-tema-ve-stil)
  - [Tema preset'i](#tema-preseti)
  - [Renkler: PrimeVue tasarım token'ları](#renkler-primevue-tasarım-tokenları)
  - [Karanlık mod — tek kaynak](#karanlık-mod--tek-kaynak)
  - [Tema değiştirici](#tema-değiştirici)
  - [Favicon](#favicon)
  - [Düzen: düz CSS](#düzen-düz-css)
  - [Sınıf adlandırma](#sınıf-adlandırma)
  - [Tailwind CSS eklemek](#tailwind-css-eklemek)
- [4. Kod kalitesi: ESLint + Prettier](#4-kod-kalitesi-eslint--prettier)
- [5. Testler: Vitest + Vue Test Utils](#5-testler-vitest--vue-test-utils)
  - [Yapılandırma](#yapılandırma)
  - [Bileşen testi yazmak](#bileşen-testi-yazmak)
- [6. Ek paketler: Router, Pinia, i18n](#6-ek-paketler-router-pinia-i18n)
  - [Router](#router)
  - [Pinia](#pinia)
  - [i18n](#i18n)
  - [`src/main.ts` — kayıt sırası](#srcmaints--kayıt-sırası)
  - [Dikkat: PrimeVue'nun kendi yerelleştirmesi var](#dikkat-primevuenun-kendi-yerelleştirmesi-var)
  - [Testlerde üç ek adım](#testlerde-üç-ek-adım)
- [Proje yapısı](#proje-yapısı)
- [Sık karşılaşılan sorunlar](#sık-karşılaşılan-sorunlar)
- [Kaynaklar](#kaynaklar)
- [IDE önerisi](#ide-önerisi)

---

## Teknoloji yığını

| Paket                            | Sürüm          | Rol                                           |
| -------------------------------- | -------------- | --------------------------------------------- |
| `vue`                            | ^3.5           | Framework                                     |
| `vite`                           | ^8.1           | Dev server / build                            |
| `typescript` + `vue-tsc`         | ~6.0 / ^3.3    | Tip kontrolü                                  |
| `primevue`                       | ^5.0           | UI bileşen kütüphanesi                        |
| `@primeuix/themes`               | ^3.0           | Tema preset'leri (Nora, Aura, Lara, Material) |
| `@primeicons/vue`                | ^8.0           | SVG ikon bileşenleri (300+)                   |
| `unplugin-vue-components`        | ^32.1          | Otomatik bileşen çözümleme                    |
| `@primevue/auto-import-resolver` | ^5.0           | PrimeVue resolver'ı                           |
| `vite-plugin-vue-devtools`       | ^8.1           | Vue DevTools paneli                           |
| `eslint` + `eslint-plugin-vue`   | ^10.8 / ^10.10 | Statik kod denetimi                           |
| `prettier`                       | ^3.9           | Kod biçimlendirme                             |
| `vitest` + `@vue/test-utils`     | ^4.1 / ^2.4    | Birim ve bileşen testleri                     |
| `jsdom`                          | ^30.0          | Testler için DOM ortamı                       |

Node gereksinimi: **^22.18.0 || >=24.12.0** (`package.json > engines`).

---

## Kurulum

```sh
npm install
npm run setup:env   # .env dosyasını .env.example'dan oluşturur
```

Ardından `.env` içindeki `VITE_PRIMEVUE_LICENSE` değerini doldurun.

> `.env` dosyası git'e girmez, bu yüzden her yeni klonda `npm run setup:env` bir kez
> çalıştırılmalıdır. PrimeUI lisans anahtarı için: <https://primeui.dev/pricing>

Node sürümü `.nvmrc` ile sabitlenmiştir (`nvm use`). `.npmrc` içindeki
`engine-strict=true` sayesinde `package.json > engines` ile uyumsuz bir Node sürümünde
`npm install` uyarı vermekle kalmaz, **hatayla durur** — yanlış sürümle başlayıp Vite veya
TypeScript'in beklenmedik yerde patlamasını önler.

## Komutlar

| Komut                | Açıklama                                                       |
| -------------------- | -------------------------------------------------------------- |
| `npm run setup:env`  | `.env` dosyasını `.env.example`'dan oluşturur (varsa dokunmaz) |
| `npm run dev`        | Geliştirme sunucusu (http://localhost:5173)                    |
| `npm run build`      | Tip kontrolü + üretim derlemesi                                |
| `npm run build-only` | Tip kontrolü olmadan derleme                                   |
| `npm run preview`    | Derlenmiş çıktıyı yerelde sunar                                |
| `npm run type-check` | Sadece TypeScript tip kontrolü (`vue-tsc --build`)             |
| `npm test`           | Birim testlerini bir kez çalıştırır (Vitest)                   |
| `npm run test:unit`  | Testleri izleme (watch) modunda çalıştırır                     |
| `npm run lint`       | ESLint denetimi                                                |
| `npm run lint:fix`   | ESLint ile otomatik düzeltme                                   |
| `npm run format`     | Prettier ile biçimlendirme                                     |

---

## Bu şablondan yeni proje başlatmak

Bu depo bir **temel şablon**; asıl kullanımı yeni projelere kopyalanmaktır.

### 1. Kopyalayın

Depo bir git remote'una gönderildiyse geçmişsiz kopya en temizi:

```sh
npx degit <kullanici>/primeui-base musteri-portali
cd musteri-portali
git init
```

Henüz yerelde duruyorsa klasörü kopyalayıp devralınan geçmişi ve türetilmiş dosyaları
atın:

```sh
cp -r /c/Proje/primeui-base /c/Proje/musteri-portali
cd /c/Proje/musteri-portali
rm -rf .git node_modules dist
git init
```

GitHub'a "template repository" olarak işaretlerseniz **Use this template** düğmesi de aynı
işi yapar.

### 2. Proje adını değiştirin

Şablon adı beş dosyada geçiyor. Git Bash'te tek seferde:

```sh
NEW=musteri-portali
sed -i "s/primeui-base/$NEW/g" package.json docker-compose.yml scripts/verify-docker.sh
sed -i "s/PrimeUI Base/Müşteri Portalı/" index.html
```

| Dosya                      | Ne geçiyor                                      |
| -------------------------- | ----------------------------------------------- |
| `package.json`             | `"name": "primeui-base"`                        |
| `index.html`               | `<title>PrimeUI Base</title>`                   |
| `docker-compose.yml`       | `image: primeui-base:local`                     |
| `scripts/verify-docker.sh` | `IMAGE=` ve `NAME=` değişkenleri                |
| `README.md`, `DEPLOY.md`   | Metin — elle gözden geçirin, `sed` ile geçmeyin |

### 3. Lisans anahtarını kurun

```sh
npm install
npm run setup:env
```

Ardından `.env` içine anahtarınızı yazın. **Aynı anahtarı kullanın** — PrimeUI lisansı
kuruluşa/geliştiriciye ait, projeye değil. Yeni proje için yeni anahtar almanız gerekmez.

### 4. Şablona ait içeriği temizleyin

Şunlar PrimeVue'nun/PrimeTek'in demo içeriği; kendi ürününüzü yayınlamadan önce
değiştirilmesi gerekir:

| Dosya                                            | Ne yapmalı                                     |
| ------------------------------------------------ | ---------------------------------------------- |
| `public/primeui-favicon-light.svg` / `-dark.svg` | Kendi favicon'unuzla değiştirin                |
| `public/favicon.ico`                             | Kendi ikonunuzdan üretin                       |
| `public/apple-touch-icon.png`                    | 180×180, opak zeminli, kendi ikonunuz          |
| `src/assets/primevue-logo.svg`                   | Kendi logonuz — ya da silin                    |
| `src/App.vue`                                    | Demo düzeni (logo + `<VerifyLicence />`) çıkar |
| `src/components/VerifyLicence.vue`               | Örnek bileşen — silin                          |
| `src/components/__tests__/VerifyLicence.spec.ts` | Bileşenle birlikte silin                       |

`ThemeToggle.vue`, `useColorScheme.ts` ve testi **kalmalı** — bunlar demo değil, altyapı.

Tema preset'ini değiştirecekseniz `src/main.ts` içindeki `Nora` import'unu değiştirin
(`aura`, `lara`, `material`).

### 5. Çalıştığını doğrulayın

```sh
npm run lint
npm run type-check
npm test
npm run dev
```

Dördü de temiz geçiyorsa şablon doğru devralınmıştır. `npm run dev` ilk çalıştığında
`components.d.ts` yeniden üretilir — sildiğiniz bileşenler listeden düşer.

Dağıtım yapılandırmasını (Docker + nginx) da devraldıysanız
`bash scripts/verify-docker.sh` ile bir kez doğrulayın; ayrıntı için
[DEPLOY.md](./DEPLOY.md).

### 6. İlk commit

```sh
git add -A
git status          # .env GORUNMEMELI
git commit -m "chore: primeui-base sablonundan turetildi"
```

`.env` listede görünüyorsa `.gitignore` devreye girmemiş demektir — lisans anahtarını
commit etmeden durun.

---

## 1. Lisans yapılandırması

PrimeVue 5, ticari bileşenler için çalışma zamanında bir lisans anahtarı bekler.
Anahtar **kod içine gömülmez**, ortam değişkeninden okunur.

**`.env`**

```dotenv
# PrimeUI lisans anahtarı: https://primeui.dev/pricing
VITE_PRIMEVUE_LICENSE=eyJhbGciOi...
```

**`src/main.ts`**

```ts
import PrimeVue from 'primevue/config';
import Nora from '@primeuix/themes/nora';

const app = createApp(App);

app.use(PrimeVue, {
  theme: {
    preset: Nora,
    options: { darkModeSelector: '.app-dark' },
  },
  license: import.meta.env.VITE_PRIMEVUE_LICENSE,
});
```

### Bilinmesi gerekenler

- `VITE_` önekli her değişken **istemci paketine (bundle) gömülür**. Bu, PrimeVue'nun
  lisans doğrulaması için beklediği davranıştır; anahtar gizli bir sır (secret) değildir
  ama repoya commit edilmemelidir. `.gitignore` bunu zaten engeller:

  ```gitignore
  .env
  .env.*
  !.env.example
  ```

  Yani `.env` yerelde kalır, `.env.example` repoda tutulur. Yeni bir geliştirici
  `npm run setup:env` ile kopyayı oluşturur (`scripts/setup-env.mjs`; mevcut `.env`
  dosyasının üzerine yazmaz) ve kendi anahtarını girer.

- `.env` yokken veya değişken boşken uygulama açılır, ancak ekranın sağ altında kırmızı
  bir **"Invalid PrimeUI License"** kutusu belirir ve ticari bileşenler kısıtlanabilir.
  Bu kutu üretim derlemesinde de görünür — dağıtımdan önce anahtarın geçerli olduğundan
  emin olun.
- Anahtar imzalı bir token'dır (`base64(JSON).imza`) ve yükünde bir `type` alanı bulunur —
  bu projedeki anahtarda `dev`. PrimeTek anahtar türlerini ve üretim/geliştirme ayrımını
  **belgelemiyor**; üretime çıkmadan önce elinizdeki anahtarın production kullanımını
  kapsayıp kapsamadığını <https://support.primeui.dev> üzerinden teyit edin. Anahtarı siz
  üretemezsiniz — imzayı yalnızca PrimeTek atabilir. Her durumda `.env` dosyasını sunucuya
  kopyalamayın, anahtarı CI/CD ortam değişkeni olarak verin.
- Yükteki `exp` alanı sona erme tarihini taşır. Bu projedeki anahtar **20 Ağustos
  2027**'de doluyor; yenileme için takvime not düşmek işe yarar.
- Ortam ayrımı: `.env.development`, `.env.production` dosyaları Vite tarafından mod'a
  göre otomatik yüklenir.
- Vite `.env` değişikliklerini HMR ile almaz; dosyayı düzenledikten sonra dev server'ı
  yeniden başlatın.

### Ortam değişkeni tipleri

`env.d.ts` içinde `ImportMetaEnv` tanımlıdır, dolayısıyla `import.meta.env` `any` değil
tiplenmiştir:

```ts
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_PRIMEVUE_LICENSE: string;
}
interface ImportMeta {
  readonly env: ImportMetaEnv;
}
```

Yeni bir `VITE_` değişkeni eklediğinizde bu arayüze de satırını ekleyin — aksi halde
`import.meta.env.VITE_YENI_DEGISKEN` tip hatası verir. Zorunlu olmayan değişkenleri
`readonly VITE_API_URL?: string` şeklinde opsiyonel tanımlayın.

---

## 2. Auto-import yapılandırması

**`vite.config.ts`**

```ts
import Components from 'unplugin-vue-components/vite';
import { PrimeVueResolver } from '@primevue/auto-import-resolver';

export default defineConfig({
  plugins: [
    vue(),
    Components({
      resolvers: [PrimeVueResolver(), PrimeIconsResolver()],
    }),
    vueDevTools(),
  ],
  resolve: {
    alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) },
  },
});
```

Sıra önemlidir: `PrimeVueResolver()` önce çalışır, ikon resolver'ı ondan sonra.

### PrimeVue bileşenleri ve direktifleri

Template'te doğrudan kullanım mümkündür:

```vue
<template>
  <Button label="Kaydet" />
  <Tag severity="success">Verified</Tag>
  <DataTable :value="rows">
    <Column field="name" header="Ad" />
  </DataTable>
</template>
```

`import Button from 'primevue/button'` satırına gerek yoktur. **Direktifler de**
otomatik çözümlenir: `v-tooltip`, `v-ripple`, `v-badge`, `v-focustrap`, `v-keyfilter`.

Prefix ile kullanmak isterseniz:

```ts
PrimeVueResolver({
  components: { prefix: 'p' }, // <p-button />
  directives: { prefix: 'p' }, // v-p-tooltip
});
```

### PrimeIcons — `Icon` sonekli auto-import

PrimeVue tarafında resmî bir ikon resolver'ı yoktur; bu şablon `vite.config.ts` içinde
kendi `PrimeIconsResolver()` fonksiyonunu tanımlar.

```vue
<template>
  <CheckIcon />
  <ArrowUpRightIcon :size="32" />
  <SpinnerIcon :spin="true" color="gray" />
</template>
```

Nasıl çalışır:

- Yalnızca **`Icon` sonekli** adlar çözümlenir. Bu, `Tag`, `Filter`, `Check` gibi hem
  PrimeVue hem PrimeIcons tarafında bulunan adların çakışmasını önler.
- Ad PascalCase → kebab-case'e çevrilir (`ArrowUpRightIcon` → `arrow-up-right`), sonra
  paketteki **gerçek ikon listesiyle** doğrulanır. Liste, config yüklenirken
  `node_modules/@primeicons/vue/dist/esm/icons` dizininden bir kez okunur.
- Listede olmayan bir ad sessizce yok sayılır — yanlış bir import üretilmez, bunun yerine
  Vue'nun bilinen "Failed to resolve component" uyarısını alırsınız. Yazım hatalarını
  yakalamak açısından istenen davranış budur.
- Üretilen import tree-shakeable'dır (barrel değil):
  `import CheckIcon from '@primeicons/vue/check'`

Manuel import da her zaman geçerlidir:

```ts
import Check from '@primeicons/vue/check'; // tree-shakeable
import { Check } from '@primeicons/vue'; // barrel
```

İkon props'ları: `size` (varsayılan `24`), `color` (varsayılan `currentColor`),
`class`, `style`, `spin`. Tüm liste: <https://primeicons.dev>

### `components.d.ts`

`unplugin-vue-components`, kullanılan her bileşen için proje kökündeki
`components.d.ts` dosyasını **otomatik üretir**. Bu dosya sayesinde IDE ve `vue-tsc`
global bileşenleri tanır:

```ts
declare module 'vue' {
  export interface GlobalComponents {
    Tag: (typeof import('primevue/tag'))['default'];
    CheckIcon: (typeof import('@primeicons/vue/check'))['default'];
    VerifyLicence: (typeof import('./src/components/VerifyLicence.vue'))['default'];
  }
}
```

- Dosya üretilmiş bir çıktıdır — elle düzenlenmez.
- Dev server veya build çalıştıkça güncellenir. Yeni bir bileşen ekledikten sonra
  IDE'de kırmızı görürseniz `npm run dev` çalıştırın.
- Ekip halinde çalışırken commit edilmesi önerilir (aksi halde temiz bir checkout'ta
  `npm run type-check` bileşenleri bulamaz).
- Tip kontrolünde görünmesi için `tsconfig.app.json > include` içinde yer alır:

  ```jsonc
  "include": ["env.d.ts", "components.d.ts", "src/**/*", "src/**/*.vue"]
  ```

### `src/components` altındaki kendi bileşenleriniz

`unplugin-vue-components` varsayılan olarak `src/components` klasörünü de tarar.
Yani `VerifyLicence.vue` template'te `<VerifyLicence />` olarak import'suz kullanılabilir.
`src/App.vue` içinde bu bileşen açık `import` ile kullanılır; ikisi de geçerlidir —
açık import daha okunabilir ve "go-to-definition" desteği daha iyidir.

---

## 3. Tema ve stil

### Tema preset'i

Preset `src/main.ts` içinde ayarlanır:

```ts
import Nora from '@primeuix/themes/nora'; // aura | lara | material | nora

app.use(PrimeVue, {
  theme: {
    preset: Nora,
    options: { darkModeSelector: '.app-dark' },
  },
  license: import.meta.env.VITE_PRIMEVUE_LICENSE,
});
```

### Renkler: PrimeVue tasarım token'ları

`base.css` kendi renk paletini tutmaz; renkleri PrimeVue'nun token'larından okur.
Böylece preset'i değiştirdiğinizde sayfa arka planı ve metin rengi bileşenlerle birlikte
değişir — iki ayrı palet senkronize tutmak gerekmez.

```css
body {
  color: var(--p-text-color, CanvasText);
  background: var(--p-content-background, Canvas);
  font-size: var(--p-typography-font-size, 0.875rem);
}

a {
  color: var(--p-primary-color, LinkText);
}
a:hover {
  color: var(--p-primary-hover-color, LinkText);
}

:focus-visible {
  outline: var(--p-focus-ring-width, 2px) var(--p-focus-ring-style, solid)
    var(--p-focus-ring-color, currentColor);
  outline-offset: var(--p-focus-ring-offset, 2px);
}
```

Sık kullanılan token'lar: `--p-text-color`, `--p-text-muted-color`,
`--p-content-background`, `--p-content-border-color`, `--p-primary-color`,
`--p-primary-hover-color`, `--p-surface-0` … `--p-surface-950`,
`--p-border-radius-md`, `--p-focus-ring-*`. Tam liste tarayıcı DevTools'ta `:root`
altında görülebilir (Nora preset'i ~400 değişken üretir).

`var()` fallback'leri (`Canvas`, `CanvasText`, `LinkText`) tema CSS'i enjekte edilene
kadarki ilk kareyi korur; bu CSS sistem renkleri de `color-scheme`'e uyar.

### Karanlık mod — tek kaynak

PrimeVue 5 token'ları CSS `light-dark()` fonksiyonuyla tanımlıdır; hangi değerin
seçileceği elemanın `color-scheme` değerine bağlıdır. `darkModeSelector: '.app-dark'`
ayarı tek bir kural üretir:

```css
:root,
:host {
  color-scheme: light;
}
.app-dark {
  color-scheme: dark;
}
```

Bu yüzden `base.css` içinde **ayrı bir `prefers-color-scheme` bloğu yoktur**. Olsaydı iki
bağımsız mekanizma oluşurdu ve manuel tema değiştirici ile ayrışırdı: PrimeVue bileşenleri
koyu, sayfa arka planı açık kalırdı. Tek sınıf hem bileşenleri hem sayfayı çevirir.

`app-dark` adı **üç yerde aynı** olmalı — birini değiştirirseniz üçünü değiştirin:

| Yer                                 | Rolü                                       |
| ----------------------------------- | ------------------------------------------ |
| `src/main.ts`                       | `darkModeSelector: '.app-dark'`            |
| `src/composables/useColorScheme.ts` | `DARK_CLASS` — sınıfı ekler/kaldırır       |
| `index.html`                        | İlk boyamadan önce sınıfı uygulayan script |

### Tema değiştirici

`src/composables/useColorScheme.ts` modül seviyesinde tekil bir durum tutar; kaç bileşen
kullanırsa kullansın aynı değeri paylaşır.

```ts
const { scheme, isDark, setScheme, cycleScheme } = useColorScheme();
```

- `scheme`: `'system' | 'light' | 'dark'` — kullanıcının seçimi
- `isDark`: hesaplanmış gerçek durum (`system` ise işletim sistemi tercihine bakar)
- `setScheme(x)` / `cycleScheme()` — `cycleScheme` sırası: system → light → dark → system

Seçim `localStorage`'a `color-scheme` anahtarıyla yazılır; `system` seçildiğinde anahtar
silinir. `localStorage` erişilemezse (gizli sekme, katı gizlilik ayarları) seçim yalnızca
o oturum için geçerli olur — kod `try/catch` ile bunu sessizce tolere eder.

`src/components/ThemeToggle.vue` bu composable'ı kullanan üç durumlu bir düğmedir
(`DesktopIcon` / `SunIcon` / `MoonIcon`).

**Açılış parlaması (flash) önlenir:** `index.html` içindeki küçük satır içi script,
uygulama JavaScript'i yüklenmeden önce `app-dark` sınıfını uygular. Bu script kaldırılırsa
koyu tema kullanıcıları her yenilemede bir kare beyaz görür.

### Favicon

Favicon seti <https://vue.primeuipro.dev> ile aynı yaklaşımı kullanır: iki SVG dosyası,
`<link>` üzerindeki `media` niteliğiyle seçilir. Böylece koyu tarayıcı temasında sekme
ikonu beyaz çizilir.

```html
<link
  rel="icon"
  type="image/svg+xml"
  href="/primeui-favicon-light.svg"
  media="(prefers-color-scheme: light)"
/>
<link
  rel="icon"
  type="image/svg+xml"
  href="/primeui-favicon-dark.svg"
  media="(prefers-color-scheme: dark)"
/>
<link rel="icon" type="image/x-icon" href="/favicon.ico" sizes="16x16 32x32 48x48" />
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
```

- `public/primeui-favicon-light.svg` ve `public/primeui-favicon-dark.svg` — PrimeUI Pro
  showcase sitesindeki dosyaların birebir aynısı (16×16 viewBox, 9 path; tek fark `fill`
  değeri: `black` / `white`).
- `public/favicon.ico` — SVG favicon desteklemeyen eski tarayıcılar ve `/favicon.ico`
  adresini kendiliğinden isteyen istemciler için yedek. Açık sürüm SVG'den üretilmiş,
  16/32/48/64/128/256 boyutlarını içerir.
- `public/apple-touch-icon.png` — iOS "Ana Ekrana Ekle" kısayolu için 180×180 PNG. iOS
  saydamlığı desteklemediği için **opak beyaz zeminli**; işaret, iOS'un kendi köşe
  yuvarlamasına yer bırakmak üzere ~%22 kenar boşluğuyla yerleştirilmiştir. Koyu mod
  varyantı yoktur — iOS tek ikon kullanır.
- Bu ikon PrimeTek'in marka işaretidir. Kendi ürününüzü yayınlarken kendi logonuzla
  değiştirin; şablon içi geliştirme için olduğu gibi kalabilir.

Not: `media` nitelikli SVG favicon'lar Chrome ve Firefox'ta çalışır; Safari SVG favicon
desteğinde daha sınırlıdır ve `favicon.ico` yedeğine düşer.

### Düzen: düz CSS

Projede Tailwind veya başka bir utility-class framework'ü **yoktur**. `flex flex-col
items-center` gibi sınıflar burada çalışmaz. Düzen iki yerde tanımlıdır:

**`src/assets/main.css`** — `#app` viewport'u dolduran ortalama kabıdır:

```css
#app {
  min-height: 100dvh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}
```

**`src/App.vue`** — içerik dizilimi scoped stil ile:

```vue
<template>
  <main class="page">
    <img class="logo" src="./assets/primevue-logo.svg" alt="PrimeVue" />
    <VerifyLicence />
  </main>
</template>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  text-align: center;
}

.logo {
  display: block;
  max-width: 100%;
  height: auto;
}
</style>
```

### Sınıf adlandırma

Bileşen stilleri `<style scoped>` içinde yazılır; Vue her seçiciye `[data-v-xxxxxxxx]`
ekleyerek izolasyonu kendisi sağlar. Bu yüzden bu projede **kısa, tek amaçlı, semantik
sınıf adları** kullanılır: `.page`, `.logo`, `.verify`.

<details>
<summary><b>Bilgi:</b> BEM ve çift alt çizgi (<code>__</code>) nedir?</summary>

BEM (**B**lock – **E**lement – **M**odifier), global CSS'te isim çakışmalarını önlemek
için geliştirilmiş bir adlandırma kuralıdır. Üç parçası vardır:

| Parça        | Yazım                     | Anlamı                                   |
| ------------ | ------------------------- | ---------------------------------------- |
| **Block**    | `.card`                   | Bağımsız, tek başına anlamlı bileşen     |
| **Element**  | `.card__title`            | Bloğun ayrılmaz bir parçası              |
| **Modifier** | `.card--featured`         | Bloğun veya elemanın bir varyantı/durumu |
|              | `.card__title--truncated` | Eleman üzerinde varyant                  |

**Neden tek değil, çift ayırıcı?** Blok ve eleman adlarının kendi içinde tire
bulunabildiği için. `user-card-avatar` okunduğunda bloğun `user`, `user-card` ya da
`user-card-avatar` olduğu belirsizdir; `user-card__avatar` ise `user-card` bloğunun
`avatar` elemanı olduğunu tek bakışta belli eder. Aynı mantıkla varyant için çift tire
(`--`) kullanılır: `user-card__avatar--large`.

Kural, ayrıca kasıtlı olarak **derinlik içermez**: HTML üç seviye iç içe olsa bile sınıf
adı yine `blok__eleman` biçiminde kalır (`.card__title__text` yazılmaz). Böylece CSS
seçicileri tek seviyede ve düşük özgüllükte (specificity) tutulur.

**Bu projede neden kullanılmıyor?** BEM'in çözdüğü problem — global ad alanında çakışma —
`<style scoped>` tarafından derleme zamanında zaten çözülüyor. `.logo` sınıfı yalnızca onu
tanımlayan bileşenin elemanlarına uygulanır, çünkü Vue seçiciyi `.logo[data-v-d4e1dc6e]`
hâline getirir. Bu durumda BEM yalnızca gereksiz uzunluk ekler.

**BEM'in yine de mantıklı olduğu yerler:**

- Global stil dosyaları (`base.css`, `main.css`) — burada scope koruması yok
- `:deep()` ile üçüncü parti bileşenlerin içine sızan stiller
- Birden çok projede paylaşılan tasarım sistemi / kütüphane CSS'i
- Scoped stil kullanmayan (CSS Modules veya utility-first de olmayan) eski kod tabanları

Alternatif yaklaşımlar: CSS Modules (`styles.logo` — derleyici adı benzersizleştirir),
utility-first (Tailwind), ve Vue'nun `<style scoped>`'u. Üçü de BEM'in çözdüğü problemi
farklı katmanda çözer.

</details>

Global CSS'e (`base.css` / `main.css`) bir sınıf eklerseniz orada scope koruması
olmadığını unutmayın; global seçicileri `#app` altında ya da açıkça ayırt edici bir adla
tanımlayın.

`src/assets/base.css` yalnızca `box-sizing` sıfırlaması, tipografi, token'lardan gelen
renkler ve odak halkasını içerir. Vite şablonunun `--vt-c-*` renk paleti, `--section-gap`
değişkeni, iki kolonlu `grid` düzeni, `body { display: flex }` ve `.green` kuralı
kaldırılmıştır.

### Tailwind CSS eklemek

Şablon Tailwind olmadan gelir. Sonradan eklemek isterseniz aşağıdaki dört adım yeterli.
Adımlar Tailwind **v4** ve PrimeVue **5** ile denenmiş, sonuçlar en sonda.

**1. Paketleri kurun**

```sh
npm i -D tailwindcss @tailwindcss/vite tailwindcss-primeui
```

`tailwindcss-primeui`, PrimeVue tasarım token'larını Tailwind yardımcı sınıflarına
bağlayan resmî eklentidir: `bg-primary`, `text-muted-color`, `border-surface`,
`surface-0` … `surface-950` gibi sınıflar tema preset'inizden beslenir.

**2. `vite.config.ts` — Tailwind eklentisini ekleyin**

```ts
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [
    vue(),
    tailwindcss(),
    Components({ resolvers: [PrimeVueResolver(), PrimeIconsResolver()] }),
    vueDevTools(),
  ],
  // ...
});
```

**3. `src/assets/main.css` — katman sırasını siz belirleyin**

```css
/* primevue, utilities'ten ÖNCE olmali; aksi halde her yardimci sinifa ! eklemeniz gerekir */
@layer theme, base, primevue, components, utilities;

@import 'tailwindcss';
@import 'tailwindcss-primeui';

/* Tailwind'in dark: varyantini PrimeVue ile AYNI sinifa bagla */
@custom-variant dark (&:where(.app-dark, .app-dark *));

/* base.css'i base katmanina alin, yoksa katmansiz kalir ve tum yardimci siniflari ezer */
@import './base.css' layer(base);

#app {
  min-height: 100dvh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}
```

**4. `src/main.ts` — PrimeVue stillerini `primevue` katmanına alın**

```ts
app.use(PrimeVue, {
  theme: {
    preset: Nora,
    options: {
      darkModeSelector: '.app-dark',
      cssLayer: {
        name: 'primevue',
        order: 'theme, base, primevue, components, utilities',
      },
    },
  },
  license: import.meta.env.VITE_PRIMEVUE_LICENSE,
});
```

#### Dikkat edilecek üç nokta

**Katman sırası her şeyi belirler.** `primevue` katmanı `utilities`'ten önce gelmezse
PrimeVue'nun bileşen stilleri Tailwind yardımcı sınıflarını yener ve `rounded-none`
yerine `!rounded-none` yazmak zorunda kalırsınız. Doğru sırada `<Tag class="rounded-none">`
`!` olmadan çalışır.

**`dark:` varyantı elle bağlanmalı.** Tailwind v4'ün `dark:` varyantı varsayılan olarak
`prefers-color-scheme`'e bakar — yani tema değiştiricinizi **görmez**. `@custom-variant`
satırı olmadan `dark:bg-surface-900` gibi sınıflar düğmeyle değişmez, işletim sistemi
tercihine takılı kalır. Bu satırı eklediğinizde `app-dark` adının geçtiği yer **üçten
dörde çıkar** (bkz. _Karanlık mod — tek kaynak_):

| Yer                                 | Rolü                                                  |
| ----------------------------------- | ----------------------------------------------------- |
| `src/main.ts`                       | `darkModeSelector`                                    |
| `src/composables/useColorScheme.ts` | `DARK_CLASS`                                          |
| `index.html`                        | Flash önleyici script                                 |
| `src/assets/main.css`               | `@custom-variant dark` — Tailwind'in `dark:` varyantı |

**`base.css`'i katmana alın.** CSS'te katmansız (unlayered) kurallar tüm katmanlı
kuralları yener. `@import './base.css'` yazarsanız `body` kuralları hiçbir Tailwind
yardımcı sınıfıyla ezilemez; `layer(base)` eklemek bunu düzeltir. `base.css` token
tabanlı olduğu için içeriğinde başka değişiklik gerekmez.

#### Doğrulanmış sonuçlar

Bu adımları şablonun bir kopyasında uygulayıp derleyip tarayıcıda ölçtüm:

| Kontrol                                         | Sonuç                                                     |
| ----------------------------------------------- | --------------------------------------------------------- |
| Derlenmiş CSS katman sırası                     | `properties, theme, base, primevue+components, utilities` |
| `<Tag class="rounded-none">` (`!` yok)          | `border-radius: 0px` — yardımcı sınıf kazanıyor           |
| `<Tag class="bg-primary">`                      | `rgb(5, 150, 105)` — Nora preset'inin primary rengi       |
| `dark:outline` + açık tema                      | `outline: none` — uygulanmıyor                            |
| `dark:outline` + `app-dark`                     | `outline: solid` — uygulanıyor                            |
| `body` renkleri (`base.css`, `layer(base)` ile) | Değişmedi: beyaz zemin, koyu metin, 14px                  |

---

## 4. Kod kalitesi: ESLint + Prettier

İş bölümü nettir: **ESLint kod hatalarını**, **Prettier biçimlendirmeyi** üstlenir.
`@vue/eslint-config-prettier/skip-formatting` ESLint'in stil kurallarını kapattığı için
ikisi çakışmaz.

```sh
npm run lint          # denetle
npm run lint:fix      # otomatik düzeltilebilenleri düzelt
npm run format        # Prettier ile biçimlendir
```

**`eslint.config.js`** (flat config, ESM):

- `pluginVue.configs['flat/essential']` + `vueTsConfigs.recommended`
- `components.d.ts` yoksayılır (üretilmiş dosya)
- `vue/multi-word-component-names` kuralı varsayılan (`error`) seviyesinde bırakıldı.
  Bu yüzden bileşenlerinizi `VerifyLicence`, `UserCard`, `OrderTable` gibi çok kelimeli
  adlandırın; tek kelimeli bir bileşen adı lint hatası verir.

**`.prettierrc.json`**: `semi: true`, `singleQuote: true`, `printWidth: 100`.
`.prettierignore` içinde `dist`, `public`, `package-lock.json` ve `components.d.ts` var.

**`.editorconfig`**: UTF-8, LF, 2 boşluk girinti, dosya sonu satırı. Editörünüzün
EditorConfig desteği açık olmalı (VS Code için `EditorConfig.EditorConfig` eklentisi).

**`.gitattributes`**: `* text=auto eol=lf` ile satır sonlarını git tarafında zorunlu
kılar. `.editorconfig` editöre "LF kullan" der; bu dosya git'in `core.autocrlf`
ayarının araya girip dosyaları CRLF'ye çevirmesini engeller. Windows'ta geliştirilen
bir projede kritik: `scripts/verify-docker.sh` CRLF'ye dönüşürse bash
`$'\r': command not found` ile ölür, `docker/*.conf` dosyaları da imaj içinde
beklenmedik davranır. `*.ico`/`*.png` gibi ikili dosyalar `binary` işaretli, `*.svg`
ise XML olduğu için metin olarak bırakıldı — favicon değişiklikleri diff'te okunabilsin.

**`.vscode/settings.json`**: kaydetmede Prettier ile biçimlendirme (`formatOnSave`),
kaydetmede ESLint düzeltmeleri (`source.fixAll.eslint`) ve dil bazında biçimlendirici
ataması açıktır. Yani `npm run format` komutunu elle çalıştırmanız çoğu zaman gerekmez.
`esbenp.prettier-vscode` ve `dbaeumer.vscode-eslint` eklentilerinin kurulu olması gerekir.

Doğrulanmış durum: `npm run lint` → 0 hata / 0 uyarı, `npx prettier --check .` → temiz,
`npm run type-check`, `npm test` ve `npm run build` → başarılı.

---

## 5. Testler: Vitest + Vue Test Utils

```sh
npm test              # bir kez çalıştır (CI için)
npm run test:unit     # izleme modu, geliştirirken
npx vitest run src/components   # sadece bir klasör
npx vitest -t "Verified"        # testi adına göre filtrele
```

Testler bileşenin yanında `__tests__` klasöründe durur ve `*.spec.ts` uzantısını kullanır:

```
src/
├─ components/
│  ├─ VerifyLicence.vue
│  └─ __tests__/VerifyLicence.spec.ts
└─ composables/
   ├─ useColorScheme.ts
   └─ __tests__/useColorScheme.spec.ts
```

### Yapılandırma

**`vitest.config.ts`** — `vite.config.ts` ile `mergeConfig` üzerinden birleşir. Bunun
pratik sonucu: `@/` takma adı ve **auto-import testlerde de çalışır**, yani mount edilen
bileşen içindeki `<Tag />` ve `<CheckIcon />` için ek bir şey yapmanız gerekmez. Ortam
`jsdom`.

**`vitest.setup.ts`** — `window.matchMedia` için bir stub içerir. Bu zorunlu: `jsdom`
`matchMedia`'yı uygulamaz ve `useColorScheme.ts` modül yüklenirken onu çağırdığı için,
stub olmadan testi **import etmek** bile hata verir.

**`tsconfig.vitest.json`** — test dosyaları `tsconfig.app.json` tarafından hariç
tutulduğu için ayrı bir proje olarak tanımlanır ve `tsconfig.json` referanslarına
eklenmiştir. Böylece `npm run type-check` testleri de kontrol eder.

### Bileşen testi yazmak

PrimeVue bileşenleri eklentinin sağladığı yapılandırmayı bekler; `global.plugins`
verilmezse mount sırasında PrimeVue config hatası alırsınız:

```ts
import { mount } from '@vue/test-utils';
import PrimeVue from 'primevue/config';
import Nora from '@primeuix/themes/nora';

const primevue: [typeof PrimeVue, object] = [PrimeVue, { theme: { preset: Nora } }];
const global = { plugins: [primevue] };

it('Verified metnini gösterir', () => {
  const wrapper = mount(VerifyLicence, { global });
  expect(wrapper.text()).toContain('Verified');
});
```

Tuple'ın açıkça `[typeof PrimeVue, object]` olarak tiplenmesi gerekir; `as const`
kullanırsanız `readonly` olur ve Vue Test Utils'in `GlobalMountOptions` tipiyle
uyuşmaz.

Sık kullanılanlar: `wrapper.text()`, `wrapper.find('.p-tag')`, `wrapper.get('button')`,
`await wrapper.find('button').trigger('click')`, `wrapper.emitted('update:modelValue')`.
Reaktif bir değişikliğin DOM'a yansımasını beklemek için `await nextTick()`.

Kapsam (coverage) raporu isterseniz `@vitest/coverage-v8` paketini kurup
`npx vitest run --coverage` çalıştırın; `coverage/` klasörü `.gitignore` ve ESLint
yoksayma listesinde zaten var.

---

## 6. Ek paketler: Router, Pinia, i18n

Bunlar şablonda **yok** — gerçek bir ihtiyaç doğmadan her yeni projeye taşınacak ölü
ağırlık olurlar. Aşağıdaki kurulum bu şablonun bir kopyasında denendi: derleme, tip
kontrolü, lint ve 9 test geçti.

```sh
npm i vue-router pinia vue-i18n
npm i -D @pinia/testing
```

### Router

**`src/router/index.ts`**

```ts
import { createRouter, createWebHistory } from 'vue-router';

const router = createRouter({
  // BASE_URL, vite.config.ts içindeki `base` ayarından gelir — alt yolda çalışırken şart
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', name: 'home', component: () => import('@/views/HomeView.vue') },
    { path: '/hakkinda', name: 'about', component: () => import('@/views/AboutView.vue') },
    {
      path: '/:pathMatch(.*)*',
      name: 'not-found',
      component: () => import('@/views/NotFoundView.vue'),
    },
  ],
});

export default router;
```

`App.vue` içinde `<RouterView />`, bağlantılarda `<RouterLink to="/hakkinda">`.
**Import gerekmez** ve bu sefer sebebi auto-import resolver'ı değil: router eklentisi bu
iki bileşeni global olarak kaydediyor. `unplugin-vue-components` da bunları
`components.d.ts`'e otomatik ekliyor (`RouterLink: typeof import('vue-router')['RouterLink']`),
yani `vue-tsc` de tanıyor — ek yapılandırma yok.

Dosya-tabanlı yönlendirme isterseniz `unplugin-vue-router` mevcut auto-import
felsefesiyle tutarlı bir alternatif.

**Dağıtım etkisi:** router eklendiği anda nginx'teki SPA fallback teorik olmaktan çıkıp
hayati hâle gelir — `/hakkinda` adresine doğrudan girip yenileyen kullanıcı aksi halde
404 görür. `docker/nginx.conf` bunu zaten karşılıyor; ayrıntı [DEPLOY.md](./DEPLOY.md).
Router ekledikten sonra `bash scripts/verify-docker.sh` çalıştırın.

### Pinia

**`src/stores/counter.ts`** — setup sözdizimi, `ref`/`computed` ile:

```ts
import { computed, ref } from 'vue';
import { defineStore } from 'pinia';

export const useCounterStore = defineStore('counter', () => {
  const count = ref(0);
  const double = computed(() => count.value * 2);
  function increment() {
    count.value++;
  }
  return { count, double, increment };
});
```

### i18n

**`src/i18n/index.ts`**

```ts
import { createI18n } from 'vue-i18n';
import tr from './locales/tr.json';
import en from './locales/en.json';

export default createI18n({
  legacy: false, // Composition API modu — <script setup> ile useI18n() kullanmak için şart
  locale: 'tr',
  fallbackLocale: 'en',
  messages: { tr, en },
});
```

Bileşende:

```vue
<script setup lang="ts">
import { useI18n } from 'vue-i18n';
const { t } = useI18n();
</script>

<template>
  <h1>{{ t('home.title') }}</h1>
  <p>{{ t('home.count', { n: 3 }) }}</p>
</template>
```

### `src/main.ts` — kayıt sırası

```ts
import { createPinia } from 'pinia';
import router from './router';
import i18n from './i18n';

const app = createApp(App);

app.use(createPinia());
app.use(router);
app.use(i18n);
app.use(PrimeVue, {
  theme: { preset: Nora, options: { darkModeSelector: '.app-dark' } },
  license: import.meta.env.VITE_PRIMEVUE_LICENSE,
});

app.mount('#app');
```

Pinia'yı router'dan önce kaydedin: navigation guard'ların içinde store kullanacaksanız
store'un o noktada hazır olması gerekir.

### Dikkat: PrimeVue'nun kendi yerelleştirmesi var

Bu, kolayca gözden kaçan bir çakışma. `vue-i18n` **sizin** metinlerinizi çevirir; PrimeVue
bileşenlerinin **kendi içindeki** metinleri (DatePicker'ın ay/gün adları, FileUpload'ın
"choose"/"upload"/"cancel" düğmeleri, DataTable filtre etiketleri) ayrı bir sistemden gelir:

```ts
app.use(PrimeVue, {
  locale: {
    dayNames: ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi'],
    dayNamesShort: ['Paz', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt'],
    dayNamesMin: ['Pz', 'Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct'],
    monthNames: [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ],
    monthNamesShort: [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ],
    accept: 'Evet',
    reject: 'Hayır',
    choose: 'Seç',
    upload: 'Yükle',
    cancel: 'İptal',
    // ...filtre etiketleri: startsWith, contains, equals, dateIs, clear, apply
  },
});
```

Yani dil değiştiren bir arayüz yaparsanız **iki** sistemi birlikte çevirmeniz gerekir:
`i18n.global.locale.value = 'en'` ve PrimeVue'nun `locale` nesnesi (çalışma zamanında
`usePrimeVue().config.locale` üzerinden güncellenebilir). Karanlık moddaki "tek kaynak"
sorununun aynısı — iki bağımsız mekanizma, elle senkron tutulmalı.

### Testlerde üç ek adım

Mevcut test kurulumuna eklenmesi gerekenler:

```ts
import { createPinia, setActivePinia } from 'pinia';

// 1) Store testlerinde: her testte temiz bir pinia.
//    Yoksa "getActivePinia() was called but there was no active Pinia" hatası.
beforeEach(() => setActivePinia(createPinia()));
```

```ts
import { createTestingPinia } from '@pinia/testing';
import { createI18n } from 'vue-i18n';
import { vi } from 'vitest';

const i18n = createI18n({ legacy: false, locale: 'tr', messages: { tr } });

mount(HomeView, {
  global: {
    // 2) i18n de PrimeVue gibi bir eklenti — plugins listesine girmeli,
    //    yoksa t() çağrısı patlar.
    plugins: [primevue, i18n, createTestingPinia({ createSpy: vi.fn })],
    // 3) RouterLink gerçek bir router olmadan çözülemez; stub'layın.
    stubs: { RouterLink: true },
  },
});
```

`createTestingPinia` eylemleri otomatik olarak spy'a çevirir — store mantığını değil,
bileşenin doğru eylemi çağırdığını test etmek istediğinizde işe yarar.

---

## Proje yapısı

```
primeui-base/
├─ .env                  # lisans anahtarı (.gitignore ile hariç tutulur)
├─ .env.example          # repoda tutulan şablon
├─ .editorconfig         # editör girinti/satır sonu kuralları
├─ .gitattributes        # satır sonlarını LF'te sabitler
├─ .nvmrc                # Node 24
├─ .npmrc                # engines alanını zorunlu kılar
├─ .prettierrc.json      # Prettier ayarları
├─ .prettierignore
├─ eslint.config.js      # ESLint flat config
├─ vitest.config.ts      # vite.config ile birleşir (alias + auto-import)
├─ vitest.setup.ts       # matchMedia stub'ı
├─ tsconfig.vitest.json  # test dosyaları için TS projesi
├─ env.d.ts              # ImportMetaEnv tipleri
├─ components.d.ts       # unplugin tarafından üretilir, commit edilir
├─ vite.config.ts        # auto-import (PrimeVue + PrimeIcons) ve alias
├─ tsconfig.json         # app + node referansları
├─ tsconfig.app.json     # include: env.d.ts, components.d.ts, src/**
├─ index.html            # lang="tr", favicon linkleri, flash önleyici tema script'i
├─ DEPLOY.md             # Docker + nginx dağıtım rehberi
├─ Dockerfile            # iki aşamalı: node build -> nginx serve
├─ .dockerignore
├─ docker-compose.yml
├─ docker/
│  ├─ nginx.conf         # SPA fallback, önbellek başlıkları, /healthz
│  └─ security-headers.conf
├─ .vscode/
│  ├─ settings.json      # formatOnSave + Prettier + ESLint
│  └─ extensions.json
├─ scripts/
│  ├─ setup-env.mjs      # npm run setup:env
│  └─ verify-docker.sh   # Docker derle + 20 kontrol (bkz. DEPLOY.md)
├─ public/
│  ├─ primeui-favicon-light.svg
│  ├─ primeui-favicon-dark.svg
│  ├─ apple-touch-icon.png  # iOS ana ekran, 180×180
│  └─ favicon.ico         # eski tarayıcılar için yedek
└─ src/
   ├─ main.ts            # PrimeVue + tema (darkModeSelector) + lisans
   ├─ App.vue            # ortalanmış düzen (scoped CSS)
   ├─ assets/
   │  ├─ base.css        # reset, tipografi, token'lardan renkler
   │  ├─ main.css        # #app ortalama kabı
   │  └─ primevue-logo.svg
   ├─ composables/
   │  ├─ useColorScheme.ts  # tekil karanlık mod durumu + localStorage
   │  └─ __tests__/useColorScheme.spec.ts
   └─ components/
      ├─ ThemeToggle.vue    # system / light / dark düğmesi
      ├─ VerifyLicence.vue  # örnek: <Tag> + <CheckIcon /> (ikisi de auto-import)
      └─ __tests__/VerifyLicence.spec.ts
```

Yol takma adı: `@/` → `src/` (hem `vite.config.ts` hem `tsconfig.app.json` içinde tanımlı).

---

## Sık karşılaşılan sorunlar

| Belirti                                                      | Neden / Çözüm                                                                                                                                                                     |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Failed to resolve component: Button`                        | Dev server auto-import yapılandırmasından önce başlatılmış. Sunucuyu yeniden başlatın.                                                                                            |
| `Failed to resolve component: XyzIcon`                       | İkon adı `@primeicons/vue` listesinde yok. Doğru adı <https://primeicons.dev> üzerinden kontrol edin (`Icon` soneki hariç PascalCase).                                            |
| `<Check />` bulunamıyor                                      | İkon resolver'ı `Icon` soneki ister: `<CheckIcon />`. Ya da manuel import edin.                                                                                                   |
| IDE bileşeni tanımıyor ama uygulama çalışıyor                | `components.d.ts` güncel değil; `npm run dev` çalıştırın.                                                                                                                         |
| Sağ altta kırmızı **"Invalid PrimeUI License"** kutusu       | `.env` eksik/boş veya anahtar geçersiz/süresi dolmuş. Dev server `.env` değişikliklerini HMR ile almaz — yeniden başlatın. `.env` git ile gelmez, `npm run setup:env` çalıştırın. |
| `Property 'VITE_X' does not exist on type 'ImportMetaEnv'`   | Yeni değişkeni `env.d.ts` içindeki `ImportMetaEnv` arayüzüne eklemeyi atlamışsınız.                                                                                               |
| Bileşenler stilsiz görünüyor                                 | `app.use(PrimeVue, { theme: ... })` çağrısı eksik veya preset import'u yanlış.                                                                                                    |
| `flex`, `gap-4` gibi sınıflar etkisiz                        | Projede Tailwind yok. Düz CSS kullanın (bkz. _Düzen: düz CSS_) veya Tailwind'i kurun.                                                                                             |
| `eslint: command not found` / `Cannot find package 'eslint'` | `npm install` çalıştırılmamış; ESLint ve Prettier `devDependencies` içinde.                                                                                                       |
| Bileşenler koyu, sayfa arka planı açık kalıyor               | `app-dark` adı üç yerden birinde farklı (`main.ts`, `useColorScheme.ts`, `index.html`) ya da `base.css`'e `prefers-color-scheme` bloğu geri eklenmiş.                             |
| Sayfa açılışta bir kare beyaz parlıyor                       | `index.html` içindeki satır içi tema script'i silinmiş.                                                                                                                           |

---

## Kaynaklar

- Dağıtım rehberi — [DEPLOY.md](./DEPLOY.md)
- PrimeVue dokümantasyonu — <https://primevue.org>
- PrimeUI lisanslama — <https://primeui.dev/licenses>
- PrimeIcons — <https://primeicons.dev>
- `unplugin-vue-components` — <https://github.com/unplugin/unplugin-vue-components>
- Vite yapılandırma referansı — <https://vite.dev/config/>

## IDE önerisi

VS Code + [Vue (Official) / Volar](https://marketplace.visualstudio.com/items?itemName=Vue.volar) (Vetur devre dışı).
`.vscode/extensions.json` bu öneriyi içerir. Ek olarak `dbaeumer.vscode-eslint`,
`esbenp.prettier-vscode` ve `EditorConfig.EditorConfig` eklentileri önerilir.
