import api from '../../api/axios';
import type { Role } from '../../types';

export interface CreateRoleData {
  name: string;
  description?: string;
  is_active?: boolean;
}

export interface UpdateRoleData {
  name?: string;
  description?: string;
  is_active?: boolean;
}

const roleService = {
  getAll: async (): Promise<Role[]> => {
    const response = await api.get('/roles/');
    return response.data;
  },

  getById: async (id: number): Promise<Role> => {
    const response = await api.get(`/roles/${id}/`);
    return response.data;
  },

  create: async (data: CreateRoleData): Promise<Role> => {
    const response = await api.post('/roles/', data);
    return response.data;
  },

  update: async (id: number, data: UpdateRoleData): Promise<Role> => {
    const response = await api.put(`/roles/${id}/`, data);
    return response.data;
  },

  delete: async (id: number): Promise<void> => {
    await api.delete(`/roles/${id}/`);
  },
};

export default roleService;