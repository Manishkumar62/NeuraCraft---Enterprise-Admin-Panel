import api from '../../api/axios';
import type { User } from '../../types';

export interface CreateUserData {
  username: string;
  email: string;
  password: string;
  first_name?: string;
  last_name?: string;
  phone?: string;
  employee_id?: string;
  role?: number | null;
  department?: number | null;
}

export interface UpdateUserData {
  username?: string;
  email?: string;
  first_name?: string;
  last_name?: string;
  phone?: string;
  employee_id?: string;
  role?: number | null;
  department?: number | null;
  is_active?: boolean;
}

const userService = {
  // Get all users
  getAll: async (): Promise<User[]> => {
    const response = await api.get('/users/');
    return response.data;
  },

  // Get single user
  getById: async (id: number): Promise<User> => {
    const response = await api.get(`/users/${id}/`);
    return response.data;
  },

  // Create user
  create: async (data: CreateUserData): Promise<User> => {
    const response = await api.post('/users/register/', data);
    return response.data;
  },

  // Update user
  update: async (id: number, data: UpdateUserData): Promise<User> => {
    const response = await api.put(`/users/${id}/`, data);
    return response.data;
  },

  // Delete user
  delete: async (id: number): Promise<void> => {
    await api.delete(`/users/${id}/`);
  },
};

export default userService;