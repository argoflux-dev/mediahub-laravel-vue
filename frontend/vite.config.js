import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
    plugins: [
        vue(),
        tailwindcss(),
    ],

    server: {
        host: '0.0.0.0',
        port: 5174,
        strictPort: true,
        allowedHosts: [
            'mediahub.argoflux.com'
        ],
    },
    build: {
        manifest: 'manifest.json',
        outDir: 'dist',
        emptyOutDir: true,
        rollupOptions: {
            output: {
                assetFileNames: 'assets/[name]-[hash][extname]',
                chunkFileNames: 'assets/[name]-[hash].js',
                entryFileNames: 'assets/[name]-[hash].js',
            },
        },
    },
});