import api from '../../api/axios';
import type { Department } from '../../types';

export interface CreateDepartmentData {
  name: string;
  code: string;
  description?: string;
  is_active?: boolean;
}

export interface UpdateDepartmentData {
  name?: string;
  code?: string;
  description?: string;
  is_active?: boolean;
}

const departmentService = {
  getAll: async (): Promise<Department[]> => {
    const response = await api.get('/departments/');
    return response.data;
  },

  getById: async (id: number): Promise<Department> => {
    const response = await api.get(`/departments/${id}/`);
    return response.data;
  },

  create: async (data: CreateDepartmentData): Promise<Department> => {
    const response = await api.post('/departments/', data);
    return response.data;
  },

  update: async (id: number, data: UpdateDepartmentData): Promise<Department> => {
    const response = await api.put(`/departments/${id}/`, data);
    return response.data;
  },

  delete: async (id: number): Promise<void> => {
    await api.delete(`/departments/${id}/`);
  },
};

export default departmentService;