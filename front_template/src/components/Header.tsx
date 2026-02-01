import { useState, useRef, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import useAuthStore from '../store/authStore';
import ThemeToggle from './ui/ThemeToggle';
import {
  UserCircleIcon,
  ArrowRightOnRectangleIcon,
  ChevronDownIcon,
  Cog6ToothIcon,
  BellIcon,
  MagnifyingGlassIcon,
} from '@heroicons/react/24/outline';

const Header = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { user, logout } = useAuthStore();
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setDropdownOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  // Get role names for display
  const getRoleNames = () => {
    if (user?.roles && user.roles.length > 0) {
      return user.roles.map((role) => role.name).join(', ');
    }
    return 'No Role';
  };

  // Get page title from path
  const getPageTitle = () => {
    const path = location.pathname.split('/').filter(Boolean);
    if (path.length === 0) return 'Dashboard';
    return path[path.length - 1]
      .split('-')
      .map(word => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ');
  };

  // Get user initials
  const getInitials = () => {
    if (user?.first_name && user?.last_name) {
      return `${user.first_name[0]}${user.last_name[0]}`.toUpperCase();
    }
    return user?.username?.slice(0, 2).toUpperCase() || 'U';
  };

  return (
    <header className="bg-[var(--color-surface)]/80 backdrop-blur-xl border-b border-[var(--color-border)] px-6 py-4 flex-shrink-0 sticky top-0 z-40">
      <div className="flex items-center justify-between">
        {/* Left Section - Page Title & Breadcrumb */}
        <div className="flex flex-col">
          <h1 className="text-xl font-semibold text-[var(--color-text-primary)]">
            {getPageTitle()}
          </h1>
          <p className="text-sm text-[var(--color-text-muted)]">
            Welcome back, {user?.first_name || user?.username}
          </p>
        </div>

        {/* Right Section - Actions & Profile */}
        <div className="flex items-center gap-2">
          {/* Search Button */}
          <button
            onClick={() => setSearchOpen(!searchOpen)}
            className="p-2.5 text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)] rounded-xl transition-all duration-200"
          >
            <MagnifyingGlassIcon className="w-5 h-5" />
          </button>

          {/* Notifications */}
          <button className="relative p-2.5 text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)] rounded-xl transition-all duration-200">
            <BellIcon className="w-5 h-5" />
            {/* Notification Badge */}
            <span className="absolute top-2 right-2 w-2 h-2 bg-[var(--color-error)] rounded-full" />
          </button>

          {/* Theme Toggle */}
          <ThemeToggle />

          {/* Divider */}
          <div className="w-px h-8 bg-[var(--color-border)] mx-2" />

          {/* Profile Dropdown */}
          <div className="relative" ref={dropdownRef}>
            <button
              onClick={() => setDropdownOpen(!dropdownOpen)}
              className={`
                flex items-center gap-3 py-1.5 pl-1.5 pr-3 rounded-xl
                transition-all duration-200
                ${dropdownOpen 
                  ? 'bg-[var(--color-surface-elevated)]' 
                  : 'hover:bg-[var(--color-surface-hover)]'
                }
              `}
            >
              {/* Avatar */}
              <div className="relative">
                <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-[var(--color-accent)] to-cyan-500 flex items-center justify-center text-white text-sm font-semibold shadow-lg shadow-[var(--color-accent)]/20">
                  {getInitials()}
                </div>
                {/* Online Status */}
                <span className="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-[var(--color-success)] border-2 border-[var(--color-surface)] rounded-full" />
              </div>

              <div className="hidden sm:flex flex-col items-start">
                <span className="text-sm font-medium text-[var(--color-text-primary)]">
                  {user?.first_name || user?.username}
                </span>
                <span className="text-xs text-[var(--color-text-muted)]">
                  {getRoleNames()}
                </span>
              </div>
              
              <ChevronDownIcon className={`w-4 h-4 text-[var(--color-text-muted)] transition-transform duration-200 ${dropdownOpen ? 'rotate-180' : ''}`} />
            </button>

            {/* Dropdown Menu */}
            {dropdownOpen && (
              <div className="dropdown-menu absolute right-0 mt-2 w-64">
                {/* User Info Section */}
                <div className="px-3 py-3 border-b border-[var(--color-border)]">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-[var(--color-accent)] to-cyan-500 flex items-center justify-center text-white text-lg font-semibold">
                      {getInitials()}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-semibold text-[var(--color-text-primary)] truncate">
                        {user?.first_name} {user?.last_name}
                      </p>
                      <p className="text-xs text-[var(--color-text-muted)] truncate">
                        {user?.email}
                      </p>
                      <div className="mt-1">
                        <span className="badge badge-accent text-[10px]">
                          {getRoleNames()}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Menu Items */}
                <div className="p-1.5">
                  <button className="dropdown-item">
                    <UserCircleIcon className="w-4 h-4" />
                    <span>View Profile</span>
                  </button>
                  
                  <button className="dropdown-item">
                    <Cog6ToothIcon className="w-4 h-4" />
                    <span>Settings</span>
                  </button>
                </div>

                <div className="dropdown-divider" />

                {/* Logout */}
                <div className="p-1.5">
                  <button
                    onClick={handleLogout}
                    className="dropdown-item text-[var(--color-error)] hover:bg-[var(--color-error-muted)]"
                  >
                    <ArrowRightOnRectangleIcon className="w-4 h-4" />
                    <span>Sign out</span>
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Search Overlay */}
      {searchOpen && (
        <>
          <div 
            className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50"
            onClick={() => setSearchOpen(false)}
          />
          <div className="fixed top-20 left-1/2 -translate-x-1/2 w-full max-w-2xl z-50 animate-fade-in-down">
            <div className="mx-4">
              <div className="glass-strong rounded-2xl p-2 shadow-2xl">
                <div className="flex items-center gap-3 px-4 py-3">
                  <MagnifyingGlassIcon className="w-5 h-5 text-[var(--color-text-muted)]" />
                  <input
                    type="text"
                    placeholder="Search for anything..."
                    className="flex-1 bg-transparent text-[var(--color-text-primary)] placeholder-[var(--color-text-muted)] outline-none text-lg"
                    autoFocus
                  />
                  <kbd className="px-2 py-1 text-xs text-[var(--color-text-muted)] bg-[var(--color-surface-elevated)] rounded-lg border border-[var(--color-border)]">
                    ESC
                  </kbd>
                </div>
                <div className="px-4 py-3 border-t border-[var(--color-border)]">
                  <p className="text-xs text-[var(--color-text-muted)]">
                    Start typing to search users, roles, departments...
                  </p>
                </div>
              </div>
            </div>
          </div>
        </>
      )}
    </header>
  );
};

export default Header;