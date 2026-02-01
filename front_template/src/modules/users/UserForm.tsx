import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import userService, { type CreateUserData, type UpdateUserData } from './services';
import type { Role, Department } from '../../types';
import api from '../../api/axios';
import {
  ArrowLeftIcon,
  UserIcon,
  EnvelopeIcon,
  KeyIcon,
  PhoneIcon,
  IdentificationIcon,
  BuildingOfficeIcon,
  ShieldCheckIcon,
  ExclamationTriangleIcon,
  XMarkIcon,
} from '@heroicons/react/24/outline';

const UserForm = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const isEdit = Boolean(id);

  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [roles, setRoles] = useState<Role[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);

  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    first_name: '',
    last_name: '',
    phone: '',
    employee_id: '',
    selectedRoles: [] as number[],
    department: '',
    is_active: true,
  });

  useEffect(() => {
    fetchDropdownData();
    if (isEdit) {
      fetchUser();
    }
  }, [id]);

  const fetchDropdownData = async () => {
    try {
      const [rolesRes, deptsRes] = await Promise.all([
        api.get('/roles/'),
        api.get('/departments/'),
      ]);
      setRoles(rolesRes.data);
      setDepartments(deptsRes.data);
    } catch (err) {
      console.error('Failed to fetch dropdown data');
    }
  };

  const fetchUser = async () => {
    try {
      setLoading(true);
      const user = await userService.getById(Number(id));
      setFormData({
        username: user.username,
        email: user.email,
        password: '',
        first_name: user.first_name || '',
        last_name: user.last_name || '',
        phone: user.phone || '',
        employee_id: user.employee_id || '',
        selectedRoles: user.roles?.map((r: Role) => r.id) || [],
        department: user.department?.id?.toString() || '',
        is_active: user.is_active,
      });
    } catch (err) {
      setError('Failed to fetch user');
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

  const handleRoleChange = (roleId: number) => {
    setFormData((prev) => {
      const isSelected = prev.selectedRoles.includes(roleId);
      return {
        ...prev,
        selectedRoles: isSelected
          ? prev.selectedRoles.filter((id) => id !== roleId)
          : [...prev.selectedRoles, roleId],
      };
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSaving(true);

    try {
      if (isEdit) {
        const updateData: UpdateUserData = {
          username: formData.username,
          email: formData.email,
          first_name: formData.first_name,
          last_name: formData.last_name,
          phone: formData.phone,
          employee_id: formData.employee_id,
          role_ids: formData.selectedRoles,
          department_id: formData.department ? Number(formData.department) : null,
          is_active: formData.is_active,
        };
        await userService.update(Number(id), updateData);
      } else {
        const createData: CreateUserData = {
          username: formData.username,
          email: formData.email,
          password: formData.password,
          first_name: formData.first_name,
          last_name: formData.last_name,
          phone: formData.phone,
          employee_id: formData.employee_id,
          role_ids: formData.selectedRoles,
          department_id: formData.department ? Number(formData.department) : null,
        };
        await userService.create(createData);
      }
      navigate('/users');
    } catch (err: any) {
      const message =
        err.response?.data?.detail ||
        err.response?.data?.message ||
        Object.values(err.response?.data || {})
          .flat()
          .join(', ') ||
        'Failed to save user';
      setError(message);
    } finally {
      setSaving(false);
    }
  };

  // Loading State
  if (loading) {
    return (
      <div className="space-y-6 max-w-5xl">
        <div className="flex items-center gap-4">
          <div className="skeleton w-10 h-10 rounded-xl" />
          <div className="skeleton h-8 w-32 rounded-lg" />
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
          <div className="lg:col-span-3 card p-5 space-y-4">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="space-y-1.5">
                <div className="skeleton h-3 w-20 rounded" />
                <div className="skeleton h-10 w-full rounded-lg" />
              </div>
            ))}
          </div>
          <div className="lg:col-span-2 card p-5">
            <div className="skeleton h-5 w-24 rounded mb-4" />
            <div className="space-y-2">
              {[...Array(5)].map((_, i) => (
                <div key={i} className="skeleton h-8 w-full rounded-lg" />
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-5xl">
      {/* Header */}
      <div className="flex items-center gap-4 animate-fade-in">
        <button
          onClick={() => navigate('/users')}
          className="p-2.5 text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)] rounded-xl transition-colors"
        >
          <ArrowLeftIcon className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">
            {isEdit ? 'Edit User' : 'Add User'}
          </h1>
          <p className="text-sm text-[var(--color-text-muted)] mt-0.5">
            {isEdit ? 'Update user information and permissions' : 'Create a new user account'}
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
          {/* Left Column - User Details (3/5) */}
          <div className="lg:col-span-3 card animate-fade-in-up">
            <div className="p-5 border-b border-[var(--color-border)]">
              <h2 className="text-base font-semibold text-[var(--color-text-primary)]">User Details</h2>
            </div>
            <div className="p-5 space-y-4">
              {/* Row 1: Username & Email */}
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="label text-xs">Username <span className="text-[var(--color-error)]">*</span></label>
                  <div className="relative">
                    <UserIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
                    <input
                      type="text"
                      name="username"
                      value={formData.username}
                      onChange={handleChange}
                      required
                      placeholder="Username"
                      className="input pl-10 py-2 text-sm"
                    />
                  </div>
                </div>
                <div className="space-y-1.5">
                  <label className="label text-xs">Email <span className="text-[var(--color-error)]">*</span></label>
                  <div className="relative">
                    <EnvelopeIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
                    <input
                      type="email"
                      name="email"
                      value={formData.email}
                      onChange={handleChange}
                      required
                      placeholder="email@example.com"
                      className="input pl-10 py-2 text-sm"
                    />
                  </div>
                </div>
              </div>

              {/* Row 2: First Name & Last Name */}
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="label text-xs">First Name</label>
                  <input
                    type="text"
                    name="first_name"
                    value={formData.first_name}
                    onChange={handleChange}
                    placeholder="First name"
                    className="input py-2 text-sm"
                  />
                </div>
                <div className="space-y-1.5">
                  <label className="label text-xs">Last Name</label>
                  <input
                    type="text"
                    name="last_name"
                    value={formData.last_name}
                    onChange={handleChange}
                    placeholder="Last name"
                    className="input py-2 text-sm"
                  />
                </div>
              </div>

              {/* Row 3: Password (create only) & Phone */}
              <div className="grid grid-cols-2 gap-4">
                {!isEdit ? (
                  <div className="space-y-1.5">
                    <label className="label text-xs">Password <span className="text-[var(--color-error)]">*</span></label>
                    <div className="relative">
                      <KeyIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
                      <input
                        type="password"
                        name="password"
                        value={formData.password}
                        onChange={handleChange}
                        required
                        placeholder="••••••••"
                        className="input pl-10 py-2 text-sm"
                      />
                    </div>
                  </div>
                ) : (
                  <div className="space-y-1.5">
                    <label className="label text-xs">Employee ID</label>
                    <div className="relative">
                      <IdentificationIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
                      <input
                        type="text"
                        name="employee_id"
                        value={formData.employee_id}
                        onChange={handleChange}
                        placeholder="EMP-001"
                        className="input pl-10 py-2 text-sm"
                      />
                    </div>
                  </div>
                )}
                <div className="space-y-1.5">
                  <label className="label text-xs">Phone</label>
                  <div className="relative">
                    <PhoneIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
                    <input
                      type="text"
                      name="phone"
                      value={formData.phone}
                      onChange={handleChange}
                      placeholder="+1 234 567 890"
                      className="input pl-10 py-2 text-sm"
                    />
                  </div>
                </div>
              </div>

              {/* Row 4: Employee ID (create only) & Department */}
              <div className="grid grid-cols-2 gap-4">
                {!isEdit && (
                  <div className="space-y-1.5">
                    <label className="label text-xs">Employee ID</label>
                    <div className="relative">
                      <IdentificationIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
                      <input
                        type="text"
                        name="employee_id"
                        value={formData.employee_id}
                        onChange={handleChange}
                        placeholder="EMP-001"
                        className="input pl-10 py-2 text-sm"
                      />
                    </div>
                  </div>
                )}
                <div className={`space-y-1.5 ${isEdit ? 'col-span-1' : ''}`}>
                  <label className="label text-xs">Department</label>
                  <div className="relative">
                    <BuildingOfficeIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
                    <select
                      name="department"
                      value={formData.department}
                      onChange={handleChange}
                      className="input pl-10 py-2 text-sm appearance-none bg-[url('data:image/svg+xml;charset=UTF-8,%3csvg%20xmlns%3d%22http%3a%2f%2fwww.w3.org%2f2000%2fsvg%22%20width%3d%2224%22%20height%3d%2224%22%20viewBox%3d%220%200%2024%2024%22%20fill%3d%22none%22%20stroke%3d%22%2371717a%22%20stroke-width%3d%222%22%20stroke-linecap%3d%22round%22%20stroke-linejoin%3d%22round%22%3e%3cpolyline%20points%3d%226%209%2012%2015%2018%209%22%3e%3c%2fpolyline%3e%3c%2fsvg%3e')] bg-no-repeat bg-[right_0.75rem_center] bg-[length:1rem] pr-10"
                    >
                      <option value="">Select Department</option>
                      {departments.map((dept) => (
                        <option key={dept.id} value={dept.id}>
                          {dept.name}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
                {isEdit && (
                  <div className="space-y-1.5 flex items-end">
                    <label className="flex items-center gap-3 cursor-pointer p-2.5 rounded-xl border border-[var(--color-border)] hover:border-[var(--color-border-hover)] transition-colors w-full">
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
                      <div>
                        <span className="text-sm text-[var(--color-text-primary)]">Active</span>
                        <p className="text-[10px] text-[var(--color-text-muted)]">
                          {formData.is_active ? 'Can login' : 'Disabled'}
                        </p>
                      </div>
                    </label>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Right Column - Roles (2/5) - Compact pill style like ModuleForm */}
          <div className="lg:col-span-2 card animate-fade-in-up" style={{ animationDelay: '50ms' }}>
            <div className="p-5 border-b border-[var(--color-border)]">
              <div className="flex items-center gap-2">
                <ShieldCheckIcon className="w-4 h-4 text-[var(--color-accent)]" />
                <h2 className="text-base font-semibold text-[var(--color-text-primary)]">Roles</h2>
              </div>
              <p className="text-xs text-[var(--color-text-muted)] mt-0.5">
                {formData.selectedRoles.length} role(s) assigned
              </p>
            </div>

            <div className="p-5 space-y-4">
              {/* Selected Roles */}
              <div>
                <p className="text-[10px] font-semibold uppercase tracking-wider text-[var(--color-accent)] mb-2">
                  Assigned
                </p>
                <div className="flex flex-wrap gap-1.5 min-h-[32px]">
                  {formData.selectedRoles.length === 0 ? (
                    <span className="text-xs text-[var(--color-text-muted)]">No roles assigned</span>
                  ) : (
                    formData.selectedRoles.map((roleId) => {
                      const role = roles.find((r) => r.id === roleId);
                      if (!role) return null;
                      return (
                        <span
                          key={role.id}
                          className="inline-flex items-center gap-1 px-2 py-1 rounded-md text-xs font-medium bg-[var(--color-accent)] text-white"
                        >
                          {role.name}
                          <button
                            type="button"
                            onClick={() => handleRoleChange(role.id)}
                            className="hover:bg-white/20 rounded p-0.5 transition-colors"
                          >
                            <XMarkIcon className="w-3 h-3" />
                          </button>
                        </span>
                      );
                    })
                  )}
                </div>
              </div>

              {/* Divider */}
              <div className="border-t border-[var(--color-border)]" />

              {/* Available Roles */}
              {roles.filter((r) => !formData.selectedRoles.includes(r.id)).length > 0 && (
                <div>
                  <p className="text-xs text-[var(--color-text-muted)] mb-2">Click to add:</p>
                  <div className="flex flex-wrap gap-1.5">
                    {roles
                      .filter((r) => !formData.selectedRoles.includes(r.id))
                      .map((role) => (
                        <button
                          key={role.id}
                          type="button"
                          onClick={() => handleRoleChange(role.id)}
                          className="px-2 py-1 text-xs rounded-md bg-[var(--color-surface-elevated)] text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)] transition-colors"
                        >
                          + {role.name}
                        </button>
                      ))}
                  </div>
                </div>
              )}

              {/* Empty state when no roles available */}
              {roles.length === 0 && (
                <div className="text-center py-6">
                  <ShieldCheckIcon className="w-6 h-6 text-[var(--color-text-muted)] mx-auto mb-2" />
                  <p className="text-xs text-[var(--color-text-muted)]">No roles available</p>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Sticky Action Bar */}
        <div className="sticky bottom-4 mt-6 flex justify-end">
          <div className="flex items-center gap-3 p-3 rounded-2xl bg-[var(--color-surface)]/90 backdrop-blur-xl border border-[var(--color-border)] shadow-xl">
            <button type="button" onClick={() => navigate('/users')} className="btn btn-secondary">
              Cancel
            </button>
            <button type="submit" disabled={saving} className="btn btn-primary min-w-[120px]">
              {saving ? (
                <>
                  <div className="spinner" />
                  <span>Saving...</span>
                </>
              ) : (
                <span>{isEdit ? 'Update User' : 'Create User'}</span>
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default UserForm;