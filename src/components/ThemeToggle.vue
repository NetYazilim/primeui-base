<script setup lang="ts">
import { computed } from 'vue';
import { useColorScheme } from '@/composables/useColorScheme';

// Button, SunIcon, MoonIcon ve DesktopIcon auto-import ile gelir.
const { scheme, cycleScheme } = useColorScheme();

const label = computed(
  () =>
    ({
      system: 'Sistem teması',
      light: 'Açık tema',
      dark: 'Koyu tema',
    })[scheme.value],
);
</script>

<template>
  <Button
    variant="text"
    rounded
    severity="secondary"
    :aria-label="`${label} — değiştirmek için tıklayın`"
    :title="label"
    @click="cycleScheme"
  >
    <DesktopIcon v-if="scheme === 'system'" :size="18" />
    <SunIcon v-else-if="scheme === 'light'" :size="18" />
    <MoonIcon v-else :size="18" />
  </Button>
</template>
