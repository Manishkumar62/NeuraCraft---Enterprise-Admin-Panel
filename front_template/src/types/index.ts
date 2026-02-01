// User types
export interface User {
  id: number;
  username: string;
  email: string;
  first_name: string;
  last_name: string;
  phone: string;
  employee_id: string;
  roles: Role[];
  department: Department | null;
  is_active: boolean;
  date_joined: string;
}

// Role types
export interface Role {
  id: number;
  name: string;
  description: string;
  department?: number | null;
  department_name?: string;
  is_active: boolean;
  created_at: string;
  updated_at?: string;
}

// Department types
export interface Department {
  id: number;
  name: string;
  code: string;
  description: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

// Module types
export interface Module {
  id: number;
  name: string;
  icon: string;
  path: string;
  parent: number | null;
  order: number;
  is_active: boolean;
  children?: Module[];
}

// Menu item from /my-menu/ API (UPDATED: permissions is now string array)
export interface MenuItem {
  id: number;
  module_name: string;
  icon: string;
  path: string;
  order: number;
  permissions: string[];  // Changed from MenuPermissions object to string[]
  children: MenuItem[];
}

// Available permission definition (for role assignment screen)
export interface AvailablePermission {
  id: number;
  codename: string;
  label: string;
  category: 'crud' | 'column' | 'component' | 'action' | 'field';
}

// Module with its available permissions (for role assignment screen)
export interface ModulePermissionConfig {
  module_id: number;
  module_name: string;
  available_permissions: AvailablePermission[];
  granted_permissions: string[];  // codenames that are granted
  children?: ModulePermissionConfig[];
}

// Auth types
export interface LoginCredentials {
  username: string;
  password: string;
}

export interface AuthTokens {
  access: string;
  refresh: string;
}

export interface RegisterData {
  username: string;
  email: string;
  password: string;
  first_name?: string;
  last_name?: string;
}