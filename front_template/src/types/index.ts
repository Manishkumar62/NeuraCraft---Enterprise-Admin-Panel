// User types
export interface User {
  id: number;
  username: string;
  email: string;
  first_name: string;
  last_name: string;
  phone: string;
  employee_id: string;
  role: Role | null;
  department: Department | null;
  is_active: boolean;
  date_joined: string;
}

// Role types
export interface Role {
  id: number;
  name: string;
  description: string;
  is_active: boolean;
  created_at: string;
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

// Menu item from /my-menu/ API
export interface MenuPermissions {
  can_view: boolean;
  can_add: boolean;
  can_edit: boolean;
  can_delete: boolean;
}

export interface MenuItem {
  id: number;
  module_name: string;
  icon: string;
  path: string;
  order: number;
  permissions: MenuPermissions;
  children: MenuItem[];
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