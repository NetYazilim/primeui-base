import { describe, expect, it } from 'vitest';
import { mount } from '@vue/test-utils';
import PrimeVue from 'primevue/config';
import Nora from '@primeuix/themes/nora';
import VerifyLicence from '@/components/VerifyLicence.vue';

// PrimeVue bilesenleri (Tag) eklentinin sagladigi yapilandirmayi bekler; global
// plugins olmadan mount edilirse "no PrimeVue config" hatasi alirsiniz.
const primevue: [typeof PrimeVue, object] = [PrimeVue, { theme: { preset: Nora } }];
const global = { plugins: [primevue] };

describe('VerifyLicence', () => {
  it('Verified metnini gosterir', () => {
    const wrapper = mount(VerifyLicence, { global });
    expect(wrapper.text()).toContain('Verified');
  });

  it('auto-import edilen Tag ve CheckIcon bilesenlerini render eder', () => {
    const wrapper = mount(VerifyLicence, { global });
    expect(wrapper.find('.p-tag').exists()).toBe(true);
    expect(wrapper.find('svg.p-icon').exists()).toBe(true);
  });
});
