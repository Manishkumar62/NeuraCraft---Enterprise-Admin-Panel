import { NavLink } from 'react-router-dom';
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
} from '@heroicons/react/24/outline';

// Icon mapping
const iconMap: { [key: string]: React.ElementType } = {
  dashboard: HomeIcon,
  users: UsersIcon,
  user: UserIcon,
  roles: ShieldCheckIcon,
  shield: ShieldCheckIcon,
  departments: BuildingOfficeIcon,
  building: BuildingOfficeIcon,
  modules: Squares2X2Icon,
  default: Squares2X2Icon,
};

interface SidebarProps {
  menu: MenuItem[];
}

const Sidebar = ({ menu }: SidebarProps) => {
  const [openMenus, setOpenMenus] = useState<number[]>([]);

  const toggleMenu = (id: number) => {
    setOpenMenus((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const getIcon = (iconName: string) => {
    const Icon = iconMap[iconName.toLowerCase()] || iconMap.default;
    return <Icon className="w-5 h-5" />;
  };

  const renderMenuItem = (item: MenuItem) => {
    const hasChildren = item.children && item.children.length > 0;
    const isOpen = openMenus.includes(item.id);

    if (hasChildren) {
      return (
        <div key={item.id}>
          <button
            onClick={() => toggleMenu(item.id)}
            className="w-full flex items-center justify-between px-4 py-3 text-gray-300 hover:bg-gray-700 hover:text-white rounded-lg transition-colors"
          >
            <div className="flex items-center gap-3">
              {getIcon(item.icon)}
              <span>{item.module_name}</span>
            </div>
            {isOpen ? (
              <ChevronDownIcon className="w-4 h-4" />
            ) : (
              <ChevronRightIcon className="w-4 h-4" />
            )}
          </button>

          {isOpen && (
            <div className="ml-4 mt-1 space-y-1">
              {item.children.map((child) => (
                <NavLink
                  key={child.id}
                  to={child.path}
                  className={({ isActive }) =>
                    `flex items-center gap-3 px-4 py-2 rounded-lg transition-colors ${
                      isActive
                        ? 'bg-blue-600 text-white'
                        : 'text-gray-400 hover:bg-gray-700 hover:text-white'
                    }`
                  }
                >
                  {getIcon(child.icon)}
                  <span>{child.module_name}</span>
                </NavLink>
              ))}
            </div>
          )}
        </div>
      );
    }

    return (
      <NavLink
        key={item.id}
        to={item.path}
        className={({ isActive }) =>
          `flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${
            isActive
              ? 'bg-blue-600 text-white'
              : 'text-gray-300 hover:bg-gray-700 hover:text-white'
          }`
        }
      >
        {getIcon(item.icon)}
        <span>{item.module_name}</span>
      </NavLink>
    );
  };

  return (
    <aside className="w-64 bg-gray-800 flex flex-col flex-shrink-0">
      {/* Logo - Fixed */}
      <div className="p-4 border-b border-gray-700">
        <h1 className="text-2xl font-bold text-white text-center">NeuraCraft</h1>
        <p className="text-gray-400 text-sm text-center">Admin Panel</p>
      </div>

      {/* Navigation - Scrollable */}
      <nav className="flex-1 overflow-y-auto p-4 space-y-2">
        {menu.map((item) => renderMenuItem(item))}
      </nav>

      {/* Sidebar Footer */}
      <div className="p-4 border-t border-gray-700">
        <p className="text-gray-500 text-xs text-center">v1.0.0</p>
      </div>
    </aside>
  );
};

export default Sidebar;