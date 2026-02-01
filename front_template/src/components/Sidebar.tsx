import { NavLink, useLocation } from 'react-router-dom';
import { useState } from 'react';
import type { MenuItem } from '../types';
import {
  HomeIcon,
  UsersIcon,
  UserIcon,
  ShieldCheckIcon,
  BuildingOfficeIcon,
  Squares2X2Icon,
  ChevronDownIcon,
  ChevronRightIcon,
  Cog6ToothIcon,
  SparklesIcon,
} from '@heroicons/react/24/outline';

// Icon mapping
const iconMap: { [key: string]: React.ElementType } = {
  dashboard: HomeIcon,
  home: HomeIcon,
  users: UsersIcon,
  user: UserIcon,
  roles: ShieldCheckIcon,
  shield: ShieldCheckIcon,
  departments: BuildingOfficeIcon,
  building: BuildingOfficeIcon,
  modules: Squares2X2Icon,
  settings: Cog6ToothIcon,
  default: Squares2X2Icon,
};

interface SidebarProps {
  menu: MenuItem[];
}

const Sidebar = ({ menu }: SidebarProps) => {
  const [openMenus, setOpenMenus] = useState<number[]>([]);
  const [isCollapsed, setIsCollapsed] = useState(false);
  const location = useLocation();

  const toggleMenu = (id: number) => {
    setOpenMenus((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const getIcon = (iconName: string) => {
    const Icon = iconMap[iconName?.toLowerCase()] || iconMap.default;
    return <Icon className="w-5 h-5 flex-shrink-0" />;
  };

  // Check if any child is active
  const isChildActive = (item: MenuItem) => {
    if (!item.children) return false;
    return item.children.some((child) => location.pathname === child.path);
  };

  const renderMenuItem = (item: MenuItem, index: number) => {
    const hasChildren = item.children && item.children.length > 0;
    const isOpen = openMenus.includes(item.id) || isChildActive(item);

    if (hasChildren) {
      return (
        <div key={item.id} className="animate-fade-in" style={{ animationDelay: `${index * 50}ms` }}>
          <button
            onClick={() => toggleMenu(item.id)}
            className={`
              group relative w-full flex items-center justify-between px-3 py-2.5 
              text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)]
              hover:bg-[var(--color-surface-hover)] rounded-xl
              transition-all duration-200
              ${isChildActive(item) ? 'text-[var(--color-text-primary)] bg-[var(--color-surface-hover)]' : ''}
            `}
          >
            <div className="flex items-center gap-3">
              <span className={`
                transition-colors duration-200
                ${isChildActive(item) ? 'text-[var(--color-accent)]' : 'group-hover:text-[var(--color-accent)]'}
              `}>
                {getIcon(item.icon)}
              </span>
              {!isCollapsed && (
                <span className="font-medium text-sm">{item.module_name}</span>
              )}
            </div>
            {!isCollapsed && (
              <ChevronDownIcon 
                className={`w-4 h-4 transition-transform duration-200 ${isOpen ? 'rotate-180' : ''}`} 
              />
            )}
          </button>

          {/* Submenu */}
          <div className={`
            overflow-hidden transition-all duration-300 ease-in-out
            ${isOpen ? 'max-h-96 opacity-100' : 'max-h-0 opacity-0'}
          `}>
            <div className="ml-4 pl-4 mt-1 space-y-1 border-l border-[var(--color-border)]">
              {item.children.map((child, childIndex) => (
                <NavLink
                  key={child.id}
                  to={child.path}
                  className={({ isActive }) => `
                    group relative flex items-center gap-3 px-3 py-2 rounded-lg
                    text-sm font-medium transition-all duration-200
                    ${isActive 
                      ? 'text-[var(--color-accent)] bg-[var(--color-accent-muted)]' 
                      : 'text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)]'
                    }
                  `}
                  style={{ animationDelay: `${childIndex * 30}ms` }}
                >
                  {({ isActive }) => (
                    <>
                      {/* Active Indicator Dot */}
                      <span className={`
                        w-1.5 h-1.5 rounded-full transition-all duration-200
                        ${isActive 
                          ? 'bg-[var(--color-accent)] shadow-[0_0_8px_var(--color-accent)]' 
                          : 'bg-[var(--color-text-muted)] group-hover:bg-[var(--color-text-secondary)]'
                        }
                      `} />
                      <span>{child.module_name}</span>
                    </>
                  )}
                </NavLink>
              ))}
            </div>
          </div>
        </div>
      );
    }

    return (
      <NavLink
        key={item.id}
        to={item.path}
        className={({ isActive }) => `
          group relative flex items-center gap-3 px-3 py-2.5 rounded-xl
          text-sm font-medium transition-all duration-200
          animate-fade-in
          ${isActive 
            ? 'text-[var(--color-accent)] bg-[var(--color-accent-muted)]' 
            : 'text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)]'
          }
        `}
        style={{ animationDelay: `${index * 50}ms` }}
      >
        {({ isActive }) => (
          <>
            {/* Active Indicator Bar */}
            {isActive && (
              <span className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-[var(--color-accent)] rounded-r-full shadow-[0_0_12px_var(--color-accent)]" />
            )}
            <span className={`transition-colors duration-200 ${isActive ? 'text-[var(--color-accent)]' : 'group-hover:text-[var(--color-accent)]'}`}>
              {getIcon(item.icon)}
            </span>
            {!isCollapsed && <span>{item.module_name}</span>}
          </>
        )}
      </NavLink>
    );
  };

  return (
    <aside className={`
      ${isCollapsed ? 'w-20' : 'w-72'}
      bg-[var(--color-surface)] border-r border-[var(--color-border)]
      flex flex-col flex-shrink-0 transition-all duration-300
    `}>
      {/* Logo Section */}
      <div className="p-4 border-b border-[var(--color-border)]">
        <div className="flex items-center gap-3">
          {/* Logo Icon */}
          <div className="relative flex-shrink-0">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[var(--color-accent)] to-cyan-500 flex items-center justify-center shadow-lg shadow-[var(--color-accent)]/25">
              <SparklesIcon className="w-5 h-5 text-white" />
            </div>
            {/* Glow Effect */}
            <div className="absolute inset-0 w-10 h-10 rounded-xl bg-gradient-to-br from-[var(--color-accent)] to-cyan-500 blur-xl opacity-40" />
          </div>
          
          {!isCollapsed && (
            <div className="flex flex-col">
              <h1 className="text-lg font-bold text-gradient">NeuraCraft</h1>
              <p className="text-[10px] uppercase tracking-widest text-[var(--color-text-muted)]">Admin Panel</p>
            </div>
          )}
        </div>
      </div>

      {/* Navigation - Scrollable */}
      <nav className="flex-1 overflow-y-auto p-3 space-y-1">
        {/* Section Label */}
        {!isCollapsed && (
          <div className="px-3 py-2">
            <span className="text-[10px] uppercase tracking-widest font-semibold text-[var(--color-text-muted)]">
              Navigation
            </span>
          </div>
        )}
        
        {menu.map((item, index) => renderMenuItem(item, index))}
      </nav>

      {/* Collapse Toggle Button */}
      <div className="p-3 border-t border-[var(--color-border)]">
        <button
          onClick={() => setIsCollapsed(!isCollapsed)}
          className="w-full flex items-center justify-center gap-2 px-3 py-2 
            text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)]
            hover:bg-[var(--color-surface-hover)] rounded-xl
            transition-all duration-200 text-sm"
        >
          <ChevronRightIcon className={`w-4 h-4 transition-transform duration-300 ${isCollapsed ? '' : 'rotate-180'}`} />
          {!isCollapsed && <span>Collapse</span>}
        </button>
      </div>

      {/* Sidebar Footer */}
      {!isCollapsed && (
        <div className="p-4 border-t border-[var(--color-border)]">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-[var(--color-success)] animate-pulse" />
              <span className="text-xs text-[var(--color-text-muted)]">System Online</span>
            </div>
            <span className="text-[10px] text-[var(--color-text-muted)] bg-[var(--color-surface-elevated)] px-2 py-0.5 rounded-full">
              v1.0.0
            </span>
          </div>
        </div>
      )}
    </aside>
  );
};

export default Sidebar;