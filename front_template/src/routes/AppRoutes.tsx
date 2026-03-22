import { Routes, Route, Navigate } from 'react-router-dom';
import AuthLayout from '../layouts/AuthLayout';
import MainLayout from '../layouts/MainLayout';
import LoginPage from '../auth/LoginPage';
import SignupPage from '../auth/SignupPage';
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
import ProtectedRoute from './ProtectedRoute';

const AppRoutes = () => {
  return (
    <Routes>
      {/* Auth Routes (Login, Register) */}
      <Route element={<AuthLayout />}>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/signup" element={<SignupPage />} />
      </Route>

      {/* Protected Routes (Dashboard, Users, etc.) */}
      <Route element={<ProtectedRoute><MainLayout /></ProtectedRoute>}>
        <Route
          path="/dashboard"
          element={<ProtectedRoute requiredPath="/dashboard"><DashboardPage /></ProtectedRoute>}
        />

        {/* Users Routes */}
        <Route
          path="/users"
          element={<ProtectedRoute requiredPath="/users"><UserList /></ProtectedRoute>}
        />
        <Route
          path="/users/add"
          element={<ProtectedRoute requiredPath="/users"><UserForm /></ProtectedRoute>}
        />
        <Route
          path="/users/edit/:id"
          element={<ProtectedRoute requiredPath="/users"><UserForm /></ProtectedRoute>}
        />

        {/* Roles Routes */}
        <Route
          path="/roles"
          element={<ProtectedRoute requiredPath="/roles"><RoleList /></ProtectedRoute>}
        />
        <Route
          path="/roles/add"
          element={<ProtectedRoute requiredPath="/roles"><RoleForm /></ProtectedRoute>}
        />
        <Route
          path="/roles/edit/:id"
          element={<ProtectedRoute requiredPath="/roles"><RoleForm /></ProtectedRoute>}
        />
        <Route
          path="/roles/:id/permissions"
          element={<ProtectedRoute requiredPath="/roles"><RolePermissions /></ProtectedRoute>}
        />

        {/* Departments Routes */}
        <Route
          path="/departments"
          element={<ProtectedRoute requiredPath="/departments"><DepartmentList /></ProtectedRoute>}
        />
        <Route
          path="/departments/add"
          element={<ProtectedRoute requiredPath="/departments"><DepartmentForm /></ProtectedRoute>}
        />
        <Route
          path="/departments/edit/:id"
          element={<ProtectedRoute requiredPath="/departments"><DepartmentForm /></ProtectedRoute>}
        />

        {/* Modules Routes */}
        <Route
          path="/modules"
          element={<ProtectedRoute requiredPath="/modules"><ModuleList /></ProtectedRoute>}
        />
        <Route
          path="/modules/add"
          element={<ProtectedRoute requiredPath="/modules"><ModuleForm /></ProtectedRoute>}
        />
        <Route
          path="/modules/edit/:id"
          element={<ProtectedRoute requiredPath="/modules"><ModuleForm /></ProtectedRoute>}
        />
      </Route>

      {/* Default Redirect */}
      <Route path="/" element={<Navigate to="/dashboard" replace />} />
      
      {/* 404 - Not Found */}
      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
};

export default AppRoutes;
