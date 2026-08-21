import './assets/main.css';

import { createApp } from 'vue';
import App from './App.vue';
import PrimeVue from 'primevue/config';
import Nora from '@primeuix/themes/nora';

const app = createApp(App);
app.use(PrimeVue, {
  theme: {
    preset: Nora,
    options: {
      // TEK KAYNAK: bu secici index.html'deki on-boyama script'i ve
      // src/composables/useColorScheme.ts icindeki DARK_CLASS ile ayni olmali.
      darkModeSelector: '.app-dark',
    },
  },
  license: import.meta.env.VITE_PRIMEVUE_LICENSE,
});
app.mount('#app');
