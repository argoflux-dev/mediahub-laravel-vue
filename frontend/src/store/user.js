import { defineStore } from 'pinia';
import axiosClient from '../axios';

const useUserStore = defineStore('user', {
	state: () => ({
		user: null
	}),
	actions: {
		async fetchUser() {
			const { data } = await axiosClient.get('/api/user');
			this.user = data;
		}
	}
});

export default useUserStore;