import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import moduleService, { type PermissionData } from './services';
import type { Module } from '../../types';
import { ArrowLeftIcon, PlusIcon, XMarkIcon } from '@heroicons/react/24/outline';

// Preset permissions that users can quickly add
const PRESET_PERMISSIONS: PermissionData[] = [
  { codename: 'view', label: 'Can View', category: 'crud' },
  { codename: 'add', label: 'Can Add', category: 'crud' },
  { codename: 'edit', label: 'Can Edit', category: 'crud' },
  { codename: 'delete', label: 'Can Delete', category: 'crud' },
  { codename: 'export_csv', label: 'Export CSV', category: 'action' },
  { codename: 'export_pdf', label: 'Export PDF', category: 'action' },
  { codename: 'export_excel', label: 'Export Excel', category: 'action' },
  { codename: 'import', label: 'Import Data', category: 'action' },
  { codename: 'print', label: 'Print', category: 'action' },
];

const CATEGORY_OPTIONS = [
  { value: 'crud', label: 'CRUD' },
  { value: 'column', label: 'Column' },
  { value: 'component', label: 'Component' },
  { value: 'action', label: 'Action' },
  { value: 'field', label: 'Field' },
];

const ModuleForm = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const isEdit = Boolean(id);

  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [parentModules, setParentModules] = useState<Module[]>([]);

  // Module form data
  const [formData, setFormData] = useState({
    name: '',
    icon: '',
    path: '',
    parent: '',
    order: '0',
    is_active: true,
  });

  // Permissions
  const [permissions, setPermissions] = useState<PermissionData[]>([
    { codename: 'view', label: 'Can View', category: 'crud' }, // Default permission
  ]);

  // Custom permission form
  const [showCustomForm, setShowCustomForm] = useState(false);
  const [customPermission, setCustomPermission] = useState({
    codename: '',
    label: '',
    category: 'action' as PermissionData['category'],
  });

  // Available icons
  const availableIcons = [
    { value: 'dashboard', label: 'Dashboard' },
    { value: 'users', label: 'Users' },
    { value: 'user', label: 'User' },
    { value: 'shield', label: 'Shield (Roles)' },
    { value: 'building', label: 'Building (Departments)' },
    { value: 'modules', label: 'Modules' },
    { value: 'chart', label: 'Chart' },
    { value: 'document', label: 'Document' },
    { value: 'settings', label: 'Settings' },
    { value: 'folder', label: 'Folder' },
  ];

  useEffect(() => {
    fetchParentModules();
    if (isEdit) {
      fetchModule();
    }
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
      setPermissions(module.permissions.length > 0 ? module.permissions : [{ codename: 'view', label: 'Can View', category: 'crud' }]);
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

  // Add a preset permission
  const addPresetPermission = (preset: PermissionData) => {
    if (!permissions.some((p) => p.codename === preset.codename)) {
      setPermissions([...permissions, preset]);
    }
  };

  // Remove a permission
  const removePermission = (codename: string) => {
    setPermissions(permissions.filter((p) => p.codename !== codename));
  };

  // Add custom permission
  const addCustomPermission = () => {
    if (!customPermission.codename || !customPermission.label) return;
    
    // Convert label to codename if not provided
    const codename = customPermission.codename || customPermission.label.toLowerCase().replace(/\s+/g, '_');
    
    if (permissions.some((p) => p.codename === codename)) {
      setError('Permission with this codename already exists');
      return;
    }

    setPermissions([
      ...permissions,
      {
        codename,
        label: customPermission.label,
        category: customPermission.category,
      },
    ]);

    // Reset form
    setCustomPermission({ codename: '', label: '', category: 'action' });
    setShowCustomForm(false);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (permissions.length === 0) {
      setError('At least one permission is required (view is recommended)');
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
        permissions: permissions.map((p, idx) => ({
          ...p,
          order: idx + 1,
        })),
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

  // Get unused preset permissions
  const unusedPresets = PRESET_PERMISSIONS.filter(
    (preset) => !permissions.some((p) => p.codename === preset.codename)
  );

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Loading...</div>
      </div>
    );
  }

  return (
    <div>
      <div className="flex items-center gap-4 mb-6">
        <button
          onClick={() => navigate('/modules')}
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
        >
          <ArrowLeftIcon className="w-5 h-5 text-gray-600" />
        </button>
        <h1 className="text-2xl font-bold text-gray-800">
          {isEdit ? 'Edit Module' : 'Add Module'}
        </h1>
      </div>

      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      <form onSubmit={handleSubmit}>
        {/* Module Details Card */}
        <div className="bg-white rounded-lg shadow p-6 mb-6">
          <h2 className="text-lg font-semibold text-gray-800 mb-4">Module Details</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {/* Name */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Name *
              </label>
              <input
                type="text"
                name="name"
                value={formData.name}
                onChange={handleChange}
                required
                placeholder="e.g. Reports"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
              />
            </div>

            {/* Path */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Path *
              </label>
              <input
                type="text"
                name="path"
                value={formData.path}
                onChange={handleChange}
                required
                placeholder="e.g. /reports"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
              />
            </div>

            {/* Icon */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Icon *
              </label>
              <select
                name="icon"
                value={formData.icon}
                onChange={handleChange}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
              >
                <option value="">Select Icon</option>
                {availableIcons.map((icon) => (
                  <option key={icon.value} value={icon.value}>
                    {icon.label}
                  </option>
                ))}
              </select>
            </div>

            {/* Parent Module */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Parent Module
              </label>
              <select
                name="parent"
                value={formData.parent}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
              >
                <option value="">None (Top Level)</option>
                {parentModules.map((module) => (
                  <option key={module.id} value={module.id}>
                    {module.name}
                  </option>
                ))}
              </select>
            </div>

            {/* Order */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Order
              </label>
              <input
                type="number"
                name="order"
                value={formData.order}
                onChange={handleChange}
                min="0"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
              />
            </div>

            {/* Is Active */}
            <div className="flex items-center pt-6">
              <input
                type="checkbox"
                name="is_active"
                checked={formData.is_active}
                onChange={handleChange}
                className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
              />
              <label className="ml-2 text-sm font-medium text-gray-700">
                Active
              </label>
            </div>
          </div>
        </div>

        {/* Permissions Card */}
        <div className="bg-white rounded-lg shadow p-6 mb-6">
          <h2 className="text-lg font-semibold text-gray-800 mb-4">Available Permissions</h2>
          <p className="text-sm text-gray-500 mb-4">
            Define what permissions this module supports. These can then be assigned to roles.
          </p>

          {/* Selected Permissions */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Selected Permissions
            </label>
            <div className="flex flex-wrap gap-2 min-h-[40px] p-3 bg-gray-50 rounded-lg border border-gray-200">
              {permissions.length === 0 ? (
                <span className="text-gray-400 text-sm">No permissions selected</span>
              ) : (
                permissions.map((perm) => (
                  <span
                    key={perm.codename}
                    className="inline-flex items-center gap-1 px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm"
                  >
                    {perm.label}
                    <span className="text-xs text-blue-500">({perm.category})</span>
                    <button
                      type="button"
                      onClick={() => removePermission(perm.codename)}
                      className="ml-1 hover:bg-blue-200 rounded-full p-0.5"
                    >
                      <XMarkIcon className="w-3 h-3" />
                    </button>
                  </span>
                ))
              )}
            </div>
          </div>

          {/* Quick Add Presets */}
          {unusedPresets.length > 0 && (
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Quick Add
              </label>
              <div className="flex flex-wrap gap-2">
                {unusedPresets.map((preset) => (
                  <button
                    key={preset.codename}
                    type="button"
                    onClick={() => addPresetPermission(preset)}
                    className="px-3 py-1 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-sm transition-colors border border-gray-200"
                  >
                    + {preset.label}
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* Custom Permission Form */}
          {showCustomForm ? (
            <div className="border border-gray-200 rounded-lg p-4 bg-gray-50">
              <h3 className="text-sm font-medium text-gray-700 mb-3">Add Custom Permission</h3>
              <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
                <div>
                  <label className="block text-xs text-gray-500 mb-1">Label *</label>
                  <input
                    type="text"
                    value={customPermission.label}
                    onChange={(e) => setCustomPermission({ ...customPermission, label: e.target.value })}
                    placeholder="e.g. View Salary"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs text-gray-500 mb-1">Codename</label>
                  <input
                    type="text"
                    value={customPermission.codename}
                    onChange={(e) => setCustomPermission({ ...customPermission, codename: e.target.value.toLowerCase().replace(/\s+/g, '_') })}
                    placeholder="Auto: view_salary"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs text-gray-500 mb-1">Category</label>
                  <select
                    value={customPermission.category}
                    onChange={(e) => setCustomPermission({ ...customPermission, category: e.target.value as PermissionData['category'] })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    {CATEGORY_OPTIONS.map((cat) => (
                      <option key={cat.value} value={cat.value}>
                        {cat.label}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="flex items-end gap-2">
                  <button
                    type="button"
                    onClick={addCustomPermission}
                    disabled={!customPermission.label}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed"
                  >
                    Add
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setShowCustomForm(false);
                      setCustomPermission({ codename: '', label: '', category: 'action' });
                    }}
                    className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg text-sm hover:bg-gray-50"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            </div>
          ) : (
            <button
              type="button"
              onClick={() => setShowCustomForm(true)}
              className="flex items-center gap-2 px-4 py-2 text-blue-600 hover:bg-blue-50 rounded-lg text-sm transition-colors"
            >
              <PlusIcon className="w-4 h-4" />
              Add Custom Permission
            </button>
          )}
        </div>

        {/* Action Buttons */}
        <div className="flex items-center gap-4">
          <button
            type="submit"
            disabled={saving}
            className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:bg-blue-300 disabled:cursor-not-allowed transition-colors"
          >
            {saving ? 'Saving...' : isEdit ? 'Update Module' : 'Create Module'}
          </button>
          <button
            type="button"
            onClick={() => navigate('/modules')}
            className="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
          >
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
};

export default ModuleForm;