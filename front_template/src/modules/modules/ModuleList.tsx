import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import type { Module } from '../../types';
import usePermissions from '../../hooks/usePermissions';
import moduleService from './services';
import {
    PlusIcon,
    PencilSquareIcon,
    TrashIcon,
    ChevronRightIcon,
} from '@heroicons/react/24/outline';

const ModuleList = () => {
    const [modules, setModules] = useState<Module[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const { canAdd, canEdit, canDelete } = usePermissions('/modules');

    useEffect(() => {
        fetchModules();
    }, []);

    const fetchModules = async () => {
        try {
            setLoading(true);
            const data = await moduleService.getAll();
            setModules(data);
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
                fetchModules(); // Refresh to update nested structure
            } catch (err) {
                setError('Failed to delete module');
            }
        }
    };

    const renderModule = (module: Module, level: number = 0) => {
        const hasChildren = module.children && module.children.length > 0;

        return (
            <div key={module.id}>
                <div
                    className={`flex items-center justify-between py-3 px-4 hover:bg-gray-50 border-b border-gray-100 ${level > 0 ? 'bg-gray-50' : ''
                        }`}
                    style={{ paddingLeft: `${level * 24 + 16}px` }}
                >
                    <div className="flex items-center gap-3">
                        {hasChildren && (
                            <ChevronRightIcon className="w-4 h-4 text-gray-400" />
                        )}
                        {!hasChildren && level > 0 && (
                            <span className="w-4" />
                        )}
                        <div>
                            <div className="flex items-center gap-2">
                                <span className="text-sm font-medium text-gray-900">
                                    {module.name}
                                </span>
                                <span className="text-xs text-gray-500 bg-gray-100 px-2 py-0.5 rounded">
                                    {module.icon}
                                </span>
                            </div>
                            <div className="text-xs text-gray-500">
                                Path: {module.path} | Order: {module.order}
                            </div>
                        </div>
                    </div>

                    <div className="flex items-center gap-3">
                        <span
                            className={`px-2 py-1 text-xs font-medium rounded-full ${module.is_active
                                    ? 'bg-green-100 text-green-800'
                                    : 'bg-red-100 text-red-800'
                                }`}
                        >
                            {module.is_active ? 'Active' : 'Inactive'}
                        </span>
                        {canEdit && (
                            <Link
                                to={`/modules/edit/${module.id}`}
                                className="text-blue-600 hover:text-blue-900"
                            >
                                <PencilSquareIcon className="w-5 h-5" />
                            </Link>
                        )}
                        {canDelete && (
                            <button
                                onClick={() => handleDelete(module.id, module.name)}
                                className="text-red-600 hover:text-red-900"
                            >
                                <TrashIcon className="w-5 h-5" />
                            </button>
                        )}
                    </div>
                </div>

                {/* Render children */}
                {hasChildren &&
                    module.children!.map((child) => renderModule(child, level + 1))}
            </div>
        );
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center h-64">
                <div className="text-gray-600">Loading modules...</div>
            </div>
        );
    }

    return (
        <div>
            <div className="flex items-center justify-between mb-6">
                <h1 className="text-2xl font-bold text-gray-800">Modules</h1>
                {canAdd && (
                    <Link
                        to="/modules/add"
                        className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                    >
                        <PlusIcon className="w-5 h-5" />
                        Add Module
                    </Link>
                )}
            </div>

            {error && (
                <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                    {error}
                </div>
            )}

            <div className="bg-white rounded-lg shadow overflow-hidden">
                <div className="px-4 py-3 bg-gray-50 border-b border-gray-200">
                    <div className="flex items-center justify-between text-xs font-medium text-gray-500 uppercase tracking-wider">
                        <span>Module</span>
                        <span>Actions</span>
                    </div>
                </div>

                {modules.length === 0 ? (
                    <div className="px-6 py-4 text-center text-gray-500">
                        No modules found
                    </div>
                ) : (
                    modules.map((module) => renderModule(module))
                )}
            </div>
        </div>
    );
};

export default ModuleList;