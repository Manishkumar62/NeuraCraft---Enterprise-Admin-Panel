import api from '../../api/axios';
import type { Role } from '../../types';

export interface CreateRoleData {
  name: string;
  description?: string;
  department?: number | null;
  is_active?: boolean;
}

export interface UpdateRoleData {
  name?: string;
  description?: string;
  department?: number | null;
  is_active?: boolean;
}

// Available permission definition (from backend)
export interface AvailablePermission {
  id: number;
  codename: string;
  label: string;
  category: 'crud' | 'column' | 'component' | 'action' | 'field';
}

// Module with its permissions (for role assignment screen)
export interface ModulePermission {
  module_id: number;
  module_name: string;
  available_permissions: AvailablePermission[];
  granted_permissions: string[];  // codenames that are granted
  children?: ModulePermission[];
}

// Request type for updating permissions
export interface UpdatePermissionData {
  module_id: number;
  granted: string[];  // Array of permission codenames
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

  // Permissions (dynamic)
  getPermissions: async (roleId: number): Promise<ModulePermission[]> => {
    const response = await api.get(`/roles/${roleId}/permissions/`);
    return response.data;
  },

  updatePermissions: async (roleId: number, permissions: UpdatePermissionData[]): Promise<void> => {
    await api.post(`/roles/${roleId}/permissions/`, { permissions });
  },
};

export default roleService;