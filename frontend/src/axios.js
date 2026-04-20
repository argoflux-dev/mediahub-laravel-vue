import axios from 'axios'
import router from './router'

const axiosClient = axios.create({
	baseURL: import.meta.env.VITE_API_BASE_URL,

	// For Session-based authentication
	// withCredentials: true,
	// withXSRFToken: true,
	// headers: {
	// 	'Accept': 'application/json', // This forces Laravel to return errors in JSON instead of redirecting
	// 	'X-Requested-With': 'XMLHttpRequest'
	// }
});

// For Token-based authentication
axiosClient.interceptors.request.use(config => {
	const token = localStorage.getItem('token');
	if (token) {
		config.headers.Authorization = `Bearer ${token}`;
	}
	return config;
});

// Session-based authentication: Get the CSRF cookie once when loading the application.
// axiosClient.get('/sanctum/csrf-cookie').catch(() => {
// 	console.error('Could not fetch CSRF cookie — server unavailable?');
// });

axiosClient.interceptors.response.use((response) => {
	return response;
}, error => {
	const status = error.response?.status;

	if (status === 500) {
		console.error('Server error:', error.response?.data);
	}

	throw error;
})

export default axiosClient