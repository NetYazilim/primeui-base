import { globalIgnores } from 'eslint/config';
import pluginVue from 'eslint-plugin-vue';
import { defineConfigWithVueTs, vueTsConfigs } from '@vue/eslint-config-typescript';
import skipFormatting from '@vue/eslint-config-prettier/skip-formatting';

export default defineConfigWithVueTs(
  {
    name: 'app/files-to-lint',
    files: ['**/*.{ts,mts,tsx,vue}'],
  },

  globalIgnores([
    '**/dist/**',
    '**/dist-ssr/**',
    '**/coverage/**',
    // unplugin-vue-components tarafindan uretilir
    'components.d.ts',
  ]),

  pluginVue.configs['flat/essential'],
  vueTsConfigs.recommended,

  // Bicimlendirmeyi Prettier'a birak; ESLint'in stil kurallarini kapatir.
  skipFormatting,
);
