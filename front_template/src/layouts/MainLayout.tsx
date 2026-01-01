import { Outlet, Navigate } from 'react-router-dom';
import { useEffect } from 'react';
import useAuthStore from '../store/authStore';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import Footer from '../components/Footer';

const MainLayout = () => {
  const { isAuthenticated, menu, fetchProfile, fetchMenu, isLoading } = useAuthStore();

  useEffect(() => {
    if (isAuthenticated) {
      fetchProfile();
      fetchMenu();
    }
  }, [isAuthenticated]);

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (isLoading) {
    return (
      <div className="h-screen flex items-center justify-center bg-gray-100">
        <div className="text-gray-600">Loading...</div>
      </div>
    );
  }

  return (
    <div className="h-screen flex overflow-hidden bg-gray-100">
      {/* Sidebar - Fixed */}
      <Sidebar menu={menu} />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header - Fixed */}
        <Header />

        {/* Scrollable Content */}
        <main className="flex-1 overflow-y-auto p-6">
          <Outlet />
        </main>

        {/* Footer - Fixed at bottom */}
        <Footer />
      </div>
    </div>
  );
};

export default MainLayout;