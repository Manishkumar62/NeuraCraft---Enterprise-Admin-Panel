import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import userService, { type CreateUserData, type UpdateUserData } from './services';
import type { Role, Department } from '../../types';
import api from '../../api/axios';
import { ArrowLeftIcon } from '@heroicons/react/24/outline';

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
    selectedRoles: [] as number[],  // Changed: array of role IDs
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
        selectedRoles: user.roles?.map((r: Role) => r.id) || [],  // Changed: extract role IDs
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

  // Handle role checkbox change
  const handleRoleChange = (roleId: number) => {
    setFormData((prev) => {
      const isSelected = prev.selectedRoles.includes(roleId);
      return {
        ...prev,
        selectedRoles: isSelected
          ? prev.selectedRoles.filter((id) => id !== roleId)  // Remove if already selected
          : [...prev.selectedRoles, roleId],  // Add if not selected
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
          role_ids: formData.selectedRoles,  // Changed: send array
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
          role_ids: formData.selectedRoles,  // Changed: send array
          department_id: formData.department ? Number(formData.department) : null,
        };
        await userService.create(createData);
      }
      navigate('/users');
    } catch (err: any) {
      const message = err.response?.data?.detail || 
                      err.response?.data?.message ||
                      Object.values(err.response?.data || {}).flat().join(', ') ||
                      'Failed to save user';
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
          onClick={() => navigate('/users')}
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
        >
          <ArrowLeftIcon className="w-5 h-5 text-gray-600" />
        </button>
        <h1 className="text-2xl font-bold text-gray-800">
          {isEdit ? 'Edit User' : 'Add User'}
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
            {/* Username */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Username *
              </label>
              <input
                type="text"
                name="username"
                value={formData.username}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            {/* Email */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Email *
              </label>
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            {/* Password (only for create) */}
            {!isEdit && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Password *
                </label>
                <input
                  type="password"
                  name="password"
                  value={formData.password}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            )}

            {/* First Name */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                First Name
              </label>
              <input
                type="text"
                name="first_name"
                value={formData.first_name}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            {/* Last Name */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Last Name
              </label>
              <input
                type="text"
                name="last_name"
                value={formData.last_name}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            {/* Phone */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Phone
              </label>
              <input
                type="text"
                name="phone"
                value={formData.phone}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            {/* Employee ID */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Employee ID
              </label>
              <input
                type="text"
                name="employee_id"
                value={formData.employee_id}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            {/* Department */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Department
              </label>
              <select
                name="department"
                value={formData.department}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select Department</option>
                {departments.map((dept) => (
                  <option key={dept.id} value={dept.id}>
                    {dept.name}
                  </option>
                ))}
              </select>
            </div>

            {/* Is Active (only for edit) */}
            {isEdit && (
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
            )}
          </div>

          {/* Roles - Multi-select with Checkboxes */}
          <div className="mt-6">
            <label className="block text-sm font-medium text-gray-700 mb-3">
              Roles (Select one or more)
            </label>
            <div className="border border-gray-300 rounded-lg p-4 max-h-60 overflow-y-auto">
              {roles.length === 0 ? (
                <p className="text-gray-500 text-sm">No roles available</p>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                  {roles.map((role) => (
                    <label
                      key={role.id}
                      className={`flex items-center p-3 rounded-lg border cursor-pointer transition-colors ${
                        formData.selectedRoles.includes(role.id)
                          ? 'bg-blue-50 border-blue-500'
                          : 'bg-white border-gray-200 hover:bg-gray-50'
                      }`}
                    >
                      <input
                        type="checkbox"
                        checked={formData.selectedRoles.includes(role.id)}
                        onChange={() => handleRoleChange(role.id)}
                        className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                      />
                      <div className="ml-3">
                        <span className="text-sm font-medium text-gray-900">
                          {role.name}
                        </span>
                        {role.department_name && (
                          <span className="block text-xs text-gray-500">
                            {role.department_name}
                          </span>
                        )}
                      </div>
                    </label>
                  ))}
                </div>
              )}
            </div>
            {formData.selectedRoles.length > 0 && (
              <p className="mt-2 text-sm text-gray-600">
                {formData.selectedRoles.length} role(s) selected
              </p>
            )}
          </div>

          {/* Buttons */}
          <div className="flex items-center gap-4 mt-6">
            <button
              type="submit"
              disabled={saving}
              className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:bg-blue-300 disabled:cursor-not-allowed transition-colors"
            >
              {saving ? 'Saving...' : isEdit ? 'Update User' : 'Create User'}
            </button>
            <button
              type="button"
              onClick={() => navigate('/users')}
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

export default UserForm;