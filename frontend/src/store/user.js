import { defineStore } from 'pinia';
import axiosClient from '../axios';

const useUserStore = defineStore('user', {
	state: () => ({
		user: null
	}),
	actions: {
		async fetchUser() {
			try {
				const { data } = await axiosClient.get('/api/user');
				this.user = data;
			} catch {
				this.user = null;
			}
		}
	}
});

export default useUserStore;