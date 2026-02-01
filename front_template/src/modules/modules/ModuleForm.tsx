import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import moduleService, { type PermissionData } from './services';
import type { Module } from '../../types';
import {
  ArrowLeftIcon,
  PlusIcon,
  XMarkIcon,
  Squares2X2Icon,
  FolderIcon,
  LinkIcon,
  HashtagIcon,
  ExclamationTriangleIcon,
  CheckIcon,
  SparklesIcon,
} from '@heroicons/react/24/outline';

// Preset permissions
const PRESET_PERMISSIONS: PermissionData[] = [
  { codename: 'view', label: 'View', category: 'crud' },
  { codename: 'add', label: 'Add', category: 'crud' },
  { codename: 'edit', label: 'Edit', category: 'crud' },
  { codename: 'delete', label: 'Delete', category: 'crud' },
  { codename: 'export_csv', label: 'Export CSV', category: 'action' },
  { codename: 'export_pdf', label: 'Export PDF', category: 'action' },
  { codename: 'export_excel', label: 'Export Excel', category: 'action' },
  { codename: 'import', label: 'Import', category: 'action' },
  { codename: 'print', label: 'Print', category: 'action' },
];

const CATEGORY_CONFIG: Record<string, { label: string; color: string }> = {
  crud: { label: 'CRUD', color: 'var(--color-accent)' },
  column: { label: 'Column', color: 'var(--color-info)' },
  component: { label: 'Component', color: 'var(--color-warning)' },
  action: { label: 'Action', color: 'var(--color-success)' },
  field: { label: 'Field', color: 'var(--color-error)' },
};

const ICON_OPTIONS = [
  { value: 'dashboard', label: 'Dashboard', icon: '📊' },
  { value: 'users', label: 'Users', icon: '👥' },
  { value: 'user', label: 'User', icon: '👤' },
  { value: 'shield', label: 'Shield', icon: '🛡️' },
  { value: 'building', label: 'Building', icon: '🏢' },
  { value: 'modules', label: 'Modules', icon: '📦' },
  { value: 'chart', label: 'Chart', icon: '📈' },
  { value: 'document', label: 'Document', icon: '📄' },
  { value: 'settings', label: 'Settings', icon: '⚙️' },
  { value: 'folder', label: 'Folder', icon: '📁' },
];

const ModuleForm = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const isEdit = Boolean(id);

  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [parentModules, setParentModules] = useState<Module[]>([]);

  const [formData, setFormData] = useState({
    name: '',
    icon: '',
    path: '',
    parent: '',
    order: '0',
    is_active: true,
  });

  const [permissions, setPermissions] = useState<PermissionData[]>([
    { codename: 'view', label: 'View', category: 'crud' },
  ]);

  const [showCustomForm, setShowCustomForm] = useState(false);
  const [customPermission, setCustomPermission] = useState({
    codename: '',
    label: '',
    category: 'action' as PermissionData['category'],
  });

  useEffect(() => {
    fetchParentModules();
    if (isEdit) fetchModule();
  }, [id]);

  const fetchParentModules = async () => {
    try {
      const data = await moduleService.getAll();
      setParentModules(data);
    } catch (err) {
      console.error('Failed to fetch parent modules');
    }
  };

  const fetchModule = async () => {
    try {
      setLoading(true);
      const module = await moduleService.getWithPermissions(Number(id));
      setFormData({
        name: module.name,
        icon: module.icon,
        path: module.path,
        parent: module.parent?.toString() || '',
        order: module.order.toString(),
        is_active: module.is_active,
      });
      setPermissions(
        module.permissions.length > 0
          ? module.permissions
          : [{ codename: 'view', label: 'View', category: 'crud' }]
      );
    } catch (err) {
      setError('Failed to fetch module');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target;
    setFormData({
      ...formData,
      [name]: type === 'checkbox' ? (e.target as HTMLInputElement).checked : value,
    });
  };

  const addPresetPermission = (preset: PermissionData) => {
    if (!permissions.some((p) => p.codename === preset.codename)) {
      setPermissions([...permissions, preset]);
    }
  };

  const removePermission = (codename: string) => {
    setPermissions(permissions.filter((p) => p.codename !== codename));
  };

  const addCustomPermission = () => {
    if (!customPermission.label) return;
    const codename =
      customPermission.codename || customPermission.label.toLowerCase().replace(/\s+/g, '_');

    if (permissions.some((p) => p.codename === codename)) {
      setError('Permission already exists');
      return;
    }

    setPermissions([...permissions, { codename, label: customPermission.label, category: customPermission.category }]);
    setCustomPermission({ codename: '', label: '', category: 'action' });
    setShowCustomForm(false);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (permissions.length === 0) {
      setError('At least one permission is required');
      return;
    }

    setSaving(true);

    try {
      const moduleData = {
        name: formData.name,
        icon: formData.icon,
        path: formData.path,
        parent: formData.parent ? Number(formData.parent) : null,
        order: Number(formData.order),
        is_active: formData.is_active,
        permissions: permissions.map((p, idx) => ({ ...p, order: idx + 1 })),
      };

      if (isEdit) {
        await moduleService.updateWithPermissions(Number(id), moduleData);
      } else {
        await moduleService.createWithPermissions(moduleData);
      }
      navigate('/modules');
    } catch (err: any) {
      const message =
        err.response?.data?.detail ||
        err.response?.data?.message ||
        Object.values(err.response?.data || {}).flat().join(', ') ||
        'Failed to save module';
      setError(message);
    } finally {
      setSaving(false);
    }
  };

  const unusedPresets = PRESET_PERMISSIONS.filter(
    (preset) => !permissions.some((p) => p.codename === preset.codename)
  );

  // Group permissions by category
  const groupedPermissions = permissions.reduce((acc, perm) => {
    if (!acc[perm.category]) acc[perm.category] = [];
    acc[perm.category].push(perm);
    return acc;
  }, {} as Record<string, PermissionData[]>);

  if (loading) {
    return (
      <div className="space-y-6 max-w-4xl">
        <div className="flex items-center gap-4">
          <div className="skeleton w-10 h-10 rounded-xl" />
          <div className="skeleton h-8 w-40 rounded-lg" />
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="card p-6 space-y-4">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="space-y-2">
                <div className="skeleton h-4 w-20 rounded" />
                <div className="skeleton h-10 w-full rounded-lg" />
              </div>
            ))}
          </div>
          <div className="card p-6">
            <div className="skeleton h-6 w-32 rounded mb-4" />
            <div className="space-y-2">
              {[...Array(4)].map((_, i) => (
                <div key={i} className="skeleton h-8 w-full rounded-lg" />
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-4xl">
      {/* Header */}
      <div className="flex items-center gap-4 animate-fade-in">
        <button
          onClick={() => navigate('/modules')}
          className="p-2.5 text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)] rounded-xl transition-colors"
        >
          <ArrowLeftIcon className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">
            {isEdit ? 'Edit Module' : 'Add Module'}
          </h1>
          <p className="text-sm text-[var(--color-text-muted)] mt-0.5">
            {isEdit ? 'Update module configuration' : 'Create a new navigation module'}
          </p>
        </div>
      </div>

      {/* Error */}
      {error && (
        <div className="alert alert-error animate-fade-in-down">
          <ExclamationTriangleIcon className="w-5 h-5 flex-shrink-0" />
          <span>{error}</span>
          <button onClick={() => setError(null)} className="ml-auto p-1 hover:opacity-70">
            <XMarkIcon className="w-4 h-4" />
          </button>
        </div>
      )}

      <form onSubmit={handleSubmit}>
        <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
          {/* Module Details - 3 columns */}
          <div className="lg:col-span-3 card animate-fade-in-up">
            <div className="p-5 border-b border-[var(--color-border)]">
              <h2 className="text-base font-semibold text-[var(--color-text-primary)]">Module Details</h2>
            </div>
            <div className="p-5 space-y-4">
              {/* Row 1: Name & Icon */}
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="label">Name <span className="text-[var(--color-error)]">*</span></label>
                  <div className="relative">
                    <Squares2X2Icon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
                    <input
                      type="text"
                      name="name"
                      value={formData.name}
                      onChange={handleChange}
                      required
                      placeholder="e.g. Reports"
                      className="input pl-10 text-sm"
                    />
                  </div>
                </div>
                <div className="space-y-1.5">
                  <label className="label">Icon <span className="text-[var(--color-error)]">*</span></label>
                  <select
                    name="icon"
                    value={formData.icon}
                    onChange={handleChange}
                    required
                    className="input text-sm appearance-none bg-[url('data:image/svg+xml;charset=UTF-8,%3csvg%20xmlns%3d%22http%3a%2f%2fwww.w3.org%2f2000%2fsvg%22%20width%3d%2224%22%20height%3d%2224%22%20viewBox%3d%220%200%2024%2024%22%20fill%3d%22none%22%20stroke%3d%22%2371717a%22%20stroke-width%3d%222%22%20stroke-linecap%3d%22round%22%20stroke-linejoin%3d%22round%22%3e%3cpolyline%20points%3d%226%209%2012%2015%2018%209%22%3e%3c%2fpolyline%3e%3c%2fsvg%3e')] bg-no-repeat bg-[right_0.75rem_center] bg-[length:1rem] pr-10"
                  >
                    <option value="">Select Icon</option>
                    {ICON_OPTIONS.map((icon) => (
                      <option key={icon.value} value={icon.value}>
                        {icon.icon} {icon.label}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Row 2: Path & Parent */}
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="label">Path <span className="text-[var(--color-error)]">*</span></label>
                  <div className="relative">
                    <LinkIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
                    <input
                      type="text"
                      name="path"
                      value={formData.path}
                      onChange={handleChange}
                      required
                      placeholder="e.g. /reports"
                      className="input pl-10 text-sm"
                    />
                  </div>
                </div>
                <div className="space-y-1.5">
                  <label className="label">Parent Module</label>
                  <div className="relative">
                    <FolderIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
                    <select
                      name="parent"
                      value={formData.parent}
                      onChange={handleChange}
                      className="input pl-10 text-sm appearance-none bg-[url('data:image/svg+xml;charset=UTF-8,%3csvg%20xmlns%3d%22http%3a%2f%2fwww.w3.org%2f2000%2fsvg%22%20width%3d%2224%22%20height%3d%2224%22%20viewBox%3d%220%200%2024%2024%22%20fill%3d%22none%22%20stroke%3d%22%2371717a%22%20stroke-width%3d%222%22%20stroke-linecap%3d%22round%22%20stroke-linejoin%3d%22round%22%3e%3cpolyline%20points%3d%226%209%2012%2015%2018%209%22%3e%3c%2fpolyline%3e%3c%2fsvg%3e')] bg-no-repeat bg-[right_0.75rem_center] bg-[length:1rem] pr-10"
                    >
                      <option value="">None (Top Level)</option>
                      {parentModules.map((module) => (
                        <option key={module.id} value={module.id}>
                          {module.name}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              </div>

              {/* Row 3: Order & Active */}
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="label">Order</label>
                  <div className="relative">
                    <HashtagIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
                    <input
                      type="number"
                      name="order"
                      value={formData.order}
                      onChange={handleChange}
                      min="0"
                      className="input pl-10 text-sm"
                    />
                  </div>
                </div>
                <div className="space-y-1.5 flex items-end">
                  <label className="flex items-center gap-3 cursor-pointer p-3 rounded-xl border border-[var(--color-border)] hover:border-[var(--color-border-hover)] transition-colors w-full">
                    <div className="relative">
                      <input
                        type="checkbox"
                        name="is_active"
                        checked={formData.is_active}
                        onChange={handleChange}
                        className="peer sr-only"
                      />
                      <div className="w-9 h-5 bg-[var(--color-surface-elevated)] border border-[var(--color-border)] rounded-full peer-checked:bg-[var(--color-success)] peer-checked:border-[var(--color-success)] transition-all" />
                      <div className="absolute top-0.5 left-0.5 w-4 h-4 bg-[var(--color-text-muted)] rounded-full peer-checked:translate-x-4 peer-checked:bg-white transition-all" />
                    </div>
                    <span className="text-sm text-[var(--color-text-primary)]">Active</span>
                  </label>
                </div>
              </div>
            </div>
          </div>

          {/* Permissions - 2 columns */}
          <div className="lg:col-span-2 card animate-fade-in-up" style={{ animationDelay: '50ms' }}>
            <div className="p-5 border-b border-[var(--color-border)]">
              <h2 className="text-base font-semibold text-[var(--color-text-primary)]">Permissions</h2>
              <p className="text-xs text-[var(--color-text-muted)] mt-0.5">
                {permissions.length} permission(s) configured
              </p>
            </div>

            <div className="p-5 space-y-4">
              {/* Selected Permissions by Category */}
              <div className="space-y-3">
                {Object.entries(groupedPermissions).map(([category, perms]) => (
                  <div key={category}>
                    <div
                      className="text-[10px] font-semibold uppercase tracking-wider mb-1.5 px-1"
                      style={{ color: CATEGORY_CONFIG[category]?.color || 'var(--color-text-muted)' }}
                    >
                      {CATEGORY_CONFIG[category]?.label || category}
                    </div>
                    <div className="flex flex-wrap gap-1.5">
                      {perms.map((perm) => (
                        <span
                          key={perm.codename}
                          className="inline-flex items-center gap-1 px-2 py-1 rounded-md text-xs font-medium bg-[var(--color-accent)] text-white"
                        >
                          {perm.label}
                          <button
                            type="button"
                            onClick={() => removePermission(perm.codename)}
                            className="hover:bg-white/20 rounded p-0.5 transition-colors"
                          >
                            <XMarkIcon className="w-3 h-3" />
                          </button>
                        </span>
                      ))}
                    </div>
                  </div>
                ))}

                {permissions.length === 0 && (
                  <div className="text-center py-6 text-[var(--color-text-muted)]">
                    <SparklesIcon className="w-8 h-8 mx-auto mb-2 opacity-50" />
                    <p className="text-sm">No permissions added</p>
                  </div>
                )}
              </div>

              {/* Divider */}
              <div className="border-t border-[var(--color-border)]" />

              {/* Quick Add */}
              {unusedPresets.length > 0 && (
                <div>
                  <p className="text-xs text-[var(--color-text-muted)] mb-2">Quick add:</p>
                  <div className="flex flex-wrap gap-1.5">
                    {unusedPresets.slice(0, 6).map((preset) => (
                      <button
                        key={preset.codename}
                        type="button"
                        onClick={() => addPresetPermission(preset)}
                        className="px-2 py-1 text-xs rounded-md bg-[var(--color-surface-elevated)] text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)] transition-colors"
                      >
                        + {preset.label}
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {/* Custom Permission */}
              {showCustomForm ? (
                <div className="p-3 rounded-xl bg-[var(--color-surface-elevated)] space-y-3">
                  <div className="grid grid-cols-2 gap-2">
                    <input
                      type="text"
                      value={customPermission.label}
                      onChange={(e) => setCustomPermission({ ...customPermission, label: e.target.value })}
                      placeholder="Label"
                      className="input text-sm py-2"
                    />
                    <select
                      value={customPermission.category}
                      onChange={(e) =>
                        setCustomPermission({ ...customPermission, category: e.target.value as PermissionData['category'] })
                      }
                      className="input text-sm py-2"
                    >
                      {Object.entries(CATEGORY_CONFIG).map(([value, { label }]) => (
                        <option key={value} value={value}>
                          {label}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="flex gap-2">
                    <button
                      type="button"
                      onClick={addCustomPermission}
                      disabled={!customPermission.label}
                      className="btn btn-primary py-1.5 px-3 text-xs flex-1"
                    >
                      <CheckIcon className="w-3 h-3" />
                      Add
                    </button>
                    <button
                      type="button"
                      onClick={() => {
                        setShowCustomForm(false);
                        setCustomPermission({ codename: '', label: '', category: 'action' });
                      }}
                      className="btn btn-secondary py-1.5 px-3 text-xs"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              ) : (
                <button
                  type="button"
                  onClick={() => setShowCustomForm(true)}
                  className="w-full flex items-center justify-center gap-1.5 py-2 text-xs text-[var(--color-accent)] hover:bg-[var(--color-accent-muted)] rounded-lg transition-colors"
                >
                  <PlusIcon className="w-4 h-4" />
                  Add Custom Permission
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Actions - Sticky */}
        <div className="sticky bottom-4 mt-6 flex justify-end">
          <div className="flex items-center gap-3 p-3 rounded-2xl bg-[var(--color-surface)]/90 backdrop-blur-xl border border-[var(--color-border)] shadow-xl">
            <button type="button" onClick={() => navigate('/modules')} className="btn btn-secondary">
              Cancel
            </button>
            <button type="submit" disabled={saving} className="btn btn-primary min-w-[120px]">
              {saving ? (
                <>
                  <div className="spinner" />
                  <span>Saving...</span>
                </>
              ) : (
                <span>{isEdit ? 'Update Module' : 'Create Module'}</span>
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default ModuleForm;