import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import type { Department } from '../../types';
import usePermissions from '../../hooks/usePermissions';
import departmentService from './services';
import {
  PlusIcon,
  PencilSquareIcon,
  TrashIcon,
  BuildingOfficeIcon,
  MagnifyingGlassIcon,
  ExclamationTriangleIcon,
} from '@heroicons/react/24/outline';

const DepartmentList = () => {
  const [departments, setDepartments] = useState<Department[]>([]);
  const [filteredDepartments, setFilteredDepartments] = useState<Department[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const { canAdd, canEdit, canDelete } = usePermissions('/departments');

  useEffect(() => {
    fetchDepartments();
  }, []);

  useEffect(() => {
    if (searchQuery) {
      const filtered = departments.filter(
        (dept) =>
          dept.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
          dept.code?.toLowerCase().includes(searchQuery.toLowerCase()) ||
          dept.description?.toLowerCase().includes(searchQuery.toLowerCase())
      );
      setFilteredDepartments(filtered);
    } else {
      setFilteredDepartments(departments);
    }
  }, [searchQuery, departments]);

  const fetchDepartments = async () => {
    try {
      setLoading(true);
      const data = await departmentService.getAll();
      setDepartments(data);
      setFilteredDepartments(data);
    } catch (err) {
      setError('Failed to fetch departments');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: number, name: string) => {
    if (window.confirm(`Are you sure you want to delete "${name}"?`)) {
      try {
        await departmentService.delete(id);
        setDepartments(departments.filter((dept) => dept.id !== id));
      } catch (err) {
        setError('Failed to delete department');
      }
    }
  };

  // Loading State
  if (loading) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div className="space-y-2">
            <div className="skeleton h-8 w-36 rounded-lg" />
            <div className="skeleton h-4 w-48 rounded-lg" />
          </div>
          <div className="skeleton h-10 w-36 rounded-xl" />
        </div>
        <div className="grid grid-cols-3 gap-4">
          {[...Array(3)].map((_, i) => (
            <div key={i} className="skeleton h-20 rounded-xl" />
          ))}
        </div>
        <div className="card">
          <div className="p-4 border-b border-[var(--color-border)]">
            <div className="skeleton h-10 w-64 rounded-lg" />
          </div>
          <div className="divide-y divide-[var(--color-border)]">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="p-4 flex items-center gap-4">
                <div className="skeleton w-10 h-10 rounded-xl" />
                <div className="flex-1 space-y-2">
                  <div className="skeleton h-4 w-32 rounded" />
                  <div className="skeleton h-3 w-24 rounded" />
                </div>
                <div className="skeleton h-6 w-16 rounded-full" />
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex items-start justify-between animate-fade-in">
        <div>
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Departments</h1>
          <p className="text-sm text-[var(--color-text-muted)] mt-1">
            Manage organizational departments
          </p>
        </div>
        {canAdd && (
          <Link
            to="/departments/add"
            className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-medium text-white bg-gradient-to-r from-[var(--color-accent)] to-violet-600 rounded-xl hover:shadow-lg hover:shadow-[var(--color-accent)]/25 transition-all duration-300 hover:-translate-y-0.5"
          >
            <PlusIcon className="w-5 h-5" />
            Add Department
          </Link>
        )}
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

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 animate-fade-in-up">
        <div className="card p-4">
          <p className="text-xs text-[var(--color-text-muted)] uppercase tracking-wider">Total</p>
          <p className="text-2xl font-bold text-[var(--color-text-primary)] mt-1">{departments.length}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-[var(--color-text-muted)] uppercase tracking-wider">Active</p>
          <p className="text-2xl font-bold text-[var(--color-success)] mt-1">
            {departments.filter((d) => d.is_active).length}
          </p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-[var(--color-text-muted)] uppercase tracking-wider">Inactive</p>
          <p className="text-2xl font-bold text-[var(--color-error)] mt-1">
            {departments.filter((d) => !d.is_active).length}
          </p>
        </div>
      </div>

      {/* Table Card */}
      <div className="card animate-fade-in-up" style={{ animationDelay: '100ms' }}>
        {/* Search */}
        <div className="p-4 border-b border-[var(--color-border)]">
          <div className="relative max-w-sm">
            <MagnifyingGlassIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[var(--color-text-muted)]" />
            <input
              type="text"
              placeholder="Search departments..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="input pl-11 py-2.5"
            />
          </div>
        </div>

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-[var(--color-border)]">
                <th className="px-5 py-4 text-left text-xs font-semibold text-[var(--color-text-muted)] uppercase tracking-wider">
                  Department
                </th>
                <th className="px-5 py-4 text-left text-xs font-semibold text-[var(--color-text-muted)] uppercase tracking-wider">
                  Code
                </th>
                <th className="px-5 py-4 text-left text-xs font-semibold text-[var(--color-text-muted)] uppercase tracking-wider">
                  Description
                </th>
                <th className="px-5 py-4 text-left text-xs font-semibold text-[var(--color-text-muted)] uppercase tracking-wider">
                  Status
                </th>
                <th className="px-5 py-4 text-right text-xs font-semibold text-[var(--color-text-muted)] uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[var(--color-border)]">
              {filteredDepartments.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-5 py-12">
                    <div className="flex flex-col items-center justify-center text-center">
                      <div className="w-16 h-16 rounded-2xl bg-[var(--color-surface-elevated)] flex items-center justify-center mb-4">
                        <BuildingOfficeIcon className="w-8 h-8 text-[var(--color-text-muted)]" />
                      </div>
                      <h3 className="text-lg font-semibold text-[var(--color-text-primary)] mb-1">
                        {searchQuery ? 'No departments found' : 'No departments yet'}
                      </h3>
                      <p className="text-sm text-[var(--color-text-muted)] mb-4">
                        {searchQuery ? 'Try adjusting your search' : 'Get started by creating your first department'}
                      </p>
                      {!searchQuery && canAdd && (
                        <Link
                          to="/departments/add"
                          className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-gradient-to-r from-[var(--color-accent)] to-violet-600 rounded-xl"
                        >
                          <PlusIcon className="w-4 h-4" />
                          Add Department
                        </Link>
                      )}
                    </div>
                  </td>
                </tr>
              ) : (
                filteredDepartments.map((dept, index) => (
                  <tr
                    key={dept.id}
                    className="hover:bg-[var(--color-surface-hover)] transition-colors animate-fade-in"
                    style={{ animationDelay: `${index * 30}ms` }}
                  >
                    {/* Department */}
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center shadow-lg shadow-emerald-500/20">
                          <BuildingOfficeIcon className="w-5 h-5 text-white" />
                        </div>
                        <span className="text-sm font-semibold text-[var(--color-text-primary)]">
                          {dept.name}
                        </span>
                      </div>
                    </td>

                    {/* Code */}
                    <td className="px-5 py-4">
                      <span className="px-2 py-1 text-xs font-mono font-medium rounded bg-[var(--color-surface-elevated)] text-[var(--color-text-secondary)]">
                        {dept.code}
                      </span>
                    </td>

                    {/* Description */}
                    <td className="px-5 py-4 text-sm text-[var(--color-text-secondary)] max-w-xs truncate">
                      {dept.description || <span className="text-[var(--color-text-muted)]">—</span>}
                    </td>

                    {/* Status */}
                    <td className="px-5 py-4">
                      <span className={`badge ${dept.is_active ? 'badge-success' : 'badge-error'}`}>
                        {dept.is_active ? 'Active' : 'Inactive'}
                      </span>
                    </td>

                    {/* Actions */}
                    <td className="px-5 py-4">
                      <div className="flex items-center justify-end gap-1">
                        {canEdit && (
                          <Link
                            to={`/departments/edit/${dept.id}`}
                            className="p-2 text-[var(--color-text-muted)] hover:text-[var(--color-accent)] hover:bg-[var(--color-accent-muted)] rounded-lg transition-colors"
                            title="Edit"
                          >
                            <PencilSquareIcon className="w-5 h-5" />
                          </Link>
                        )}
                        {canDelete && (
                          <button
                            onClick={() => handleDelete(dept.id, dept.name)}
                            className="p-2 text-[var(--color-text-muted)] hover:text-[var(--color-error)] hover:bg-[var(--color-error-muted)] rounded-lg transition-colors"
                            title="Delete"
                          >
                            <TrashIcon className="w-5 h-5" />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Footer */}
        {filteredDepartments.length > 0 && (
          <div className="px-5 py-3 border-t border-[var(--color-border)] flex items-center justify-between">
            <p className="text-sm text-[var(--color-text-muted)]">
              Showing <span className="font-medium text-[var(--color-text-secondary)]">{filteredDepartments.length}</span> of{' '}
              <span className="font-medium text-[var(--color-text-secondary)]">{departments.length}</span> departments
            </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default DepartmentList;