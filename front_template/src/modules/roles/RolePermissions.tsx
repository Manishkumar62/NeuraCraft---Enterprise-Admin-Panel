import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import roleService, { type ModulePermission, type UpdatePermissionData } from './services';
import type { Role } from '../../types';
import { ArrowLeftIcon, ChevronDownIcon, ChevronRightIcon } from '@heroicons/react/24/outline';

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

  const handlePermissionChange = (
    moduleId: number,
    field: 'can_view' | 'can_add' | 'can_edit' | 'can_delete',
    value: boolean,
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
                child.module_id === moduleId ? { ...child, [field]: value } : child
              ),
            };
          }
        } else if (perm.module_id === moduleId) {
          return { ...perm, [field]: value };
        }
        return perm;
      })
    );
  };

  const handleSelectAll = (
    moduleId: number,
    value: boolean,
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
                      can_view: value,
                      can_add: value,
                      can_edit: value,
                      can_delete: value,
                    }
                  : child
              ),
            };
          }
        } else if (perm.module_id === moduleId) {
          return {
            ...perm,
            can_view: value,
            can_add: value,
            can_edit: value,
            can_delete: value,
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
          can_view: perm.can_view,
          can_add: perm.can_add,
          can_edit: perm.can_edit,
          can_delete: perm.can_delete,
        });

        perm.children?.forEach((child) => {
          allPermissions.push({
            module_id: child.module_id,
            can_view: child.can_view,
            can_add: child.can_add,
            can_edit: child.can_edit,
            can_delete: child.can_delete,
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

  const renderPermissionRow = (
    perm: ModulePermission,
    isChild: boolean = false,
    parentId?: number
  ) => {
    const allChecked =
      perm.can_view && perm.can_add && perm.can_edit && perm.can_delete;

    return (
      <tr
        key={perm.module_id}
        className={`${isChild ? 'bg-gray-50' : 'bg-white'} hover:bg-gray-100`}
      >
        <td className="px-6 py-4 whitespace-nowrap">
          <div
            className="flex items-center gap-2"
            style={{ paddingLeft: isChild ? '24px' : '0' }}
          >
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
            <span className={`text-sm ${isChild ? 'text-gray-600' : 'font-medium text-gray-900'}`}>
              {perm.module_name}
            </span>
          </div>
        </td>
        <td className="px-6 py-4 whitespace-nowrap text-center">
          <input
            type="checkbox"
            checked={perm.can_view}
            onChange={(e) =>
              handlePermissionChange(perm.module_id, 'can_view', e.target.checked, isChild, parentId)
            }
            className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
          />
        </td>
        <td className="px-6 py-4 whitespace-nowrap text-center">
          <input
            type="checkbox"
            checked={perm.can_add}
            onChange={(e) =>
              handlePermissionChange(perm.module_id, 'can_add', e.target.checked, isChild, parentId)
            }
            className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
          />
        </td>
        <td className="px-6 py-4 whitespace-nowrap text-center">
          <input
            type="checkbox"
            checked={perm.can_edit}
            onChange={(e) =>
              handlePermissionChange(perm.module_id, 'can_edit', e.target.checked, isChild, parentId)
            }
            className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
          />
        </td>
        <td className="px-6 py-4 whitespace-nowrap text-center">
          <input
            type="checkbox"
            checked={perm.can_delete}
            onChange={(e) =>
              handlePermissionChange(perm.module_id, 'can_delete', e.target.checked, isChild, parentId)
            }
            className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
          />
        </td>
        <td className="px-6 py-4 whitespace-nowrap text-center">
          <input
            type="checkbox"
            checked={allChecked}
            onChange={(e) =>
              handleSelectAll(perm.module_id, e.target.checked, isChild, parentId)
            }
            className="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
          />
        </td>
      </tr>
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
          <h1 className="text-2xl font-bold text-gray-800">
            Manage Permissions
          </h1>
          <p className="text-gray-600 mt-1">
            Role: <span className="font-medium">{role?.name}</span>
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

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Module
              </th>
              <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                View
              </th>
              <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                Add
              </th>
              <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                Edit
              </th>
              <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                Delete
              </th>
              <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                All
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {permissions.map((perm) => (
              <>
                {renderPermissionRow(perm)}
                {expandedModules.includes(perm.module_id) &&
                  perm.children?.map((child) =>
                    renderPermissionRow(child, true, perm.module_id)
                  )}
              </>
            ))}
          </tbody>
        </table>
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