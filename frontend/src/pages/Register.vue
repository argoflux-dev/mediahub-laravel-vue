<script setup>
import axiosClient from '../axios';
import GuestLayout from '../components/GuestLayout.vue'
import { ref } from 'vue'

const data = ref({
  name: '',
  email: '',
  password: '',
  password_confirmation: '',
})

const errors = ref({
  name: [],
  email: [],
  password: [],
})

function submit() {
  axiosClient.get('/sanctum/csrf-cookie').then(response => {
    axiosClient.post('/register', data.value)
      // .then(response => {
      //   console.log('Success:', response.data)
      // })
      .catch(error => {
        errors.value = error.response.data.errors;
      })
  });
}

</script>

<template>
	<GuestLayout>
		<h2 class="mt-10 text-center text-2xl/9 font-bold tracking-tight text-white">Create new account</h2>
    <div class="mt-10 sm:mx-auto sm:w-full sm:max-w-sm">
      <form @submit.prevent="submit" class="space-y-4">
        <div>
          <label for="name" class="block text-sm/6 text-left font-medium text-gray-100">Full name</label>
          <div class="mt-2">
            <input
              name="name"
              id="name"
              v-model="data.name"
              class="block w-full rounded-md bg-white/5 px-3 py-1.5 text-base text-white outline-1 -outline-offset-1 outline-white/10 placeholder:text-gray-500 focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-500 sm:text-sm/6" />
          </div>
          <p v-if="errors.name?.length" class="text-red-500 text-left font-regular text-sm">{{ errors.name[0] }}</p>
        </div>

        <div>
          <label for="email" class="block text-sm/6 text-left font-medium text-gray-100">Email address</label>
          <div class="mt-2">
            <input
              type="email"
              name="email"
              id="email"
              autocomplete="email"
              v-model="data.email"
              class="block w-full rounded-md bg-white/5 px-3 py-1.5 text-base text-white outline-1 -outline-offset-1 outline-white/10 placeholder:text-gray-500 focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-500 sm:text-sm/6" />
          </div>
          <p v-if="errors.email?.length" class="text-red-500 text-left font-regular text-sm">{{ errors.email[0] }}</p>
        </div>

        <div>
          <div class="flex items-center justify-between">
            <label for="password" class="block text-sm/6 font-medium text-gray-100">Password</label>
          </div>
          <div class="mt-2">
            <input
              type="password"
              name="password"
              id="password"
              v-model="data.password"
              class="block w-full rounded-md bg-white/5 px-3 py-1.5 text-base text-white outline-1 -outline-offset-1 outline-white/10 placeholder:text-gray-500 focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-500 sm:text-sm/6" />
          </div>
          <p v-if="errors.password?.length" class="text-red-500 text-left font-regular text-sm">{{ errors.password[0] }}</p>
        </div>

        <div>
          <div class="flex items-center justify-between">
            <label for="password_confirmation" class="block text-sm/6 font-medium text-gray-100">Confirm password</label>
          </div>
          <div class="mt-2">
            <input
              type="password"
              name="password_confirmation"
              id="password_confirmation"
              v-model="data.password_confirmation"
              class="block w-full rounded-md bg-white/5 px-3 py-1.5 text-base text-white outline-1 -outline-offset-1 outline-white/10 placeholder:text-gray-500 focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-500 sm:text-sm/6" />
          </div>
        </div>

        <div>
          <button type="submit" class="flex w-full justify-center rounded-md bg-indigo-500 px-3 py-1.5 text-sm/6 font-semibold text-white transition hover:bg-indigo-400 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500">Register</button>
        </div>
      </form>

      <p class="mt-10 text-center text-sm/6 text-gray-400">
        Already have an account?
        {{ ' ' }}
        <RouterLink :to="{name: 'Login'}" class="font-semibold text-indigo-400 hover:text-indigo-300">Login</RouterLink>
      </p>

    </div>
	</GuestLayout>
</template>

<style scoped>

</style>