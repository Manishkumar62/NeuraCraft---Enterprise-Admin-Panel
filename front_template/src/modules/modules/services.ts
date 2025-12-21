import api from '../../api/axios';
import type { Module } from '../../types';

export interface CreateModuleData {
  name: string;
  icon: string;
  path: string;
  parent?: number | null;
  order?: number;
  is_active?: boolean;
}

export interface UpdateModuleData {
  name?: string;
  icon?: string;
  path?: string;
  parent?: number | null;
  order?: number;
  is_active?: boolean;
}

const moduleService = {
  getAll: async (): Promise<Module[]> => {
    const response = await api.get('/modules/');
    return response.data;
  },

  getById: async (id: number): Promise<Module> => {
    const response = await api.get(`/modules/${id}/`);
    return response.data;
  },

  create: async (data: CreateModuleData): Promise<Module> => {
    const response = await api.post('/modules/', data);
    return response.data;
  },

  update: async (id: number, data: UpdateModuleData): Promise<Module> => {
    const response = await api.put(`/modules/${id}/`, data);
    return response.data;
  },

  delete: async (id: number): Promise<void> => {
    await api.delete(`/modules/${id}/`);
  },
};

export default moduleService;