import { Routes, Route, Navigate } from 'react-router-dom';
import AuthLayout from '../layouts/AuthLayout';
import MainLayout from '../layouts/MainLayout';
import LoginPage from '../auth/LoginPage';
import DashboardPage from '../modules/dashboard/DashboardPage';
import UserList from '../modules/users/UserList';
import UserForm from '../modules/users/UserForm';
import RoleList from '../modules/roles/RoleList';
import RoleForm from '../modules/roles/RoleForm';
import RolePermissions from '../modules/roles/RolePermissions';
import DepartmentList from '../modules/departments/DepartmentList';
import DepartmentForm from '../modules/departments/DepartmentForm';
import ModuleList from '../modules/modules/ModuleList';
import ModuleForm from '../modules/modules/ModuleForm';

const AppRoutes = () => {
  return (
    <Routes>
      {/* Auth Routes (Login, Register) */}
      <Route element={<AuthLayout />}>
        <Route path="/login" element={<LoginPage />} />
      </Route>

      {/* Protected Routes (Dashboard, Users, etc.) */}
      <Route element={<MainLayout />}>
        <Route path="/dashboard" element={<DashboardPage />} />

        {/* Users Routes */}
        <Route path="/users" element={<UserList />} />
        <Route path="/users/add" element={<UserForm />} />
        <Route path="/users/edit/:id" element={<UserForm />} />

        {/* Roles Routes */}
        <Route path="/roles" element={<RoleList />} />
        <Route path="/roles/add" element={<RoleForm />} />
        <Route path="/roles/edit/:id" element={<RoleForm />} />
        <Route path="/roles/:id/permissions" element={<RolePermissions />} />

        {/* Departments Routes */}
        <Route path="/departments" element={<DepartmentList />} />
        <Route path="/departments/add" element={<DepartmentForm />} />
        <Route path="/departments/edit/:id" element={<DepartmentForm />} />

        {/* Modules Routes */}
        <Route path="/modules" element={<ModuleList />} />
        <Route path="/modules/add" element={<ModuleForm />} />
        <Route path="/modules/edit/:id" element={<ModuleForm />} />
      </Route>

      {/* Default Redirect */}
      <Route path="/" element={<Navigate to="/dashboard" replace />} />
      
      {/* 404 - Not Found */}
      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
};

export default AppRoutes;