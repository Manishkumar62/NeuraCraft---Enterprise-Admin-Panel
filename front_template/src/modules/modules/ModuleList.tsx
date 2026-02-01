import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import type { Module } from '../../types';
import usePermissions from '../../hooks/usePermissions';
import moduleService from './services';
import {
  PlusIcon,
  PencilSquareIcon,
  TrashIcon,
  ChevronDownIcon,
  ChevronRightIcon,
  Squares2X2Icon,
  MagnifyingGlassIcon,
  ExclamationTriangleIcon,
  FolderIcon,
  DocumentIcon,
} from '@heroicons/react/24/outline';

const ModuleList = () => {
  const [modules, setModules] = useState<Module[]>([]);
  const [filteredModules, setFilteredModules] = useState<Module[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [expandedModules, setExpandedModules] = useState<number[]>([]);
  const { canAdd, canEdit, canDelete } = usePermissions('/modules');

  useEffect(() => {
    fetchModules();
  }, []);

  useEffect(() => {
    if (searchQuery) {
      // Flatten and filter modules
      const filterModules = (mods: Module[]): Module[] => {
        return mods.reduce((acc: Module[], mod) => {
          const matchesSelf =
            mod.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            mod.path.toLowerCase().includes(searchQuery.toLowerCase());
          const filteredChildren = mod.children ? filterModules(mod.children) : [];

          if (matchesSelf || filteredChildren.length > 0) {
            acc.push({ ...mod, children: filteredChildren.length > 0 ? filteredChildren : mod.children });
          }
          return acc;
        }, []);
      };
      setFilteredModules(filterModules(modules));
      // Expand all when searching
      const getAllIds = (mods: Module[]): number[] => {
        return mods.reduce((acc: number[], mod) => {
          acc.push(mod.id);
          if (mod.children) acc.push(...getAllIds(mod.children));
          return acc;
        }, []);
      };
      setExpandedModules(getAllIds(modules));
    } else {
      setFilteredModules(modules);
    }
  }, [searchQuery, modules]);

  const fetchModules = async () => {
    try {
      setLoading(true);
      const data = await moduleService.getAll();
      setModules(data);
      setFilteredModules(data);
      // Expand top level by default
      setExpandedModules(data.map((m) => m.id));
    } catch (err) {
      setError('Failed to fetch modules');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: number, name: string) => {
    if (window.confirm(`Are you sure you want to delete "${name}"? This will also delete all child modules.`)) {
      try {
        await moduleService.delete(id);
        fetchModules();
      } catch (err) {
        setError('Failed to delete module');
      }
    }
  };

  const toggleExpand = (id: number) => {
    setExpandedModules((prev) =>
      prev.includes(id) ? prev.filter((i) => i !== id) : [...prev, id]
    );
  };

  // Count total modules including children
  const countModules = (mods: Module[]): number => {
    return mods.reduce((acc, mod) => {
      return acc + 1 + (mod.children ? countModules(mod.children) : 0);
    }, 0);
  };

  const totalCount = countModules(modules);
  const activeCount = modules.reduce((acc, mod) => {
    const countActive = (m: Module): number => {
      let count = m.is_active ? 1 : 0;
      if (m.children) count += m.children.reduce((a, c) => a + countActive(c), 0);
      return count;
    };
    return acc + countActive(mod);
  }, 0);

  const renderModule = (module: Module, level: number = 0, isLast: boolean = false) => {
    const hasChildren = module.children && module.children.length > 0;
    const isExpanded = expandedModules.includes(module.id);

    return (
      <div key={module.id} className="animate-fade-in" style={{ animationDelay: `${level * 20}ms` }}>
        {/* Module Row */}
        <div
          className={`
            group flex items-center gap-2 px-3 py-2.5 rounded-xl transition-colors
            hover:bg-[var(--color-surface-hover)]
            ${level > 0 ? 'ml-6' : ''}
          `}
        >
          {/* Expand/Collapse or Indent */}
          <div className="w-6 flex-shrink-0">
            {hasChildren ? (
              <button
                onClick={() => toggleExpand(module.id)}
                className="p-1 hover:bg-[var(--color-surface-elevated)] rounded-md transition-colors"
              >
                {isExpanded ? (
                  <ChevronDownIcon className="w-4 h-4 text-[var(--color-text-muted)]" />
                ) : (
                  <ChevronRightIcon className="w-4 h-4 text-[var(--color-text-muted)]" />
                )}
              </button>
            ) : (
              <div className="w-4 h-4 ml-1 border-l-2 border-b-2 border-[var(--color-border)] rounded-bl" />
            )}
          </div>

          {/* Icon */}
          <div
            className={`
              w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0
              ${hasChildren
                ? 'bg-gradient-to-br from-amber-500 to-orange-600 shadow-lg shadow-amber-500/20'
                : 'bg-[var(--color-surface-elevated)]'
              }
            `}
          >
            {hasChildren ? (
              <FolderIcon className="w-4 h-4 text-white" />
            ) : (
              <DocumentIcon className="w-4 h-4 text-[var(--color-text-muted)]" />
            )}
          </div>

          {/* Module Info */}
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2">
              <span className="text-sm font-medium text-[var(--color-text-primary)] truncate">
                {module.name}
              </span>
              <span className="text-[10px] px-1.5 py-0.5 rounded bg-[var(--color-surface-elevated)] text-[var(--color-text-muted)]">
                {module.icon}
              </span>
            </div>
            <div className="flex items-center gap-2 text-xs text-[var(--color-text-muted)]">
              <span className="truncate">{module.path}</span>
              <span>•</span>
              <span>Order: {module.order}</span>
            </div>
          </div>

          {/* Status */}
          <span
            className={`badge flex-shrink-0 ${module.is_active ? 'badge-success' : 'badge-error'}`}
          >
            {module.is_active ? 'Active' : 'Inactive'}
          </span>

          {/* Actions */}
          <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
            {canEdit && (
              <Link
                to={`/modules/edit/${module.id}`}
                className="p-1.5 text-[var(--color-text-muted)] hover:text-[var(--color-accent)] hover:bg-[var(--color-accent-muted)] rounded-lg transition-colors"
                title="Edit"
              >
                <PencilSquareIcon className="w-4 h-4" />
              </Link>
            )}
            {canDelete && (
              <button
                onClick={() => handleDelete(module.id, module.name)}
                className="p-1.5 text-[var(--color-text-muted)] hover:text-[var(--color-error)] hover:bg-[var(--color-error-muted)] rounded-lg transition-colors"
                title="Delete"
              >
                <TrashIcon className="w-4 h-4" />
              </button>
            )}
          </div>
        </div>

        {/* Children */}
        {hasChildren && isExpanded && (
          <div className="relative">
            {/* Vertical line connector */}
            <div
              className="absolute left-[1.35rem] top-0 bottom-4 w-px bg-[var(--color-border)]"
              style={{ marginLeft: `${level * 24}px` }}
            />
            {module.children!.map((child, idx) =>
              renderModule(child, level + 1, idx === module.children!.length - 1)
            )}
          </div>
        )}
      </div>
    );
  };

  // Loading State
  if (loading) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div className="space-y-2">
            <div className="skeleton h-8 w-28 rounded-lg" />
            <div className="skeleton h-4 w-48 rounded-lg" />
          </div>
          <div className="skeleton h-10 w-32 rounded-xl" />
        </div>
        <div className="grid grid-cols-3 gap-4">
          {[...Array(3)].map((_, i) => (
            <div key={i} className="skeleton h-20 rounded-xl" />
          ))}
        </div>
        <div className="card p-4 space-y-3">
          {[...Array(6)].map((_, i) => (
            <div key={i} className="flex items-center gap-3">
              <div className="skeleton w-6 h-6 rounded" />
              <div className="skeleton w-8 h-8 rounded-lg" />
              <div className="flex-1 space-y-1">
                <div className="skeleton h-4 w-32 rounded" />
                <div className="skeleton h-3 w-24 rounded" />
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex items-start justify-between animate-fade-in">
        <div>
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Modules</h1>
          <p className="text-sm text-[var(--color-text-muted)] mt-1">
            Manage application modules and their hierarchy
          </p>
        </div>
        {canAdd && (
          <Link
            to="/modules/add"
            className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-medium text-white bg-gradient-to-r from-[var(--color-accent)] to-violet-600 rounded-xl hover:shadow-lg hover:shadow-[var(--color-accent)]/25 transition-all duration-300 hover:-translate-y-0.5"
          >
            <PlusIcon className="w-5 h-5" />
            Add Module
          </Link>
        )}
      </div>

      {/* Error Alert */}
      {error && (
        <div className="alert alert-error animate-fade-in-down">
          <ExclamationTriangleIcon className="w-5 h-5 flex-shrink-0" />
          <span>{error}</span>
          <button onClick={() => setError(null)} className="ml-auto p-1 hover:opacity-70">
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      )}

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 animate-fade-in-up">
        <div className="card p-4">
          <p className="text-xs text-[var(--color-text-muted)] uppercase tracking-wider">Total Modules</p>
          <p className="text-2xl font-bold text-[var(--color-text-primary)] mt-1">{totalCount}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-[var(--color-text-muted)] uppercase tracking-wider">Active</p>
          <p className="text-2xl font-bold text-[var(--color-success)] mt-1">{activeCount}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-[var(--color-text-muted)] uppercase tracking-wider">Parent Modules</p>
          <p className="text-2xl font-bold text-[var(--color-warning)] mt-1">{modules.length}</p>
        </div>
      </div>

      {/* Module Tree Card */}
      <div className="card animate-fade-in-up" style={{ animationDelay: '100ms' }}>
        {/* Search */}
        <div className="p-4 border-b border-[var(--color-border)]">
          <div className="relative max-w-sm">
            <MagnifyingGlassIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[var(--color-text-muted)]" />
            <input
              type="text"
              placeholder="Search modules..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="input pl-11 py-2.5"
            />
          </div>
        </div>

        {/* Module Tree */}
        <div className="p-4">
          {filteredModules.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <div className="w-16 h-16 rounded-2xl bg-[var(--color-surface-elevated)] flex items-center justify-center mb-4">
                <Squares2X2Icon className="w-8 h-8 text-[var(--color-text-muted)]" />
              </div>
              <h3 className="text-lg font-semibold text-[var(--color-text-primary)] mb-1">
                {searchQuery ? 'No modules found' : 'No modules yet'}
              </h3>
              <p className="text-sm text-[var(--color-text-muted)] mb-4">
                {searchQuery ? 'Try adjusting your search' : 'Get started by creating your first module'}
              </p>
              {!searchQuery && canAdd && (
                <Link
                  to="/modules/add"
                  className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-gradient-to-r from-[var(--color-accent)] to-violet-600 rounded-xl"
                >
                  <PlusIcon className="w-4 h-4" />
                  Add Module
                </Link>
              )}
            </div>
          ) : (
            <div className="space-y-1">
              {filteredModules.map((module, idx) => renderModule(module, 0, idx === filteredModules.length - 1))}
            </div>
          )}
        </div>

        {/* Footer */}
        {filteredModules.length > 0 && (
          <div className="px-4 py-3 border-t border-[var(--color-border)]">
            <p className="text-sm text-[var(--color-text-muted)]">
              Showing <span className="font-medium text-[var(--color-text-secondary)]">{countModules(filteredModules)}</span> of{' '}
              <span className="font-medium text-[var(--color-text-secondary)]">{totalCount}</span> modules
            </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default ModuleList;