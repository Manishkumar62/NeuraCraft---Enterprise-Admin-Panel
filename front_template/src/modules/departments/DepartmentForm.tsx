import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import departmentService, { type CreateDepartmentData, type UpdateDepartmentData } from './services';
import {
  ArrowLeftIcon,
  BuildingOfficeIcon,
  CodeBracketIcon,
  DocumentTextIcon,
  ExclamationTriangleIcon,
  XMarkIcon,
} from '@heroicons/react/24/outline';

const DepartmentForm = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const isEdit = Boolean(id);

  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [formData, setFormData] = useState({
    name: '',
    code: '',
    description: '',
    is_active: true,
  });

  useEffect(() => {
    if (isEdit) {
      fetchDepartment();
    }
  }, [id]);

  const fetchDepartment = async () => {
    try {
      setLoading(true);
      const dept = await departmentService.getById(Number(id));
      setFormData({
        name: dept.name,
        code: dept.code || '',
        description: dept.description || '',
        is_active: dept.is_active,
      });
    } catch (err) {
      setError('Failed to fetch department');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value, type } = e.target;
    setFormData({
      ...formData,
      [name]: type === 'checkbox' ? (e.target as HTMLInputElement).checked : value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSaving(true);

    try {
      if (isEdit) {
        const updateData: UpdateDepartmentData = {
          name: formData.name,
          code: formData.code,
          description: formData.description,
          is_active: formData.is_active,
        };
        await departmentService.update(Number(id), updateData);
      } else {
        const createData: CreateDepartmentData = {
          name: formData.name,
          code: formData.code,
          description: formData.description,
          is_active: formData.is_active,
        };
        await departmentService.create(createData);
      }
      navigate('/departments');
    } catch (err: any) {
      const message =
        err.response?.data?.detail ||
        err.response?.data?.message ||
        Object.values(err.response?.data || {}).flat().join(', ') ||
        'Failed to save department';
      setError(message);
    } finally {
      setSaving(false);
    }
  };

  // Loading State
  if (loading) {
    return (
      <div className="space-y-6 max-w-2xl">
        <div className="flex items-center gap-4">
          <div className="skeleton w-10 h-10 rounded-xl" />
          <div className="skeleton h-8 w-40 rounded-lg" />
        </div>
        <div className="card p-5 space-y-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="space-y-1.5">
              <div className="skeleton h-3 w-20 rounded" />
              <div className="skeleton h-10 w-full rounded-lg" />
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-2xl">
      {/* Header */}
      <div className="flex items-center gap-4 animate-fade-in">
        <button
          onClick={() => navigate('/departments')}
          className="p-2.5 text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)] rounded-xl transition-colors"
        >
          <ArrowLeftIcon className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">
            {isEdit ? 'Edit Department' : 'Add Department'}
          </h1>
          <p className="text-sm text-[var(--color-text-muted)] mt-0.5">
            {isEdit ? 'Update department information' : 'Create a new department'}
          </p>
        </div>
      </div>

      {/* Error */}
      {error && (
        <div className="alert alert-error animate-fade-in-down">
          <ExclamationTriangleIcon className="w-5 h-5 flex-shrink-0" />
          <span>{error}</span>
          <button onClick={() => setError(null)} className="ml-auto p-1 hover:opacity-70">
            <XMarkIcon className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* Form Card */}
      <div className="card animate-fade-in-up">
        <form onSubmit={handleSubmit}>
          <div className="p-5 space-y-4">
            {/* Row 1: Name & Code */}
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="label text-xs">Name <span className="text-[var(--color-error)]">*</span></label>
                <div className="relative">
                  <BuildingOfficeIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
                  <input
                    type="text"
                    name="name"
                    value={formData.name}
                    onChange={handleChange}
                    required
                    placeholder="Department name"
                    className="input pl-10 py-2 text-sm"
                  />
                </div>
              </div>
              <div className="space-y-1.5">
                <label className="label text-xs">Code <span className="text-[var(--color-error)]">*</span></label>
                <div className="relative">
                  <CodeBracketIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
                  <input
                    type="text"
                    name="code"
                    value={formData.code}
                    onChange={handleChange}
                    required
                    placeholder="HR, IT, FIN"
                    className="input pl-10 py-2 text-sm font-mono uppercase"
                  />
                </div>
              </div>
            </div>

            {/* Description */}
            <div className="space-y-1.5">
              <label className="label text-xs">Description</label>
              <div className="relative">
                <DocumentTextIcon className="absolute left-3 top-3 w-4 h-4 text-[var(--color-text-muted)]" />
                <textarea
                  name="description"
                  value={formData.description}
                  onChange={handleChange}
                  rows={3}
                  placeholder="Brief description of the department"
                  className="input pl-10 py-2 text-sm min-h-[80px] resize-y"
                />
              </div>
            </div>

            {/* Active Toggle */}
            <div className="space-y-1.5">
              <label className="flex items-center gap-3 cursor-pointer p-3 rounded-xl border border-[var(--color-border)] hover:border-[var(--color-border-hover)] transition-colors">
                <div className="relative">
                  <input
                    type="checkbox"
                    name="is_active"
                    checked={formData.is_active}
                    onChange={handleChange}
                    className="peer sr-only"
                  />
                  <div className="w-9 h-5 bg-[var(--color-surface-elevated)] border border-[var(--color-border)] rounded-full peer-checked:bg-[var(--color-success)] peer-checked:border-[var(--color-success)] transition-all" />
                  <div className="absolute top-0.5 left-0.5 w-4 h-4 bg-[var(--color-text-muted)] rounded-full peer-checked:translate-x-4 peer-checked:bg-white transition-all" />
                </div>
                <div>
                  <span className="text-sm font-medium text-[var(--color-text-primary)]">Active Status</span>
                  <p className="text-xs text-[var(--color-text-muted)]">
                    {formData.is_active ? 'Department is active' : 'Department is inactive'}
                  </p>
                </div>
              </label>
            </div>
          </div>

          {/* Actions */}
          <div className="px-5 py-4 border-t border-[var(--color-border)] flex items-center justify-end gap-3 bg-[var(--color-surface-elevated)]/30">
            <button type="button" onClick={() => navigate('/departments')} className="btn btn-secondary">
              Cancel
            </button>
            <button type="submit" disabled={saving} className="btn btn-primary min-w-[140px]">
              {saving ? (
                <>
                  <div className="spinner" />
                  <span>Saving...</span>
                </>
              ) : (
                <span>{isEdit ? 'Update Department' : 'Create Department'}</span>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default DepartmentForm;