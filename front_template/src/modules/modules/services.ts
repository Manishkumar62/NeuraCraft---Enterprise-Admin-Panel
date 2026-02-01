import api from '../../api/axios';
import type { Module } from '../../types';

export interface PermissionData {
  id?: number;
  codename: string;
  label: string;
  category: 'crud' | 'column' | 'component' | 'action' | 'field';
  order?: number;
}

export interface ModuleWithPermissions {
  id: number;
  name: string;
  icon: string;
  path: string;
  parent: number | null;
  order: number;
  is_active: boolean;
  permissions: PermissionData[];
}

export interface CreateModuleData {
  name: string;
  icon: string;
  path: string;
  parent?: number | null;
  order?: number;
  is_active?: boolean;
  permissions?: PermissionData[];
}

export interface UpdateModuleData {
  name?: string;
  icon?: string;
  path?: string;
  parent?: number | null;
  order?: number;
  is_active?: boolean;
  permissions?: PermissionData[];
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

  // Get module with its permissions
  getWithPermissions: async (id: number): Promise<ModuleWithPermissions> => {
    const response = await api.get(`/modules/${id}/with-permissions/`);
    return response.data;
  },

  // Create module with permissions
  createWithPermissions: async (data: CreateModuleData): Promise<ModuleWithPermissions> => {
    const response = await api.post('/modules/create-with-permissions/', data);
    return response.data;
  },

  // Update module with permissions
  updateWithPermissions: async (id: number, data: UpdateModuleData): Promise<ModuleWithPermissions> => {
    const response = await api.put(`/modules/${id}/update-with-permissions/`, data);
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