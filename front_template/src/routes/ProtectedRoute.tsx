import { Navigate } from 'react-router-dom';
import useAuthStore from '../store/authStore';
import type { MenuItem } from '../types';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredPath?: string;
}

const hasMenuAccess = (menu: MenuItem[], path: string): boolean => {
  for (const item of menu) {
    if (item.path === path) {
      return true;
    }

    if (item.children?.some((child) => child.path === path)) {
      return true;
    }
  }

  return false;
};

const ProtectedRoute = ({ children, requiredPath }: ProtectedRouteProps) => {
  const { isAuthenticated, menu } = useAuthStore();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (requiredPath && menu.length > 0 && !hasMenuAccess(menu, requiredPath)) {
    const fallbackPath = menu[0]?.path || '/';
    return <Navigate to={fallbackPath} replace />;
  }

  return <>{children}</>;
};

export default ProtectedRoute;
