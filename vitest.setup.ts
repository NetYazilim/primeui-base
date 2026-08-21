import { vi } from 'vitest';

// jsdom window.matchMedia'yi uygulamaz. useColorScheme modul yuklenirken bunu
// cagirdigi icin stub zorunlu; aksi halde test dosyasi import edilirken patlar.
if (!window.matchMedia) {
  window.matchMedia = vi.fn().mockImplementation((query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    addListener: vi.fn(),
    removeListener: vi.fn(),
    dispatchEvent: vi.fn(),
  }));
}
