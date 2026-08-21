import { beforeEach, describe, expect, it } from 'vitest';
import { nextTick } from 'vue';
import { useColorScheme } from '@/composables/useColorScheme';

describe('useColorScheme', () => {
  beforeEach(() => {
    localStorage.clear();
    useColorScheme().setScheme('system');
  });

  it('koyu secildiginde app-dark sinifini ekler', async () => {
    const { setScheme } = useColorScheme();
    setScheme('dark');
    await nextTick();
    expect(document.documentElement.classList.contains('app-dark')).toBe(true);
  });

  it('acik secildiginde sinifi kaldirir', async () => {
    const { setScheme } = useColorScheme();
    setScheme('dark');
    await nextTick();
    setScheme('light');
    await nextTick();
    expect(document.documentElement.classList.contains('app-dark')).toBe(false);
  });

  it('secimi localStorage a yazar, system secildiginde siler', () => {
    const { setScheme } = useColorScheme();
    setScheme('dark');
    expect(localStorage.getItem('color-scheme')).toBe('dark');
    setScheme('system');
    expect(localStorage.getItem('color-scheme')).toBeNull();
  });
});
