import api from '../../api/axios';

export interface DashboardStats {
  total_users: number;
  active_users: number;
  inactive_users: number;
  total_roles: number;
  active_roles: number;
  total_departments: number;
  active_departments: number;
  total_modules: number;
  active_modules: number;
  recent_users: RecentUser[];
}

export interface RecentUser {
  id: number;
  username: string;
  email: string;
  first_name: string;
  last_name: string;
  date_joined: string;
}

const dashboardService = {
  getStats: async (): Promise<DashboardStats> => {
    const response = await api.get('/dashboard/stats/');
    return response.data;
  },
};

export default dashboardService;