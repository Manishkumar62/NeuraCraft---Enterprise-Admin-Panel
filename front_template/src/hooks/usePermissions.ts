import useAuthStore from '../store/authStore';
import type { MenuPermissions } from '../types';

interface UsePermissionsReturn {
  permissions: MenuPermissions | null;
  canView: boolean;
  canAdd: boolean;
  canEdit: boolean;
  canDelete: boolean;
}

const usePermissions = (path: string): UsePermissionsReturn => {
  const { menu } = useAuthStore();

  // Default permissions (no access)
  const defaultPermissions: MenuPermissions = {
    can_view: false,
    can_add: false,
    can_edit: false,
    can_delete: false,
  };

  // Find the module by path (check both parent and children)
  let permissions: MenuPermissions | null = null;

  for (const item of menu) {
    // Check parent module
    if (item.path === path) {
      permissions = item.permissions;
      break;
    }

    // Check children
    if (item.children) {
      const child = item.children.find((c) => c.path === path);
      if (child) {
        permissions = child.permissions;
        break;
      }
    }
  }

  return {
    permissions,
    canView: permissions?.can_view ?? false,
    canAdd: permissions?.can_add ?? false,
    canEdit: permissions?.can_edit ?? false,
    canDelete: permissions?.can_delete ?? false,
  };
};

export default usePermissions;