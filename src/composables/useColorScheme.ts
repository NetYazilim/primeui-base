import { computed, ref, watchEffect } from 'vue';

export type ColorScheme = 'system' | 'light' | 'dark';

/**
 * Karanlik mod durumu.
 *
 * TEK KAYNAK: Asagidaki DARK_CLASS, src/main.ts icindeki PrimeVue
 * `theme.options.darkModeSelector` ayari ve index.html icindeki on-boyama
 * script'i ile AYNI olmak zorundadir. Birini degistirirseniz ucunu birlikte
 * degistirin - aksi halde PrimeVue bilesenleri ile sayfa arka plani ayrisir.
 *
 * PrimeVue token'lari light-dark() kullandigi icin sinifi eklemek/kaldirmak
 * hem bilesen renklerini hem base.css'teki sayfa renklerini birlikte cevirir.
 */
const DARK_CLASS = 'app-dark';
const STORAGE_KEY = 'color-scheme';

/** localStorage bazi baglamlarda (gizli sekme, katı gizlilik ayarlari) hata atar. */
function readStored(): ColorScheme {
  try {
    const value = localStorage.getItem(STORAGE_KEY);
    if (value === 'light' || value === 'dark') return value;
  } catch {
    // yoksay: varsayilan 'system'
  }
  return 'system';
}

function writeStored(scheme: ColorScheme) {
  try {
    if (scheme === 'system') localStorage.removeItem(STORAGE_KEY);
    else localStorage.setItem(STORAGE_KEY, scheme);
  } catch {
    // yoksay: secim yalnizca bu oturum icin gecerli olur
  }
}

const query = window.matchMedia('(prefers-color-scheme: dark)');

// Modul seviyesinde tekil state; kac bilesen kullanirsa kullansin ayni degeri paylasir.
const scheme = ref<ColorScheme>(readStored());
const systemPrefersDark = ref(query.matches);

query.addEventListener('change', (event) => {
  systemPrefersDark.value = event.matches;
});

const isDark = computed(
  () => scheme.value === 'dark' || (scheme.value === 'system' && systemPrefersDark.value),
);

watchEffect(() => {
  document.documentElement.classList.toggle(DARK_CLASS, isDark.value);
});

export function useColorScheme() {
  function setScheme(next: ColorScheme) {
    scheme.value = next;
    writeStored(next);
  }

  /** system -> light -> dark -> system */
  function cycleScheme() {
    setScheme(scheme.value === 'system' ? 'light' : scheme.value === 'light' ? 'dark' : 'system');
  }

  return { scheme, systemPrefersDark, isDark, setScheme, cycleScheme };
}
