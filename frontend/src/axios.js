import axios from 'axios'
import router from './router'

const axiosClient = axios.create({
	baseURL: '/api', //import.meta.env.VITE_API_BASE_URL,
	withCredentials: true,
	withXSRFToken: true
})

// axiosClient.interceptors.request.use(config => {
// 	config.headers.common = `Bearer ${localStorage.getItem('token')}`
// })

axiosClient.interceptors.response.use((response) => {
	return response;
}, error => {
	if (error.response && error.response.status === 401) {
		router.push({ name: 'Login' });
	}

	throw error;
})

export default axiosClient