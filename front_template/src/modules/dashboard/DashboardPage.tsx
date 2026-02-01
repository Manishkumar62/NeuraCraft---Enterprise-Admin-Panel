import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import useAuthStore from '../../store/authStore';
import usePermissions from '../../hooks/usePermissions';
import dashboardService, { type DashboardStats } from './services';
import {
  UsersIcon,
  ShieldCheckIcon,
  BuildingOfficeIcon,
  Squares2X2Icon,
  UserPlusIcon,
  ArrowRightIcon,
  ExclamationTriangleIcon,
  SparklesIcon,
} from '@heroicons/react/24/outline';

const DashboardPage = () => {
  const { user } = useAuthStore();
  const { hasPermission } = usePermissions('/dashboard');

  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      setLoading(true);
      const data = await dashboardService.getStats();
      setStats(data);
    } catch (err) {
      setError('Failed to fetch dashboard stats');
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  };

  // Loading State
  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center h-64 gap-4">
        <div className="relative">
          <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-[var(--color-accent)] to-cyan-500 animate-pulse" />
          <div className="absolute inset-0 w-12 h-12 rounded-xl border-2 border-[var(--color-accent)]/50 animate-spin" style={{ animationDuration: '2s' }} />
        </div>
        <p className="text-[var(--color-text-muted)] text-sm">Loading dashboard...</p>
      </div>
    );
  }

  // Error State
  if (error) {
    return (
      <div className="alert alert-error animate-fade-in">
        <ExclamationTriangleIcon className="w-5 h-5 flex-shrink-0" />
        <span>{error}</span>
        <button 
          onClick={fetchStats}
          className="ml-auto text-sm underline hover:no-underline"
        >
          Retry
        </button>
      </div>
    );
  }

  // Check if any card is visible
  const hasAnyCard =
    hasPermission('total_users') ||
    hasPermission('total_roles') ||
    hasPermission('total_departments') ||
    hasPermission('total_modules');

  // Stats card configuration
  const statsCards = [
    {
      key: 'total_users',
      permission: 'total_users',
      title: 'Total Users',
      value: stats?.total_users,
      subtitle: (
        <>
          <span className="text-[var(--color-success)]">{stats?.active_users} active</span>
          <span className="text-[var(--color-text-muted)]"> · </span>
          <span className="text-[var(--color-error)]">{stats?.inactive_users} inactive</span>
        </>
      ),
      icon: UsersIcon,
      gradient: 'from-violet-500 to-purple-600',
      shadowColor: 'rgba(139, 92, 246, 0.3)',
      link: '/users',
      linkText: 'View all users',
    },
    {
      key: 'total_roles',
      permission: 'total_roles',
      title: 'Total Roles',
      value: stats?.total_roles,
      subtitle: (
        <span className="text-[var(--color-success)]">{stats?.active_roles} active</span>
      ),
      icon: ShieldCheckIcon,
      gradient: 'from-cyan-500 to-blue-600',
      shadowColor: 'rgba(6, 182, 212, 0.3)',
      link: '/roles',
      linkText: 'View all roles',
    },
    {
      key: 'total_departments',
      permission: 'total_departments',
      title: 'Total Departments',
      value: stats?.total_departments,
      subtitle: (
        <span className="text-[var(--color-success)]">{stats?.active_departments} active</span>
      ),
      icon: BuildingOfficeIcon,
      gradient: 'from-emerald-500 to-green-600',
      shadowColor: 'rgba(16, 185, 129, 0.3)',
      link: '/departments',
      linkText: 'View all departments',
    },
    {
      key: 'total_modules',
      permission: 'total_modules',
      title: 'Total Modules',
      value: stats?.total_modules,
      subtitle: (
        <span className="text-[var(--color-success)]">{stats?.active_modules} active</span>
      ),
      icon: Squares2X2Icon,
      gradient: 'from-amber-500 to-orange-600',
      shadowColor: 'rgba(245, 158, 11, 0.3)',
      link: '/modules',
      linkText: 'View all modules',
    },
  ];

  return (
    <div className="space-y-8">
      {/* Welcome Section */}
      <div className="animate-fade-in">
        <div className="flex items-center gap-3 mb-2">
          <div className="relative">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[var(--color-accent)] to-cyan-500 flex items-center justify-center">
              <SparklesIcon className="w-5 h-5 text-white" />
            </div>
            <div className="absolute inset-0 w-10 h-10 rounded-xl bg-gradient-to-br from-[var(--color-accent)] to-cyan-500 blur-xl opacity-40" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">
              Welcome back, {user?.first_name || user?.username}!
            </h1>
            <p className="text-[var(--color-text-muted)] text-sm">
              Here's what's happening with your application today.
            </p>
          </div>
        </div>
      </div>

      {/* Stats Cards */}
      {hasAnyCard && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
          {statsCards.map((card, index) =>
            hasPermission(card.permission) ? (
              <div
                key={card.key}
                className="card p-5 group animate-fade-in-up"
                style={{ animationDelay: `${index * 100}ms` }}
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <p className="text-sm font-medium text-[var(--color-text-muted)] mb-1">
                      {card.title}
                    </p>
                    <p className="text-3xl font-bold text-[var(--color-text-primary)]">
                      {card.value}
                    </p>
                    <p className="text-xs mt-1.5">{card.subtitle}</p>
                  </div>
                  <div
                    className={`w-12 h-12 rounded-xl bg-gradient-to-br ${card.gradient} flex items-center justify-center shadow-lg transition-transform duration-300 group-hover:scale-110`}
                    style={{ boxShadow: `0 8px 20px -4px ${card.shadowColor}` }}
                  >
                    <card.icon className="w-6 h-6 text-white" />
                  </div>
                </div>
                <Link
                  to={card.link}
                  className="inline-flex items-center gap-1.5 text-sm text-[var(--color-text-muted)] hover:text-[var(--color-accent)] transition-colors group/link"
                >
                  <span>{card.linkText}</span>
                  <ArrowRightIcon className="w-4 h-4 transition-transform group-hover/link:translate-x-1" />
                </Link>
              </div>
            ) : null
          )}
        </div>
      )}

      {/* Recent Users Section */}
      {hasPermission('recent_users') && (
        <div className="card animate-fade-in-up" style={{ animationDelay: '300ms' }}>
          <div className="px-5 py-4 border-b border-[var(--color-border)] flex items-center justify-between">
            <div>
              <h2 className="text-lg font-semibold text-[var(--color-text-primary)]">
                Recent Users
              </h2>
              <p className="text-xs text-[var(--color-text-muted)] mt-0.5">
                Latest registered users in your system
              </p>
            </div>
            <Link
              to="/users/add"
              className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-gradient-to-r from-[var(--color-accent)] to-violet-600 rounded-xl hover:shadow-lg hover:shadow-[var(--color-accent)]/25 transition-all duration-300 hover:-translate-y-0.5"
            >
              <UserPlusIcon className="w-4 h-4" />
              Add User
            </Link>
          </div>

          <div className="divide-y divide-[var(--color-border)]">
            {stats?.recent_users.length === 0 ? (
              <div className="px-5 py-12 text-center">
                <div className="w-16 h-16 mx-auto mb-4 rounded-2xl bg-[var(--color-surface-elevated)] flex items-center justify-center">
                  <UsersIcon className="w-8 h-8 text-[var(--color-text-muted)]" />
                </div>
                <p className="text-[var(--color-text-muted)]">No users found</p>
                <Link
                  to="/users/add"
                  className="inline-flex items-center gap-1 text-sm text-[var(--color-accent)] hover:underline mt-2"
                >
                  Add your first user
                  <ArrowRightIcon className="w-3 h-3" />
                </Link>
              </div>
            ) : (
              stats?.recent_users.map((recentUser, index) => (
                <div
                  key={recentUser.id}
                  className="px-5 py-4 flex items-center justify-between hover:bg-[var(--color-surface-hover)] transition-colors animate-fade-in"
                  style={{ animationDelay: `${index * 50}ms` }}
                >
                  <div className="flex items-center gap-4">
                    {/* Avatar */}
                    <div className="relative">
                      <div className="w-11 h-11 rounded-xl bg-gradient-to-br from-[var(--color-accent)] to-cyan-500 flex items-center justify-center text-white font-semibold shadow-lg shadow-[var(--color-accent)]/20">
                        {recentUser.first_name?.[0] || recentUser.username[0].toUpperCase()}
                      </div>
                      {/* Online indicator - optional */}
                      <span className="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 bg-[var(--color-success)] border-2 border-[var(--color-surface)] rounded-full" />
                    </div>

                    {/* User Info */}
                    <div>
                      <p className="text-sm font-semibold text-[var(--color-text-primary)]">
                        {recentUser.first_name} {recentUser.last_name || recentUser.username}
                      </p>
                      <p className="text-xs text-[var(--color-text-muted)]">
                        {recentUser.email}
                      </p>
                    </div>
                  </div>

                  {/* Join Date */}
                  <div className="flex items-center gap-3">
                    <div className="text-right">
                      <p className="text-xs text-[var(--color-text-muted)]">Joined</p>
                      <p className="text-sm text-[var(--color-text-secondary)]">
                        {formatDate(recentUser.date_joined)}
                      </p>
                    </div>
                    <Link
                      to={`/users/${recentUser.id}`}
                      className="p-2 text-[var(--color-text-muted)] hover:text-[var(--color-accent)] hover:bg-[var(--color-accent-muted)] rounded-lg transition-colors"
                    >
                      <ArrowRightIcon className="w-4 h-4" />
                    </Link>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* View All Link */}
          {stats?.recent_users && stats.recent_users.length > 0 && (
            <div className="px-5 py-3 border-t border-[var(--color-border)]">
              <Link
                to="/users"
                className="inline-flex items-center gap-1.5 text-sm text-[var(--color-accent)] hover:underline"
              >
                View all users
                <ArrowRightIcon className="w-4 h-4" />
              </Link>
            </div>
          )}
        </div>
      )}

      {/* System Overview - Additional section */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
        <div className="card p-5 animate-fade-in-up" style={{ animationDelay: '400ms' }}>
          <div className="flex items-center justify-between mb-3">
            <span className="text-sm text-[var(--color-text-muted)]">System Status</span>
            <span className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-[var(--color-success)] animate-pulse" />
              <span className="text-xs text-[var(--color-success)]">Operational</span>
            </span>
          </div>
          <p className="text-2xl font-bold text-[var(--color-text-primary)]">99.9%</p>
          <p className="text-xs text-[var(--color-text-muted)] mt-1">Uptime this month</p>
        </div>

        <div className="card p-5 animate-fade-in-up" style={{ animationDelay: '450ms' }}>
          <div className="flex items-center justify-between mb-3">
            <span className="text-sm text-[var(--color-text-muted)]">API Response</span>
            <span className="badge badge-success text-[10px]">Fast</span>
          </div>
          <p className="text-2xl font-bold text-[var(--color-text-primary)]">45ms</p>
          <p className="text-xs text-[var(--color-text-muted)] mt-1">Average response time</p>
        </div>

        <div className="card p-5 animate-fade-in-up" style={{ animationDelay: '500ms' }}>
          <div className="flex items-center justify-between mb-3">
            <span className="text-sm text-[var(--color-text-muted)]">Active Sessions</span>
            <span className="badge badge-info text-[10px]">Live</span>
          </div>
          <p className="text-2xl font-bold text-[var(--color-text-primary)]">24</p>
          <p className="text-xs text-[var(--color-text-muted)] mt-1">Users currently online</p>
        </div>
      </div>

      {/* No permissions message */}
      {!hasAnyCard && !hasPermission('recent_users') && (
        <div className="card p-12 text-center animate-fade-in">
          <div className="w-16 h-16 mx-auto mb-4 rounded-2xl bg-[var(--color-surface-elevated)] flex items-center justify-center">
            <ShieldCheckIcon className="w-8 h-8 text-[var(--color-text-muted)]" />
          </div>
          <h3 className="text-lg font-semibold text-[var(--color-text-primary)] mb-1">
            Limited Access
          </h3>
          <p className="text-[var(--color-text-muted)] text-sm">
            You don't have permission to view any dashboard widgets.
          </p>
        </div>
      )}
    </div>
  );
};

export default DashboardPage;