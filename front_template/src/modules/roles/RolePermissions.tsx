import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import roleService, {
  type ModulePermission,
  type AvailablePermission,
  type UpdatePermissionData,
} from './services';
import type { Role } from '../../types';
import {
  ArrowLeftIcon,
  ChevronDownIcon,
  ChevronRightIcon,
  ShieldCheckIcon,
  CheckIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  Squares2X2Icon,
} from '@heroicons/react/24/outline';

// Category configuration
const categoryConfig: Record<string, { label: string; color: string }> = {
  crud: { label: 'CRUD', color: 'var(--color-accent)' },
  column: { label: 'Columns', color: 'var(--color-info)' },
  component: { label: 'Components', color: 'var(--color-warning)' },
  action: { label: 'Actions', color: 'var(--color-success)' },
  field: { label: 'Fields', color: 'var(--color-error)' },
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
      setExpandedModules(permissionsData.map((p) => p.module_id));
    } catch (err) {
      setError('Failed to fetch permissions');
    } finally {
      setLoading(false);
    }
  };

  const toggleExpand = (moduleId: number) => {
    setExpandedModules((prev) =>
      prev.includes(moduleId) ? prev.filter((id) => id !== moduleId) : [...prev, moduleId]
    );
  };

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
                  ? { ...child, granted_permissions: selectAll ? allCodenames : [] }
                  : child
              ),
            };
          }
        } else if (perm.module_id === moduleId) {
          return { ...perm, granted_permissions: selectAll ? allCodenames : [] };
        }
        return perm;
      })
    );
  };

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
          }
          return current.filter((c) => !categoryCodenames.includes(c));
        };

        if (isChild && parentId) {
          if (perm.module_id === parentId) {
            return {
              ...perm,
              children: perm.children?.map((child) =>
                child.module_id === moduleId
                  ? { ...child, granted_permissions: updateGranted(child.granted_permissions) }
                  : child
              ),
            };
          }
        } else if (perm.module_id === moduleId) {
          return { ...perm, granted_permissions: updateGranted(perm.granted_permissions) };
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
      const allPermissions: UpdatePermissionData[] = [];
      permissions.forEach((perm) => {
        allPermissions.push({ module_id: perm.module_id, granted: perm.granted_permissions });
        perm.children?.forEach((child) => {
          allPermissions.push({ module_id: child.module_id, granted: child.granted_permissions });
        });
      });

      await roleService.updatePermissions(Number(id), allPermissions);
      setSuccess('Permissions saved successfully!');
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      setError('Failed to save permissions');
    } finally {
      setSaving(false);
    }
  };

  const groupByCategory = (perms: AvailablePermission[]) => {
    const grouped: Record<string, AvailablePermission[]> = {};
    perms.forEach((p) => {
      if (!grouped[p.category]) grouped[p.category] = [];
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
      perm.available_permissions.every((p) => perm.granted_permissions.includes(p.codename));
    const someGranted = perm.granted_permissions.length > 0 && !allGranted;
    const hasChildren = !isChild && perm.children && perm.children.length > 0;
    const isExpanded = expandedModules.includes(perm.module_id);

    return (
      <div key={perm.module_id} className={`${isChild ? 'ml-6 mt-2' : ''}`}>
        {/* Module Header */}
        <div
          className={`
            flex items-center gap-3 p-3 rounded-xl transition-colors
            ${isChild ? 'bg-[var(--color-surface-elevated)]/50' : 'bg-[var(--color-surface-elevated)]'}
          `}
        >
          {/* Expand Button */}
          {hasChildren && (
            <button
              onClick={() => toggleExpand(perm.module_id)}
              className="p-1 hover:bg-[var(--color-surface-hover)] rounded-lg transition-colors"
            >
              {isExpanded ? (
                <ChevronDownIcon className="w-4 h-4 text-[var(--color-text-muted)]" />
              ) : (
                <ChevronRightIcon className="w-4 h-4 text-[var(--color-text-muted)]" />
              )}
            </button>
          )}
          {!hasChildren && !isChild && <div className="w-6" />}

          {/* Module Icon */}
          <div
            className={`
              w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0
              ${isChild ? 'bg-[var(--color-surface)]' : 'bg-gradient-to-br from-[var(--color-accent)] to-violet-600'}
            `}
          >
            <Squares2X2Icon className={`w-4 h-4 ${isChild ? 'text-[var(--color-text-muted)]' : 'text-white'}`} />
          </div>

          {/* Module Name & Count */}
          <div className="flex-1 min-w-0">
            <span className={`text-sm font-medium ${isChild ? 'text-[var(--color-text-secondary)]' : 'text-[var(--color-text-primary)]'}`}>
              {perm.module_name}
            </span>
            <span className="ml-2 text-xs text-[var(--color-text-muted)]">
              {perm.granted_permissions.length}/{perm.available_permissions.length}
            </span>
          </div>

          {/* Select All Toggle */}
          <button
            onClick={() =>
              handleSelectAll(perm.module_id, perm.available_permissions, !allGranted, isChild, parentId)
            }
            className={`
              flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-medium transition-colors
              ${allGranted
                ? 'bg-[var(--color-success)] text-white'
                : someGranted
                  ? 'bg-[var(--color-accent-muted)] text-[var(--color-accent)]'
                  : 'bg-[var(--color-surface)] text-[var(--color-text-muted)] hover:text-[var(--color-text-secondary)]'
              }
            `}
          >
            {allGranted && <CheckIcon className="w-3 h-3" />}
            {allGranted ? 'All' : 'Select All'}
          </button>
        </div>

        {/* Permissions Grid */}
        <div className="mt-2 pl-3 space-y-2">
          {categoryOrder.map((category) => {
            const categoryPerms = grouped[category];
            if (!categoryPerms || categoryPerms.length === 0) return null;

            const config = categoryConfig[category] || { label: category, color: 'var(--color-text-muted)' };
            const allCategoryGranted = categoryPerms.every((p) =>
              perm.granted_permissions.includes(p.codename)
            );

            return (
              <div key={category} className="flex items-start gap-2">
                {/* Category Label */}
                <button
                  onClick={() =>
                    handleSelectCategory(
                      perm.module_id,
                      category,
                      perm.available_permissions,
                      !allCategoryGranted,
                      isChild,
                      parentId
                    )
                  }
                  className={`
                    flex-shrink-0 px-2 py-1 rounded-md text-[10px] font-semibold uppercase tracking-wider transition-colors
                    ${allCategoryGranted
                      ? 'text-white'
                      : 'text-[var(--color-text-muted)] hover:text-[var(--color-text-secondary)]'
                    }
                  `}
                  style={{
                    backgroundColor: allCategoryGranted ? config.color : 'var(--color-surface-elevated)',
                    minWidth: '72px',
                  }}
                >
                  {config.label}
                </button>

                {/* Permission Pills */}
                <div className="flex flex-wrap gap-1.5">
                  {categoryPerms.map((p) => {
                    const isGranted = perm.granted_permissions.includes(p.codename);
                    return (
                      <button
                        key={p.id}
                        onClick={() => handlePermissionToggle(perm.module_id, p.codename, isChild, parentId)}
                        className={`
                          px-2.5 py-1 rounded-md text-xs font-medium transition-all duration-150
                          ${isGranted
                            ? 'bg-[var(--color-accent)] text-white shadow-sm shadow-[var(--color-accent)]/30'
                            : 'bg-[var(--color-surface)] text-[var(--color-text-muted)] hover:text-[var(--color-text-secondary)] hover:bg-[var(--color-surface-hover)]'
                          }
                        `}
                      >
                        {p.label}
                      </button>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </div>

        {/* Children */}
        {hasChildren && isExpanded && (
          <div className="border-l-2 border-[var(--color-border)] ml-4 mt-2 space-y-2">
            {perm.children?.map((child) => renderModulePermissions(child, true, perm.module_id))}
          </div>
        )}
      </div>
    );
  };

  // Loading State
  if (loading) {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <div className="skeleton w-10 h-10 rounded-xl" />
          <div className="space-y-2">
            <div className="skeleton h-7 w-48 rounded-lg" />
            <div className="skeleton h-4 w-32 rounded" />
          </div>
        </div>
        <div className="card p-6 space-y-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="space-y-2">
              <div className="skeleton h-12 w-full rounded-xl" />
              <div className="flex gap-2 ml-3">
                <div className="skeleton h-7 w-16 rounded-md" />
                <div className="skeleton h-7 w-20 rounded-md" />
                <div className="skeleton h-7 w-24 rounded-md" />
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  // Calculate total stats
  const totalPermissions = permissions.reduce((acc, p) => {
    let count = p.available_permissions.length;
    p.children?.forEach((c) => (count += c.available_permissions.length));
    return acc + count;
  }, 0);

  const grantedPermissions = permissions.reduce((acc, p) => {
    let count = p.granted_permissions.length;
    p.children?.forEach((c) => (count += c.granted_permissions.length));
    return acc + count;
  }, 0);

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex items-start justify-between animate-fade-in">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate('/roles')}
            className="p-2.5 text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)] rounded-xl transition-colors"
          >
            <ArrowLeftIcon className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Manage Permissions</h1>
            <div className="flex items-center gap-2 mt-1">
              <span className="text-sm text-[var(--color-text-muted)]">Role:</span>
              <span className="text-sm font-medium text-[var(--color-accent)]">{role?.name}</span>
              {role?.department_name && (
                <span className="badge badge-info text-[10px]">{role.department_name}</span>
              )}
            </div>
          </div>
        </div>

        {/* Stats */}
        <div className="flex items-center gap-4">
          <div className="text-right">
            <p className="text-2xl font-bold text-[var(--color-text-primary)]">
              {grantedPermissions}
              <span className="text-sm font-normal text-[var(--color-text-muted)]">/{totalPermissions}</span>
            </p>
            <p className="text-xs text-[var(--color-text-muted)]">Permissions granted</p>
          </div>
          <div
            className="w-12 h-12 rounded-xl flex items-center justify-center"
            style={{
              background: `conic-gradient(var(--color-accent) ${(grantedPermissions / totalPermissions) * 100}%, var(--color-surface-elevated) 0)`,
            }}
          >
            <div className="w-9 h-9 rounded-lg bg-[var(--color-surface)] flex items-center justify-center">
              <ShieldCheckIcon className="w-5 h-5 text-[var(--color-accent)]" />
            </div>
          </div>
        </div>
      </div>

      {/* Alerts */}
      {error && (
        <div className="alert alert-error animate-fade-in-down">
          <ExclamationTriangleIcon className="w-5 h-5 flex-shrink-0" />
          <span>{error}</span>
          <button onClick={() => setError(null)} className="ml-auto p-1 hover:opacity-70">
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      )}

      {success && (
        <div className="alert alert-success animate-fade-in-down">
          <CheckCircleIcon className="w-5 h-5 flex-shrink-0" />
          <span>{success}</span>
        </div>
      )}

      {/* Permissions Card */}
      <div className="card animate-fade-in-up">
        <div className="p-4 border-b border-[var(--color-border)]">
          <p className="text-sm text-[var(--color-text-muted)]">
            Configure what this role can access. Click permission pills to toggle, or use category/module buttons for bulk actions.
          </p>
        </div>

        <div className="p-4 space-y-4">
          {permissions.map((perm) => renderModulePermissions(perm))}
        </div>
      </div>

      {/* Action Buttons - Sticky */}
      <div className="sticky bottom-4 flex items-center justify-end gap-3">
        <div className="flex items-center gap-3 p-3 rounded-2xl bg-[var(--color-surface)]/90 backdrop-blur-xl border border-[var(--color-border)] shadow-xl">
          <button onClick={() => navigate('/roles')} className="btn btn-secondary">
            Cancel
          </button>
          <button onClick={handleSave} disabled={saving} className="btn btn-primary min-w-[140px]">
            {saving ? (
              <>
                <div className="spinner" />
                <span>Saving...</span>
              </>
            ) : (
              <>
                <CheckIcon className="w-4 h-4" />
                <span>Save Permissions</span>
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
};

export default RolePermissions;