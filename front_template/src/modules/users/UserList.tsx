import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import type { User } from '../../types';
import usePermissions from '../../hooks/usePermissions';
import userService from './services';
import {
  PlusIcon,
  PencilSquareIcon,
  TrashIcon,
  UsersIcon,
  MagnifyingGlassIcon,
  ExclamationTriangleIcon,
} from '@heroicons/react/24/outline';

const UserList = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [filteredUsers, setFilteredUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const { canAdd, canEdit, canDelete, hasPermission } = usePermissions('/users');

  useEffect(() => {
    fetchUsers();
  }, []);

  useEffect(() => {
    if (searchQuery) {
      const filtered = users.filter(
        (user) =>
          user.username.toLowerCase().includes(searchQuery.toLowerCase()) ||
          user.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
          user.first_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
          user.last_name?.toLowerCase().includes(searchQuery.toLowerCase())
      );
      setFilteredUsers(filtered);
    } else {
      setFilteredUsers(users);
    }
  }, [searchQuery, users]);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const data = await userService.getAll();
      setUsers(data);
      setFilteredUsers(data);
    } catch (err) {
      setError('Failed to fetch users');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: number, username: string) => {
    if (window.confirm(`Are you sure you want to delete "${username}"?`)) {
      try {
        await userService.delete(id);
        setUsers(users.filter((user) => user.id !== id));
      } catch (err) {
        setError('Failed to delete user');
      }
    }
  };

  // Loading State
  if (loading) {
    return (
      <div className="space-y-6">
        {/* Header Skeleton */}
        <div className="flex items-center justify-between">
          <div className="space-y-2">
            <div className="skeleton h-8 w-32 rounded-lg" />
            <div className="skeleton h-4 w-48 rounded-lg" />
          </div>
          <div className="skeleton h-10 w-28 rounded-xl" />
        </div>

        {/* Table Skeleton */}
        <div className="card">
          <div className="p-4 border-b border-[var(--color-border)]">
            <div className="skeleton h-10 w-64 rounded-lg" />
          </div>
          <div className="divide-y divide-[var(--color-border)]">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="p-4 flex items-center gap-4">
                <div className="skeleton w-11 h-11 rounded-xl" />
                <div className="flex-1 space-y-2">
                  <div className="skeleton h-4 w-32 rounded" />
                  <div className="skeleton h-3 w-24 rounded" />
                </div>
                <div className="skeleton h-6 w-16 rounded-full" />
                <div className="skeleton h-6 w-20 rounded-full" />
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
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Users</h1>
          <p className="text-sm text-[var(--color-text-muted)] mt-1">
            Manage user accounts and their access permissions
          </p>
        </div>
        {canAdd && (
          <Link
            to="/users/add"
            className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-medium text-white bg-gradient-to-r from-[var(--color-accent)] to-violet-600 rounded-xl hover:shadow-lg hover:shadow-[var(--color-accent)]/25 transition-all duration-300 hover:-translate-y-0.5"
          >
            <PlusIcon className="w-5 h-5" />
            Add User
          </Link>
        )}
      </div>

      {/* Error Alert */}
      {error && (
        <div className="alert alert-error animate-fade-in-down">
          <ExclamationTriangleIcon className="w-5 h-5 flex-shrink-0" />
          <span>{error}</span>
          <button
            onClick={() => setError(null)}
            className="ml-auto p-1 hover:opacity-70 transition-opacity"
          >
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      )}

      {/* Stats Row */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 animate-fade-in-up">
        <div className="card p-4">
          <p className="text-xs text-[var(--color-text-muted)] uppercase tracking-wider">Total Users</p>
          <p className="text-2xl font-bold text-[var(--color-text-primary)] mt-1">{users.length}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-[var(--color-text-muted)] uppercase tracking-wider">Active</p>
          <p className="text-2xl font-bold text-[var(--color-success)] mt-1">
            {users.filter((u) => u.is_active).length}
          </p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-[var(--color-text-muted)] uppercase tracking-wider">Inactive</p>
          <p className="text-2xl font-bold text-[var(--color-error)] mt-1">
            {users.filter((u) => !u.is_active).length}
          </p>
        </div>
      </div>

      {/* Table Card */}
      <div className="card animate-fade-in-up" style={{ animationDelay: '100ms' }}>
        {/* Search Bar */}
        <div className="p-4 border-b border-[var(--color-border)]">
          <div className="relative max-w-sm">
            <MagnifyingGlassIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[var(--color-text-muted)]" />
            <input
              type="text"
              placeholder="Search users..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="input pl-10 py-2.5"
            />
          </div>
        </div>

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-[var(--color-border)]">
                <th className="px-5 py-4 text-left text-xs font-semibold text-[var(--color-text-muted)] uppercase tracking-wider">
                  User
                </th>
                {hasPermission('view_email') && (
                  <th className="px-5 py-4 text-left text-xs font-semibold text-[var(--color-text-muted)] uppercase tracking-wider">
                    Email
                  </th>
                )}
                <th className="px-5 py-4 text-left text-xs font-semibold text-[var(--color-text-muted)] uppercase tracking-wider">
                  Roles
                </th>
                <th className="px-5 py-4 text-left text-xs font-semibold text-[var(--color-text-muted)] uppercase tracking-wider">
                  Department
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
              {filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-5 py-12">
                    <div className="flex flex-col items-center justify-center text-center">
                      <div className="w-16 h-16 rounded-2xl bg-[var(--color-surface-elevated)] flex items-center justify-center mb-4">
                        <UsersIcon className="w-8 h-8 text-[var(--color-text-muted)]" />
                      </div>
                      <h3 className="text-lg font-semibold text-[var(--color-text-primary)] mb-1">
                        {searchQuery ? 'No users found' : 'No users yet'}
                      </h3>
                      <p className="text-sm text-[var(--color-text-muted)] mb-4">
                        {searchQuery
                          ? 'Try adjusting your search criteria'
                          : 'Get started by adding your first user'}
                      </p>
                      {!searchQuery && canAdd && (
                        <Link
                          to="/users/add"
                          className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-gradient-to-r from-[var(--color-accent)] to-violet-600 rounded-xl hover:shadow-lg hover:shadow-[var(--color-accent)]/25 transition-all"
                        >
                          <PlusIcon className="w-4 h-4" />
                          Add User
                        </Link>
                      )}
                    </div>
                  </td>
                </tr>
              ) : (
                filteredUsers.map((user, index) => (
                  <tr
                    key={user.id}
                    className="hover:bg-[var(--color-surface-hover)] transition-colors animate-fade-in"
                    style={{ animationDelay: `${index * 30}ms` }}
                  >
                    {/* User Info */}
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-3">
                        <div className="relative">
                          <div className="w-11 h-11 rounded-xl bg-gradient-to-br from-[var(--color-accent)] to-cyan-500 flex items-center justify-center text-white font-semibold shadow-lg shadow-[var(--color-accent)]/20">
                            {user.first_name?.[0] || user.username[0].toUpperCase()}
                          </div>
                          {user.is_active && (
                            <span className="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 bg-[var(--color-success)] border-2 border-[var(--color-surface)] rounded-full" />
                          )}
                        </div>
                        <div>
                          <p className="text-sm font-semibold text-[var(--color-text-primary)]">
                            {user.first_name} {user.last_name}
                          </p>
                          <p className="text-xs text-[var(--color-text-muted)]">@{user.username}</p>
                        </div>
                      </div>
                    </td>

                    {/* Email */}
                    {hasPermission('view_email') && (
                      <td className="px-5 py-4 text-sm text-[var(--color-text-secondary)]">
                        {user.email}
                      </td>
                    )}

                    {/* Roles */}
                    <td className="px-5 py-4">
                      <div className="flex flex-wrap gap-1.5">
                        {user.roles && user.roles.length > 0 ? (
                          <>
                            {user.roles.slice(0, 2).map((role) => (
                              <span
                                key={role.id}
                                className="badge badge-accent"
                                title={role.department_name ? `Department: ${role.department_name}` : 'Global Role'}
                              >
                                {role.name}
                                {role.department_name && (
                                  <span className="ml-1 opacity-70">({role.department_name})</span>
                                )}
                              </span>
                            ))}
                            {user.roles.length > 2 && (
                              <span className="badge bg-[var(--color-surface-elevated)] text-[var(--color-text-muted)]">
                                +{user.roles.length - 2}
                              </span>
                            )}
                          </>
                        ) : (
                          <span className="text-sm text-[var(--color-text-muted)]">No roles</span>
                        )}
                      </div>
                    </td>

                    {/* Department */}
                    <td className="px-5 py-4 text-sm text-[var(--color-text-secondary)]">
                      {user.department?.name || (
                        <span className="text-[var(--color-text-muted)]">—</span>
                      )}
                    </td>

                    {/* Status */}
                    <td className="px-5 py-4">
                      <span
                        className={`badge ${
                          user.is_active ? 'badge-success' : 'badge-error'
                        }`}
                      >
                        {user.is_active ? 'Active' : 'Inactive'}
                      </span>
                    </td>

                    {/* Actions */}
                    <td className="px-5 py-4">
                      <div className="flex items-center justify-end gap-1">
                        {canEdit && (
                          <Link
                            to={`/users/edit/${user.id}`}
                            className="p-2 text-[var(--color-text-muted)] hover:text-[var(--color-accent)] hover:bg-[var(--color-accent-muted)] rounded-lg transition-colors"
                            title="Edit user"
                          >
                            <PencilSquareIcon className="w-5 h-5" />
                          </Link>
                        )}
                        {canDelete && (
                          <button
                            onClick={() => handleDelete(user.id, user.username)}
                            className="p-2 text-[var(--color-text-muted)] hover:text-[var(--color-error)] hover:bg-[var(--color-error-muted)] rounded-lg transition-colors"
                            title="Delete user"
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

        {/* Table Footer */}
        {filteredUsers.length > 0 && (
          <div className="px-5 py-3 border-t border-[var(--color-border)] flex items-center justify-between">
            <p className="text-sm text-[var(--color-text-muted)]">
              Showing <span className="font-medium text-[var(--color-text-secondary)]">{filteredUsers.length}</span> of{' '}
              <span className="font-medium text-[var(--color-text-secondary)]">{users.length}</span> users
            </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default UserList;