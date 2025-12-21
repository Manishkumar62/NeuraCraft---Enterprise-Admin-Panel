import api from '../api/axios';
import type { LoginCredentials, AuthTokens, RegisterData, User, MenuItem } from '../types';

const authService = {
  // Login user
  login: async (credentials: LoginCredentials): Promise<AuthTokens> => {
    const response = await api.post<AuthTokens>('/users/login/', credentials);
    const { access, refresh } = response.data;

    localStorage.setItem('access_token', access);
    localStorage.setItem('refresh_token', refresh);

    return response.data;
  },

  // Register user
  register: async (data: RegisterData): Promise<User> => {
    const response = await api.post<User>('/users/register/', data);
    return response.data;
  },

  // Get current user profile
  getProfile: async (): Promise<User> => {
    const response = await api.get<User>('/users/profile/');
    return response.data;
  },

  // Get user's menu based on role
  getMyMenu: async (): Promise<MenuItem[]> => {
    const response = await api.get<MenuItem[]>('/modules/my-menu/');
    return response.data;
  },

  // Logout user
  logout: (): void => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
  },

  // Check if user is logged in
  isAuthenticated: (): boolean => {
    return !!localStorage.getItem('access_token');
  },
};

export default authService;