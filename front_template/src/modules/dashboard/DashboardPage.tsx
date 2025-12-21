import useAuthStore from '../../store/authStore';

const DashboardPage = () => {
  const { user } = useAuthStore();

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-800 mb-4">
        Welcome to Dashboard
      </h1>
      <div className="bg-white p-6 rounded-lg shadow-md">
        <p className="text-gray-600">
          Hello, <span className="font-semibold">{user?.first_name || user?.username}</span>!
        </p>
        <p className="text-gray-500 mt-2">
          Role: <span className="font-medium">{user?.role?.name || 'No role assigned'}</span>
        </p>
      </div>
    </div>
  );
};

export default DashboardPage;