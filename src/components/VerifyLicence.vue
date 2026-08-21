<script setup lang="ts">
// Tag  -> PrimeVue auto-import (@primevue/auto-import-resolver)
// CheckIcon -> PrimeIcons auto-import ("Icon" sonekli, vite.config.ts icindeki PrimeIconsResolver)
// Manuel karsiligi: import Check from '@primeicons/vue/check';
</script>

<template>
  <Tag severity="success" class="verify">
    <CheckIcon :size="16" />
    Verified
  </Tag>
</template>

<style scoped>
.verify {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
}
</style>
