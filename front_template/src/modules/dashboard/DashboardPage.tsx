import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import useAuthStore from '../../store/authStore';
import dashboardService, { type DashboardStats } from './services';
import {
  UsersIcon,
  ShieldCheckIcon,
  BuildingOfficeIcon,
  Squares2X2Icon,
  UserPlusIcon,
  ArrowRightIcon,
} from '@heroicons/react/24/outline';

const DashboardPage = () => {
  const { user } = useAuthStore();
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

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Loading dashboard...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
        {error}
      </div>
    );
  }

  return (
    <div>
      {/* Welcome Section */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-800">
          Welcome back, {user?.first_name || user?.username}!
        </h1>
        <p className="text-gray-600 mt-1">
          Here's what's happening with your application today.
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {/* Users Card */}
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Users</p>
              <p className="text-3xl font-bold text-gray-800 mt-1">
                {stats?.total_users}
              </p>
              <p className="text-sm text-gray-500 mt-1">
                <span className="text-green-600">{stats?.active_users} active</span>
                {' · '}
                <span className="text-red-600">{stats?.inactive_users} inactive</span>
              </p>
            </div>
            <div className="p-3 bg-blue-100 rounded-full">
              <UsersIcon className="w-8 h-8 text-blue-600" />
            </div>
          </div>
          <Link
            to="/users"
            className="flex items-center gap-1 text-blue-600 text-sm mt-4 hover:underline"
          >
            View all users
            <ArrowRightIcon className="w-4 h-4" />
          </Link>
        </div>

        {/* Roles Card */}
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Roles</p>
              <p className="text-3xl font-bold text-gray-800 mt-1">
                {stats?.total_roles}
              </p>
              <p className="text-sm text-gray-500 mt-1">
                <span className="text-green-600">{stats?.active_roles} active</span>
              </p>
            </div>
            <div className="p-3 bg-purple-100 rounded-full">
              <ShieldCheckIcon className="w-8 h-8 text-purple-600" />
            </div>
          </div>
          <Link
            to="/roles"
            className="flex items-center gap-1 text-purple-600 text-sm mt-4 hover:underline"
          >
            View all roles
            <ArrowRightIcon className="w-4 h-4" />
          </Link>
        </div>

        {/* Departments Card */}
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Departments</p>
              <p className="text-3xl font-bold text-gray-800 mt-1">
                {stats?.total_departments}
              </p>
              <p className="text-sm text-gray-500 mt-1">
                <span className="text-green-600">{stats?.active_departments} active</span>
              </p>
            </div>
            <div className="p-3 bg-green-100 rounded-full">
              <BuildingOfficeIcon className="w-8 h-8 text-green-600" />
            </div>
          </div>
          <Link
            to="/departments"
            className="flex items-center gap-1 text-green-600 text-sm mt-4 hover:underline"
          >
            View all departments
            <ArrowRightIcon className="w-4 h-4" />
          </Link>
        </div>

        {/* Modules Card */}
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Modules</p>
              <p className="text-3xl font-bold text-gray-800 mt-1">
                {stats?.total_modules}
              </p>
              <p className="text-sm text-gray-500 mt-1">
                <span className="text-green-600">{stats?.active_modules} active</span>
              </p>
            </div>
            <div className="p-3 bg-orange-100 rounded-full">
              <Squares2X2Icon className="w-8 h-8 text-orange-600" />
            </div>
          </div>
          <Link
            to="/modules"
            className="flex items-center gap-1 text-orange-600 text-sm mt-4 hover:underline"
          >
            View all modules
            <ArrowRightIcon className="w-4 h-4" />
          </Link>
        </div>
      </div>

      {/* Recent Users Section */}
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
          <h2 className="text-lg font-semibold text-gray-800">Recent Users</h2>
          <Link
            to="/users/add"
            className="flex items-center gap-1 text-blue-600 text-sm hover:underline"
          >
            <UserPlusIcon className="w-4 h-4" />
            Add User
          </Link>
        </div>
        <div className="divide-y divide-gray-100">
          {stats?.recent_users.length === 0 ? (
            <div className="px-6 py-4 text-center text-gray-500">
              No users found
            </div>
          ) : (
            stats?.recent_users.map((recentUser) => (
              <div
                key={recentUser.id}
                className="px-6 py-4 flex items-center justify-between hover:bg-gray-50"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                    <span className="text-blue-600 font-medium">
                      {recentUser.first_name?.[0] || recentUser.username[0].toUpperCase()}
                    </span>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">
                      {recentUser.first_name} {recentUser.last_name || recentUser.username}
                    </p>
                    <p className="text-xs text-gray-500">{recentUser.email}</p>
                  </div>
                </div>
                <div className="text-sm text-gray-500">
                  Joined {formatDate(recentUser.date_joined)}
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;