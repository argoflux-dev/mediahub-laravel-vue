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

// Get the CSRF cookie once when loading the application.
axiosClient.get('/sanctum/csrf-cookie').catch(() => {
	console.error('Could not fetch CSRF cookie — server unavailable?');
});

axiosClient.interceptors.response.use((response) => {
	return response;
}, error => {
	const status = error.response?.status;

	if (status === 401) {
		if (router.currentRoute.value.name !== 'Login') {
			router.push({ name: 'Login' });
		}
	}

	if (status === 500) {
		console.error('Server error:', error.response?.data);
	}

	throw error;
})

export default axiosClient