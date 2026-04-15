import axios from 'axios'
import router from './router'

const axiosClient = axios.create({
	baseURL: import.meta.env.VITE_API_BASE_URL,
	withCredentials: true,
	withXSRFToken: true,
	headers: {
		'Accept': 'application/json', // This forces Laravel to return errors in JSON instead of redirecting
		'X-Requested-With': 'XMLHttpRequest'
	}
})

// axiosClient.interceptors.request.use(config => {
// 	config.headers.common = `Bearer ${localStorage.getItem('token')}`
// })

axiosClient.interceptors.response.use((response) => {
	return response;
}, error => {
	if (error.response && error.response.status === 401) {
		if (router.currentRoute.value.name !== 'Login') {
			router.push({ name: 'Login' });
		}
	}
	throw error;
})

export default axiosClient