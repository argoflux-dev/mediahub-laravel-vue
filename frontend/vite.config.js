import { defineConfig } from 'vite';

export default defineConfig({
    server: {
        host: '0.0.0.0',
        port: 5174,
        strictPort: true,
        // hmr: {
        //     protocol: 'wss',
        //     host: 'mediahub.argoflux.com',
        //     port: 443,
        // },
        watch: {
            usePolling: true,
            interval: 1000,
        },
        origin: 'https://mediahub.argoflux.com',
    },
    build: {
        manifest: 'manifest.json',
        outDir: 'public/dist',
        rollupOptions: {
            output: {
                assetFileNames: 'assets/[name]-[hash][extname]',
                chunkFileNames: 'assets/[name]-[hash].js',
                entryFileNames: 'assets/[name]-[hash].js',
            },
        },
    },
});
