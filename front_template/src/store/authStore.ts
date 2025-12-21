import { create } from 'zustand';
import type { User, MenuItem } from '../types';
import authService from '../auth/authService';

interface AuthState {
  user: User | null;
  menu: MenuItem[];
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;

  // Actions
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
  fetchProfile: () => Promise<void>;
  fetchMenu: () => Promise<void>;
  clearError: () => void;
}

const useAuthStore = create<AuthState>((set) => ({
  user: null,
  menu: [],
  isAuthenticated: authService.isAuthenticated(),
  isLoading: false,
  error: null,

  login: async (username: string, password: string) => {
    set({ isLoading: true, error: null });
    try {
      await authService.login({ username, password });
      const user = await authService.getProfile();
      const menu = await authService.getMyMenu();
      set({ user, menu, isAuthenticated: true, isLoading: false });
    } catch (error: any) {
      const message = error.response?.data?.detail || 'Login failed';
      set({ error: message, isLoading: false });
      throw error;
    }
  },

  logout: () => {
    authService.logout();
    set({ user: null, menu: [], isAuthenticated: false });
  },

  fetchProfile: async () => {
    set({ isLoading: true });
    try {
      const user = await authService.getProfile();
      set({ user, isLoading: false });
    } catch (error) {
      set({ isLoading: false });
    }
  },

  fetchMenu: async () => {
    try {
      const menu = await authService.getMyMenu();
      set({ menu });
    } catch (error) {
      console.error('Failed to fetch menu:', error);
    }
  },

  clearError: () => set({ error: null }),
}));

export default useAuthStore;