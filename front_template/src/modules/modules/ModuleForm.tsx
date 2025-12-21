import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import moduleService, { type CreateModuleData, type UpdateModuleData } from './services';
import type { Module } from '../../types';
import { ArrowLeftIcon } from '@heroicons/react/24/outline';

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

  // Available icons (matching Sidebar iconMap)
  const availableIcons = [
    { value: 'dashboard', label: 'Dashboard' },
    { value: 'users', label: 'Users' },
    { value: 'user', label: 'User' },
    { value: 'shield', label: 'Shield (Roles)' },
    { value: 'building', label: 'Building (Departments)' },
    { value: 'modules', label: 'Modules' },
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
      // Flatten modules for parent dropdown (only show parent-level modules)
      setParentModules(data);
    } catch (err) {
      console.error('Failed to fetch parent modules');
    }
  };

  const fetchModule = async () => {
    try {
      setLoading(true);
      const module = await moduleService.getById(Number(id));
      setFormData({
        name: module.name,
        icon: module.icon,
        path: module.path,
        parent: module.parent?.toString() || '',
        order: module.order.toString(),
        is_active: module.is_active,
      });
    } catch (err) {
      setError('Failed to fetch module');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    const { name, value, type } = e.target;
    setFormData({
      ...formData,
      [name]: type === 'checkbox' ? (e.target as HTMLInputElement).checked : value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSaving(true);

    try {
      if (isEdit) {
        const updateData: UpdateModuleData = {
          name: formData.name,
          icon: formData.icon,
          path: formData.path,
          parent: formData.parent ? Number(formData.parent) : null,
          order: Number(formData.order),
          is_active: formData.is_active,
        };
        await moduleService.update(Number(id), updateData);
      } else {
        const createData: CreateModuleData = {
          name: formData.name,
          icon: formData.icon,
          path: formData.path,
          parent: formData.parent ? Number(formData.parent) : null,
          order: Number(formData.order),
          is_active: formData.is_active,
        };
        await moduleService.create(createData);
      }
      navigate('/modules');
    } catch (err: any) {
      const message = err.response?.data?.detail ||
                      err.response?.data?.message ||
                      Object.values(err.response?.data || {}).flat().join(', ') ||
                      'Failed to save module';
      setError(message);
    } finally {
      setSaving(false);
    }
  };

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

      <div className="bg-white rounded-lg shadow p-6">
        <form onSubmit={handleSubmit}>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Name */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Name *
              </label>
              <input
                type="text"
                name="name"
                value={formData.name}
                onChange={handleChange}
                required
                placeholder="e.g. Dashboard, Users, Settings"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            {/* Icon */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Icon *
              </label>
              <select
                name="icon"
                value={formData.icon}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select Icon</option>
                {availableIcons.map((icon) => (
                  <option key={icon.value} value={icon.value}>
                    {icon.label}
                  </option>
                ))}
              </select>
            </div>

            {/* Path */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Path *
              </label>
              <input
                type="text"
                name="path"
                value={formData.path}
                onChange={handleChange}
                required
                placeholder="e.g. /dashboard, /users, #"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p className="text-xs text-gray-500 mt-1">
                Use "#" for parent menus with children
              </p>
            </div>

            {/* Parent Module */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Parent Module
              </label>
              <select
                name="parent"
                value={formData.parent}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
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
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Order
              </label>
              <input
                type="number"
                name="order"
                value={formData.order}
                onChange={handleChange}
                min="0"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p className="text-xs text-gray-500 mt-1">
                Lower numbers appear first
              </p>
            </div>

            {/* Is Active */}
            <div className="flex items-center">
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

          {/* Buttons */}
          <div className="flex items-center gap-4 mt-6">
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
    </div>
  );
};

export default ModuleForm;