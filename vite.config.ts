import { fileURLToPath, URL } from 'node:url';
import { createRequire } from 'node:module';
import { readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';

import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import vueDevTools from 'vite-plugin-vue-devtools';
import Components from 'unplugin-vue-components/vite';
import type { ComponentResolver } from 'unplugin-vue-components/types';
import { PrimeVueResolver } from '@primevue/auto-import-resolver';

/**
 * PrimeIcons (@primeicons/vue) icin auto-import resolver.
 *
 * PrimeVue tarafinda resmi bir ikon resolver'i yok. Bu resolver, template'te
 * "Icon" sonekiyle yazilan bileşenleri tree-shakeable ikon dosyalarina baglar:
 *
 *   <CheckIcon />        ->  import CheckIcon from '@primeicons/vue/check'
 *   <ArrowUpRightIcon /> ->  import ArrowUpRightIcon from '@primeicons/vue/arrow-up-right'
 *
 * "Icon" soneki zorunludur; boylece PrimeVue bileşen adlariyla (Tag, Filter,
 * Check vb.) isim cakismasi olusmaz.
 */
function PrimeIconsResolver(): ComponentResolver {
  const require = createRequire(import.meta.url);
  const iconsDir = join(dirname(require.resolve('@primeicons/vue/package.json')), 'dist/esm/icons');

  // Paketteki gercek ikon listesi; olmayan bir isim resolver tarafindan yok sayilir.
  const icons = new Set(
    readdirSync(iconsDir)
      .filter((file) => file.endsWith('.mjs'))
      .map((file) => file.slice(0, -'.mjs'.length)),
  );

  return {
    type: 'component',
    resolve: (name: string) => {
      if (!name.endsWith('Icon') || name === 'Icon') return;

      const kebab = name
        .slice(0, -'Icon'.length)
        .replace(/([a-z0-9])([A-Z])/g, '$1-$2')
        .toLowerCase();

      if (!icons.has(kebab)) return;

      return { from: `@primeicons/vue/${kebab}` };
    },
  };
}

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    Components({
      resolvers: [PrimeVueResolver(), PrimeIconsResolver()],
    }),
    vueDevTools(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
});
