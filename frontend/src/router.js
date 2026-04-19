import { createRouter, createWebHistory } from "vue-router"
import DefaultLayout from "./components/DefaultLayout.vue"
import Login from "./pages/Login.vue"
import Register from "./pages/Register.vue"
import Home from "./pages/Home.vue"
import Upload from "./pages/Upload.vue"
import NotFound from "./pages/NotFound.vue"
import useUserStore from "./store/user"

const routes = [
	{
		path: "/",
		component: DefaultLayout,
		children: [
			{ path: '/', name: 'Home', component: Home },
			{
				path: '/upload',
				name: 'Upload',
				component: Upload,
				beforeEnter: (to, from, next) => {
					const userStore = useUserStore();
					userStore.user ? next() : next({ name: 'Login' });
				}
			},
		],
		beforeEnter: async (to, from, next) => {
			const userStore = useUserStore();
			await userStore.fetchUser();
			next();
		},
	},
	{
		path: '/login',
		name: 'Login',
		component: Login,
	},
	{
		path: '/register',
		name: 'Register',
		component: Register,
	},
	{
		path: '/:pathMatch(.*)*',
		name: 'NotFound',
		component: NotFound,
	},
];

const router = createRouter({
	history: createWebHistory(),
	routes
})

export default router