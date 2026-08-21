<script setup lang="ts">
import VerifyLicence from '@/components/VerifyLicence.vue';
import ThemeToggle from '@/components/ThemeToggle.vue';
</script>

<template>
  <main class="page">
    <ThemeToggle class="toggle" />
    <img class="logo" src="./assets/primevue-logo.svg" alt="PrimeVue" />
    <VerifyLicence />
  </main>
</template>

<style scoped>
/* Stiller scoped; Vue izolasyonu sagladigi icin kisa semantik sinif adlari yeterli. */
.page {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  text-align: center;
}

.toggle {
  position: fixed;
  top: 1rem;
  right: 1rem;
}

.logo {
  display: block;
  max-width: 100%;
  height: auto;
}
</style>
