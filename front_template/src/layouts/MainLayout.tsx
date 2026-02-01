import { Outlet, Navigate } from 'react-router-dom';
import { useEffect } from 'react';
import useAuthStore from '../store/authStore';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';

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
      <div className="h-screen flex items-center justify-center bg-[var(--color-background)]">
        <div className="flex flex-col items-center gap-4">
          {/* Animated Logo */}
          <div className="relative">
            <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-[var(--color-accent)] to-cyan-500 animate-pulse-glow" />
            <div className="absolute inset-0 w-16 h-16 rounded-2xl border-2 border-[var(--color-accent)] animate-spin" style={{ animationDuration: '3s' }} />
          </div>
          
          {/* Loading Text */}
          <div className="flex flex-col items-center gap-2">
            <h2 className="text-xl font-semibold text-gradient">NeuraCraft</h2>
            <div className="flex items-center gap-2">
              <div className="spinner" />
              <span className="text-[var(--color-text-muted)] text-sm">Loading your workspace...</span>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="h-screen flex overflow-hidden bg-[var(--color-background)]">
      {/* Sidebar - Fixed */}
      <Sidebar menu={menu} />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header - Fixed */}
        <Header />

        {/* Scrollable Content */}
        <main className="flex-1 overflow-y-auto">
          {/* Subtle Background Pattern */}
          <div className="relative min-h-full">
            <div className="absolute inset-0 bg-dot-pattern opacity-30 pointer-events-none" />
            
            {/* Content Container */}
            <div className="relative z-10 p-6 animate-fade-in">
              <Outlet />
            </div>
          </div>
        </main>

        {/* Footer - Minimal */}
        <footer className="flex-shrink-0 border-t border-[var(--color-border)] px-6 py-3">
          <div className="flex items-center justify-between text-xs text-[var(--color-text-muted)]">
            <div className="flex items-center gap-2">
              <span>© {new Date().getFullYear()}</span>
              <span className="text-[var(--color-text-secondary)]">Manishkumar Vishwakarma</span>
            </div>
            <div className="flex items-center gap-4">
              <span className="px-2 py-0.5 rounded-full bg-[var(--color-surface-elevated)] text-[var(--color-text-muted)]">
                v1.0.0
              </span>
            </div>
          </div>
        </footer>
      </div>
    </div>
  );
};

export default MainLayout;