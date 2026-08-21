/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_PRIMEVUE_LICENSE: string;
}
interface ImportMeta {
  readonly env: ImportMetaEnv;
}
