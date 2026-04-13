import { createRouter, createWebHistory } from "vue-router"
import DefaultLayout from "./components/DefaultLayout.vue"
import Login from "./pages/Login.vue"
import Register from "./pages/Register.vue"
import Home from "./pages/Home.vue"
import MyImages from "./pages/MyImages.vue"
import NotFound from "./pages/NotFound.vue"

const routes = [
	{
		path: '/',
		component: DefaultLayout,
		children: [
			{ path: '/', name: 'Home', component: Home },
			{ path: '/images', name: 'My Images', component: MyImages },
		]
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