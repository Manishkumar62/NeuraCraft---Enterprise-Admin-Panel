import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import roleService, { type ModulePermission, type AvailablePermission, type UpdatePermissionData } from './services';
import type { Role } from '../../types';
import { ArrowLeftIcon, ChevronDownIcon, ChevronRightIcon } from '@heroicons/react/24/outline';

// Group permissions by category for nice UI
const categoryLabels: Record<string, string> = {
  crud: 'Basic Operations',
  column: 'Column Visibility',
  component: 'Component Visibility',
  action: 'Actions',
  field: 'Field Access',
};

const categoryOrder = ['crud', 'column', 'component', 'action', 'field'];

const RolePermissions = () => {
  const navigate = useNavigate();
  const { id } = useParams();

  const [role, setRole] = useState<Role | null>(null);
  const [permissions, setPermissions] = useState<ModulePermission[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [expandedModules, setExpandedModules] = useState<number[]>([]);

  useEffect(() => {
    fetchData();
  }, [id]);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [roleData, permissionsData] = await Promise.all([
        roleService.getById(Number(id)),
        roleService.getPermissions(Number(id)),
      ]);
      setRole(roleData);
      setPermissions(permissionsData);

      // Expand all modules by default
      setExpandedModules(permissionsData.map((p) => p.module_id));
    } catch (err) {
      setError('Failed to fetch permissions');
    } finally {
      setLoading(false);
    }
  };

  const toggleExpand = (moduleId: number) => {
    setExpandedModules((prev) =>
      prev.includes(moduleId)
        ? prev.filter((id) => id !== moduleId)
        : [...prev, moduleId]
    );
  };

  // Toggle a single permission
  const handlePermissionToggle = (
    moduleId: number,
    codename: string,
    isChild: boolean = false,
    parentId?: number
  ) => {
    setPermissions((prev) =>
      prev.map((perm) => {
        if (isChild && parentId) {
          if (perm.module_id === parentId) {
            return {
              ...perm,
              children: perm.children?.map((child) =>
                child.module_id === moduleId
                  ? {
                    ...child,
                    granted_permissions: child.granted_permissions.includes(codename)
                      ? child.granted_permissions.filter((p) => p !== codename)
                      : [...child.granted_permissions, codename],
                  }
                  : child
              ),
            };
          }
        } else if (perm.module_id === moduleId) {
          return {
            ...perm,
            granted_permissions: perm.granted_permissions.includes(codename)
              ? perm.granted_permissions.filter((p) => p !== codename)
              : [...perm.granted_permissions, codename],
          };
        }
        return perm;
      })
    );
  };

  // Select/deselect all permissions for a module
  const handleSelectAll = (
    moduleId: number,
    availablePermissions: AvailablePermission[],
    selectAll: boolean,
    isChild: boolean = false,
    parentId?: number
  ) => {
    const allCodenames = availablePermissions.map((p) => p.codename);

    setPermissions((prev) =>
      prev.map((perm) => {
        if (isChild && parentId) {
          if (perm.module_id === parentId) {
            return {
              ...perm,
              children: perm.children?.map((child) =>
                child.module_id === moduleId
                  ? {
                    ...child,
                    granted_permissions: selectAll ? allCodenames : [],
                  }
                  : child
              ),
            };
          }
        } else if (perm.module_id === moduleId) {
          return {
            ...perm,
            granted_permissions: selectAll ? allCodenames : [],
          };
        }
        return perm;
      })
    );
  };

  // Select/deselect all permissions in a category
  const handleSelectCategory = (
    moduleId: number,
    category: string,
    availablePermissions: AvailablePermission[],
    selectAll: boolean,
    isChild: boolean = false,
    parentId?: number
  ) => {
    const categoryCodenames = availablePermissions
      .filter((p) => p.category === category)
      .map((p) => p.codename);

    setPermissions((prev) =>
      prev.map((perm) => {
        const updateGranted = (current: string[]) => {
          if (selectAll) {
            return [...new Set([...current, ...categoryCodenames])];
          } else {
            return current.filter((c) => !categoryCodenames.includes(c));
          }
        };

        if (isChild && parentId) {
          if (perm.module_id === parentId) {
            return {
              ...perm,
              children: perm.children?.map((child) =>
                child.module_id === moduleId
                  ? {
                    ...child,
                    granted_permissions: updateGranted(child.granted_permissions),
                  }
                  : child
              ),
            };
          }
        } else if (perm.module_id === moduleId) {
          return {
            ...perm,
            granted_permissions: updateGranted(perm.granted_permissions),
          };
        }
        return perm;
      })
    );
  };

  const handleSave = async () => {
    setError(null);
    setSuccess(null);
    setSaving(true);

    try {
      // Flatten permissions (include both parent and children)
      const allPermissions: UpdatePermissionData[] = [];

      permissions.forEach((perm) => {
        allPermissions.push({
          module_id: perm.module_id,
          granted: perm.granted_permissions,
        });

        perm.children?.forEach((child) => {
          allPermissions.push({
            module_id: child.module_id,
            granted: child.granted_permissions,
          });
        });
      });

      await roleService.updatePermissions(Number(id), allPermissions);
      setSuccess('Permissions saved successfully!');
    } catch (err) {
      setError('Failed to save permissions');
    } finally {
      setSaving(false);
    }
  };

  // Group permissions by category
  const groupByCategory = (perms: AvailablePermission[]) => {
    const grouped: Record<string, AvailablePermission[]> = {};
    perms.forEach((p) => {
      if (!grouped[p.category]) {
        grouped[p.category] = [];
      }
      grouped[p.category].push(p);
    });
    return grouped;
  };

  const renderModulePermissions = (
    perm: ModulePermission,
    isChild: boolean = false,
    parentId?: number
  ) => {
    const grouped = groupByCategory(perm.available_permissions);
    const allGranted =
      perm.available_permissions.length > 0 &&
      perm.available_permissions.every((p) =>
        perm.granted_permissions.includes(p.codename)
      );

    return (
      <div
        key={perm.module_id}
        className={`${isChild ? 'ml-8 border-l-2 border-gray-200 pl-4' : ''} mb-4`}
      >
        {/* Module Header */}
        <div className="flex items-center justify-between bg-gray-50 p-3 rounded-lg">
          <div className="flex items-center gap-2">
            {!isChild && perm.children && perm.children.length > 0 && (
              <button
                onClick={() => toggleExpand(perm.module_id)}
                className="p-1 hover:bg-gray-200 rounded"
              >
                {expandedModules.includes(perm.module_id) ? (
                  <ChevronDownIcon className="w-4 h-4 text-gray-500" />
                ) : (
                  <ChevronRightIcon className="w-4 h-4 text-gray-500" />
                )}
              </button>
            )}
            <span className={`font-medium ${isChild ? 'text-gray-600' : 'text-gray-900'}`}>
              {perm.module_name}
            </span>
            <span className="text-xs text-gray-400">
              ({perm.granted_permissions.length}/{perm.available_permissions.length})
            </span>
          </div>
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={allGranted}
              onChange={(e) =>
                handleSelectAll(
                  perm.module_id,
                  perm.available_permissions,
                  e.target.checked,
                  isChild,
                  parentId
                )
              }
              className="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
            />
            <span className="text-gray-600">Select All</span>
          </label>
        </div>

        {/* Permissions by Category */}
        <div className="mt-2 space-y-3 pl-2">
          {categoryOrder.map((category) => {
            const categoryPerms = grouped[category];
            if (!categoryPerms || categoryPerms.length === 0) return null;

            const allCategoryGranted = categoryPerms.every((p) =>
              perm.granted_permissions.includes(p.codename)
            );

            return (
              <div key={category} className="border-l-2 border-gray-100 pl-3">
                <div className="flex items-center gap-2 mb-2">
                  <label className="flex items-center gap-2">
                    <input
                      type="checkbox"
                      checked={allCategoryGranted}
                      onChange={(e) =>
                        handleSelectCategory(
                          perm.module_id,
                          category,
                          perm.available_permissions,
                          e.target.checked,
                          isChild,
                          parentId
                        )
                      }
                      className="w-3 h-3 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                    />
                    <span className="text-xs font-semibold text-gray-500 uppercase">
                      {categoryLabels[category] || category}
                    </span>
                  </label>
                </div>
                <div className="flex flex-wrap gap-2">
                  {categoryPerms.map((p) => (
                    <label
                      key={p.id}
                      className={`flex items-center gap-2 px-3 py-1.5 rounded-full text-sm cursor-pointer transition-colors ${perm.granted_permissions.includes(p.codename)
                          ? 'bg-blue-100 text-blue-800 border border-blue-300'
                          : 'bg-gray-100 text-gray-600 border border-gray-200 hover:bg-gray-200'
                        }`}
                    >
                      <input
                        type="checkbox"
                        checked={perm.granted_permissions.includes(p.codename)}
                        onChange={() =>
                          handlePermissionToggle(perm.module_id, p.codename, isChild, parentId)
                        }
                        className="sr-only"
                      />
                      {p.label}
                    </label>
                  ))}
                </div>
              </div>
            );
          })}
        </div>

        {/* Children */}
        {!isChild &&
          expandedModules.includes(perm.module_id) &&
          perm.children?.map((child) =>
            renderModulePermissions(child, true, perm.module_id)
          )}
      </div>
    );
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Loading permissions...</div>
      </div>
    );
  }

  return (
    <div>
      <div className="flex items-center gap-4 mb-6">
        <button
          onClick={() => navigate('/roles')}
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
        >
          <ArrowLeftIcon className="w-5 h-5 text-gray-600" />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Manage Permissions</h1>
          <p className="text-gray-600 mt-1">
            Role: <span className="font-medium">{role?.name}</span>
            {role?.department_name && (
              <span className="text-gray-400"> ({role.department_name})</span>
            )}
          </p>
        </div>
      </div>

      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      {success && (
        <div className="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
          {success}
        </div>
      )}

      <div className="bg-white rounded-lg shadow p-6">
        <div className="mb-4 text-sm text-gray-500">
          <p>
            Select the permissions this role should have for each module.
            Permissions are grouped by type for easier management.
          </p>
        </div>

        <div className="space-y-4">
          {permissions.map((perm) => renderModulePermissions(perm))}
        </div>
      </div>

      <div className="flex items-center gap-4 mt-6">
        <button
          onClick={handleSave}
          disabled={saving}
          className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:bg-blue-300 disabled:cursor-not-allowed transition-colors"
        >
          {saving ? 'Saving...' : 'Save Permissions'}
        </button>
        <button
          onClick={() => navigate('/roles')}
          className="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
        >
          Cancel
        </button>
      </div>
    </div>
  );
};

export default RolePermissions;