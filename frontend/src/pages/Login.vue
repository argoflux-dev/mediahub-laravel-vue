<script setup>
import axiosClient from '../axios';
import GuestLayout from '../components/GuestLayout.vue'
import { ref } from 'vue'
import router from '../router';

const data = ref({
  email: '',
  password: '',
})

const errorMessage = ref('')

async function submit() {
  try {
    const response = await axiosClient.post("/login", data.value);
    localStorage.setItem('token', response.data.token);
    await router.push({ name: 'Home' });
  } catch (error) {
    errorMessage.value = error.response?.data?.message || 'Something went wrong';
  }
}

</script>

<template>
	<GuestLayout>
		<h2 class="mt-10 text-center text-2xl/9 font-bold tracking-tight text-white">Login to your account</h2>

    <div v-if="errorMessage" class="text-white bg-red-500 text-center rounded px-3 py-2 mt-4">{{ errorMessage }}</div>

    <div class="mt-10 sm:mx-auto sm:w-full sm:max-w-sm">
      <form @submit.prevent="submit" class="space-y-4">
        <div>
          <label for="email" class="block text-sm/6 text-left font-medium text-gray-100">Email address</label>
          <div class="mt-2">
            <input
              type="email"
              name="email"
              id="email"
              autocomplete="email"
              required=""
              v-model="data.email"
              class="block w-full rounded-md bg-white/5 px-3 py-1.5 text-base text-white outline-1 -outline-offset-1 outline-white/10 placeholder:text-gray-500 focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-500 sm:text-sm/6" />
          </div>
        </div>

        <div>
          <div class="flex items-center justify-between">
            <label for="password" class="block text-sm/6 font-medium text-gray-100">Password</label>
            <div class="text-sm">
              <a href="#" class="font-semibold text-indigo-400 hover:text-indigo-300">Forgot password?</a>
            </div>
          </div>
          <div class="mt-2">
            <input
              type="password"
              name="password"
              id="password"
              autocomplete="current-password"
              required=""
              v-model="data.password"
              class="block w-full rounded-md bg-white/5 px-3 py-1.5 text-base text-white outline-1 -outline-offset-1 outline-white/10 placeholder:text-gray-500 focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-500 sm:text-sm/6" />
          </div>
        </div>

        <div>
          <button type="submit" class="flex w-full justify-center rounded-md bg-indigo-500 px-3 py-1.5 text-sm/6 font-semibold text-white transition hover:bg-indigo-400 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500">Login</button>
        </div>
      </form>

      <p class="mt-10 text-center text-sm/6 text-gray-400">
        Don’t have an account?
        {{ ' ' }}
        <RouterLink :to="{name: 'Register'}" class="font-semibold text-indigo-400 hover:text-indigo-300">Register</RouterLink>
      </p>

    </div>
	</GuestLayout>
</template>

<style scoped>

</style>