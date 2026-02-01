import useAuthStore from '../store/authStore';

interface UsePermissionsReturn {
  permissions: string[];
  hasPermission: (permission: string) => boolean;
  hasAnyPermission: (permissions: string[]) => boolean;
  hasAllPermissions: (permissions: string[]) => boolean;
  // Convenience methods for common CRUD operations
  canView: boolean;
  canAdd: boolean;
  canEdit: boolean;
  canDelete: boolean;
}

const usePermissions = (path: string): UsePermissionsReturn => {
  const { menu } = useAuthStore();

  // Find the module by path (check both parent and children)
  let permissions: string[] = [];

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

  // Helper functions
  const hasPermission = (permission: string): boolean => {
    return permissions.includes(permission);
  };

  const hasAnyPermission = (perms: string[]): boolean => {
    return perms.some((p) => permissions.includes(p));
  };

  const hasAllPermissions = (perms: string[]): boolean => {
    return perms.every((p) => permissions.includes(p));
  };

  return {
    permissions,
    hasPermission,
    hasAnyPermission,
    hasAllPermissions,
    // Convenience for CRUD
    canView: permissions.includes('view'),
    canAdd: permissions.includes('add'),
    canEdit: permissions.includes('edit'),
    canDelete: permissions.includes('delete'),
  };
};

export default usePermissions;