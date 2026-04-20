<script setup>
import axiosClient from '../axios';
import { ref, onMounted, computed } from 'vue';
import useUserStore from '../store/user';

const userStore = useUserStore();
const isAuthenticated = computed(() => !!userStore.user);
const images = ref([]);

async function copyImageUrl(url) {
	await navigator.clipboard.writeText(url);
	alert('Copied to clipboard');
}

async function deleteImage(id) {
  if (!confirm('Are you sure?')) return;

  await axiosClient.delete(`/api/images/${id}`);
  images.value = images.value.filter(image => image.id !== id);
}

onMounted(async () => {
	const response = await axiosClient.get('/api/images');
	images.value = response.data;
});

</script>

<template>
	<header class="relative bg-gray-800 after:pointer-events-none after:absolute after:inset-x-0 after:inset-y-0 after:border-y after:border-white/10">
		<div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
			<h1 class="text-3xl font-bold tracking-tight text-white">
				Gallery
			</h1>
		</div>
	</header>
	<main>
		<div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
			<div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
				<div class="grid grid-cols-1 gap-6 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
					<div v-for="image in images" :key="image.id" class="flex flex-col bg-white overflow-hidden shadow rounded-lg">
						<img :src="image.url" alt="Image" class="w-full md:h-48 object-contain md:mt-1">
						<div class="flex flex-col flex-1 px-4 py-4">
							<!-- <h3 class="text-lg font-semibold text-gray-900">{{ image.name }}</h3> -->
							<p class="text-md text-black font-bold mb-4">{{ image.label }}</p>
							<div :class="['grid justify-between gap-2 mt-auto',
								isAuthenticated ? 'grid-cols-2' : 'grid-cols-1']">
								<button type="submit"
												@click="copyImageUrl(image.url)"
												class="min-w-[5rem] rounded-md bg-indigo-500 px-3 py-2 text-sm font-semibold text-white transition hover:bg-indigo-400 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500">
									Copy Url
								</button>
								<button v-if="isAuthenticated"
												type="submit"
												@click="deleteImage(image.id)"
												class="min-w-[5rem] rounded-md bg-red-500 px-3 py-2 text-sm font-semibold text-white transition hover:bg-red-400 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-500">
									Delete
								</button>
            	</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</main>
</template>

<style scoped>

</style>