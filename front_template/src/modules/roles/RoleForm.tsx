import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import roleService, { type CreateRoleData, type UpdateRoleData } from './services';
import type { Department } from '../../types';
import api from '../../api/axios';
import {
  ArrowLeftIcon,
  ShieldCheckIcon,
  BuildingOfficeIcon,
  DocumentTextIcon,
  ExclamationTriangleIcon,
} from '@heroicons/react/24/outline';

const RoleForm = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const isEdit = Boolean(id);

  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [departments, setDepartments] = useState<Department[]>([]);

  const [formData, setFormData] = useState({
    name: '',
    description: '',
    department: '',
    is_active: true,
  });

  useEffect(() => {
    fetchDepartments();
    if (isEdit) {
      fetchRole();
    }
  }, [id]);

  const fetchDepartments = async () => {
    try {
      const response = await api.get('/departments/');
      setDepartments(response.data);
    } catch (err) {
      console.error('Failed to fetch departments');
    }
  };

  const fetchRole = async () => {
    try {
      setLoading(true);
      const role = await roleService.getById(Number(id));
      setFormData({
        name: role.name,
        description: role.description || '',
        department: role.department?.toString() || '',
        is_active: role.is_active,
      });
    } catch (err) {
      setError('Failed to fetch role');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
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
        const updateData: UpdateRoleData = {
          name: formData.name,
          description: formData.description,
          department: formData.department ? Number(formData.department) : null,
          is_active: formData.is_active,
        };
        await roleService.update(Number(id), updateData);
      } else {
        const createData: CreateRoleData = {
          name: formData.name,
          description: formData.description,
          department: formData.department ? Number(formData.department) : null,
          is_active: formData.is_active,
        };
        await roleService.create(createData);
      }
      navigate('/roles');
    } catch (err: any) {
      const message =
        err.response?.data?.detail ||
        err.response?.data?.message ||
        Object.values(err.response?.data || {})
          .flat()
          .join(', ') ||
        'Failed to save role';
      setError(message);
    } finally {
      setSaving(false);
    }
  };

  // Loading State
  if (loading) {
    return (
      <div className="space-y-6 max-w-2xl">
        <div className="flex items-center gap-4">
          <div className="skeleton w-10 h-10 rounded-xl" />
          <div className="skeleton h-8 w-32 rounded-lg" />
        </div>
        <div className="card p-6">
          <div className="space-y-5">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="space-y-2">
                <div className="skeleton h-4 w-24 rounded" />
                <div className="skeleton h-11 w-full rounded-lg" />
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-2xl">
      {/* Page Header */}
      <div className="flex items-center gap-4 animate-fade-in">
        <button
          onClick={() => navigate('/roles')}
          className="p-2.5 text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)] rounded-xl transition-colors"
        >
          <ArrowLeftIcon className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">
            {isEdit ? 'Edit Role' : 'Add Role'}
          </h1>
          <p className="text-sm text-[var(--color-text-muted)] mt-0.5">
            {isEdit ? 'Update role information' : 'Create a new role for your organization'}
          </p>
        </div>
      </div>

      {/* Error Alert */}
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

      {/* Form Card */}
      <div className="card animate-fade-in-up">
        <form onSubmit={handleSubmit}>
          <div className="p-6 space-y-5">
            {/* Role Name */}
            <div className="space-y-1.5">
              <label className="label">
                Role Name <span className="text-[var(--color-error)]">*</span>
              </label>
              <div className="relative">
                <ShieldCheckIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[var(--color-text-muted)]" />
                <input
                  type="text"
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  required
                  placeholder="Enter role name"
                  className="input pl-11"
                />
              </div>
            </div>

            {/* Department */}
            <div className="space-y-1.5">
              <label className="label">Department</label>
              <div className="relative">
                <BuildingOfficeIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[var(--color-text-muted)]" />
                <select
                  name="department"
                  value={formData.department}
                  onChange={handleChange}
                  className="input pl-11 appearance-none bg-[url('data:image/svg+xml;charset=UTF-8,%3csvg%20xmlns%3d%22http%3a%2f%2fwww.w3.org%2f2000%2fsvg%22%20width%3d%2224%22%20height%3d%2224%22%20viewBox%3d%220%200%2024%2024%22%20fill%3d%22none%22%20stroke%3d%22%2371717a%22%20stroke-width%3d%222%22%20stroke-linecap%3d%22round%22%20stroke-linejoin%3d%22round%22%3e%3cpolyline%20points%3d%226%209%2012%2015%2018%209%22%3e%3c%2fpolyline%3e%3c%2fsvg%3e')] bg-no-repeat bg-[right_0.75rem_center] bg-[length:1rem] pr-10"
                >
                  <option value="">No Department (Global Role)</option>
                  {departments.map((dept) => (
                    <option key={dept.id} value={dept.id}>
                      {dept.name}
                    </option>
                  ))}
                </select>
              </div>
              <p className="text-xs text-[var(--color-text-muted)]">
                Leave empty for global roles that apply to all departments
              </p>
            </div>

            {/* Description */}
            <div className="space-y-1.5">
              <label className="label">Description</label>
              <div className="relative">
                <DocumentTextIcon className="absolute left-3 top-3 w-5 h-5 text-[var(--color-text-muted)]" />
                <textarea
                  name="description"
                  value={formData.description}
                  onChange={handleChange}
                  rows={3}
                  placeholder="Enter role description"
                  className="input pl-11 min-h-[100px] resize-y"
                />
              </div>
            </div>

            {/* Is Active */}
            <div className="space-y-1.5">
              <label className="flex items-center gap-3 cursor-pointer group p-4 rounded-xl border border-[var(--color-border)] hover:border-[var(--color-border-hover)] transition-colors">
                <div className="relative">
                  <input
                    type="checkbox"
                    name="is_active"
                    checked={formData.is_active}
                    onChange={handleChange}
                    className="peer sr-only"
                  />
                  <div className="w-11 h-6 bg-[var(--color-surface-elevated)] border border-[var(--color-border)] rounded-full peer-checked:bg-[var(--color-success)] peer-checked:border-[var(--color-success)] transition-all duration-200" />
                  <div className="absolute top-0.5 left-0.5 w-5 h-5 bg-[var(--color-text-muted)] rounded-full peer-checked:translate-x-5 peer-checked:bg-white transition-all duration-200" />
                </div>
                <div>
                  <span className="text-sm font-medium text-[var(--color-text-primary)]">Active Status</span>
                  <p className="text-xs text-[var(--color-text-muted)]">
                    {formData.is_active ? 'Role is active and can be assigned' : 'Role is inactive'}
                  </p>
                </div>
              </label>
            </div>
          </div>

          {/* Form Actions */}
          <div className="px-6 py-4 border-t border-[var(--color-border)] flex items-center justify-end gap-3 bg-[var(--color-surface-elevated)]/30">
            <button
              type="button"
              onClick={() => navigate('/roles')}
              className="btn btn-secondary"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={saving}
              className="btn btn-primary min-w-[120px]"
            >
              {saving ? (
                <>
                  <div className="spinner" />
                  <span>Saving...</span>
                </>
              ) : (
                <span>{isEdit ? 'Update Role' : 'Create Role'}</span>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default RoleForm;