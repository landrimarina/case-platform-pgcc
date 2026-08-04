import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { federation } from '@module-federation/vite'

export default defineConfig({
  plugins: [
    react(),
    federation({
      name: 'pgcc_mfe',
      filename: 'remoteEntry.js',
      exposes: {
        './PgccHome': './src/exposed/PgccHome',
        './PgccMenu': './src/exposed/PgccMenu',
      },
      shared: {
        react: { singleton: true, requiredVersion: '^19.0.0' },
        'react-dom': { singleton: true, requiredVersion: '^19.0.0' },
      },
    }),
  ],
  server: {
    port: 3001,
  },
  build: {
    target: 'esnext',
  },
})
