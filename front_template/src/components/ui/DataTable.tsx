import { useState, type ReactNode } from 'react';
import {
  ChevronUpIcon,
  ChevronDownIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  MagnifyingGlassIcon,
} from '@heroicons/react/24/outline';
import { Skeleton, EmptyState } from '../ui';

/* ============================================
   COLUMN DEFINITION
   ============================================ */
export interface Column<T> {
  key: keyof T | string;
  header: string;
  sortable?: boolean;
  width?: string;
  render?: (item: T, index: number) => ReactNode;
}

/* ============================================
   DATA TABLE PROPS
   ============================================ */
interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  isLoading?: boolean;
  emptyState?: {
    icon?: ReactNode;
    title: string;
    description?: string;
    action?: ReactNode;
  };
  searchable?: boolean;
  searchPlaceholder?: string;
  onSearch?: (query: string) => void;
  pagination?: {
    currentPage: number;
    totalPages: number;
    totalItems: number;
    itemsPerPage: number;
    onPageChange: (page: number) => void;
  };
  actions?: ReactNode;
  selectable?: boolean;
  selectedIds?: (string | number)[];
  onSelectionChange?: (ids: (string | number)[]) => void;
  getRowId?: (item: T) => string | number;
}

/* ============================================
   DATA TABLE COMPONENT
   ============================================ */
export function DataTable<T extends Record<string, unknown>>({
  data,
  columns,
  isLoading,
  emptyState,
  searchable,
  searchPlaceholder = 'Search...',
  onSearch,
  pagination,
  actions,
  selectable,
  selectedIds = [],
  onSelectionChange,
  getRowId = (item) => item.id as string | number,
}: DataTableProps<T>) {
  const [searchQuery, setSearchQuery] = useState('');
  const [sortKey, setSortKey] = useState<string | null>(null);
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('asc');

  // Handle search
  const handleSearch = (e: React.ChangeEvent<HTMLInputElement>) => {
    const query = e.target.value;
    setSearchQuery(query);
    onSearch?.(query);
  };

  // Handle sort
  const handleSort = (key: string) => {
    if (sortKey === key) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortKey(key);
      setSortDirection('asc');
    }
  };

  // Handle row selection
  const handleSelectAll = () => {
    if (!onSelectionChange) return;
    if (selectedIds.length === data.length) {
      onSelectionChange([]);
    } else {
      onSelectionChange(data.map(getRowId));
    }
  };

  const handleSelectRow = (id: string | number) => {
    if (!onSelectionChange) return;
    if (selectedIds.includes(id)) {
      onSelectionChange(selectedIds.filter((i) => i !== id));
    } else {
      onSelectionChange([...selectedIds, id]);
    }
  };

  // Sort data if needed
  const sortedData = sortKey
    ? [...data].sort((a, b) => {
        const aVal = a[sortKey as keyof T];
        const bVal = b[sortKey as keyof T];
        if (aVal < bVal) return sortDirection === 'asc' ? -1 : 1;
        if (aVal > bVal) return sortDirection === 'asc' ? 1 : -1;
        return 0;
      })
    : data;

  // Get cell value
  const getCellValue = (item: T, column: Column<T>, index: number): ReactNode => {
    if (column.render) {
      return column.render(item, index);
    }
    const value = item[column.key as keyof T];
    if (value === null || value === undefined) return '-';
    return String(value);
  };

  return (
    <div className="space-y-4">
      {/* Toolbar */}
      {(searchable || actions) && (
        <div className="flex items-center justify-between gap-4">
          {/* Search */}
          {searchable && (
            <div className="relative max-w-xs">
              <MagnifyingGlassIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
              <input
                type="text"
                value={searchQuery}
                onChange={handleSearch}
                placeholder={searchPlaceholder}
                className="input pl-9 pr-4 py-2 text-sm"
              />
            </div>
          )}
          
          {/* Actions */}
          {actions && <div className="flex items-center gap-2">{actions}</div>}
        </div>
      )}

      {/* Table Container */}
      <div className="table-container">
        <table className="table">
          <thead>
            <tr>
              {/* Selection Checkbox */}
              {selectable && (
                <th className="w-12">
                  <label className="flex items-center justify-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={selectedIds.length === data.length && data.length > 0}
                      onChange={handleSelectAll}
                      className="sr-only peer"
                    />
                    <div className="w-5 h-5 rounded-md border border-[var(--color-border)] bg-[var(--color-surface)] peer-checked:bg-[var(--color-accent)] peer-checked:border-[var(--color-accent)] transition-all duration-200 flex items-center justify-center">
                      <svg
                        className="w-3 h-3 text-white opacity-0 peer-checked:opacity-100"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        strokeWidth={3}
                      >
                        <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                      </svg>
                    </div>
                  </label>
                </th>
              )}
              
              {/* Column Headers */}
              {columns.map((column) => (
                <th
                  key={String(column.key)}
                  style={{ width: column.width }}
                  className={column.sortable ? 'cursor-pointer select-none hover:bg-[var(--color-surface-hover)]' : ''}
                  onClick={() => column.sortable && handleSort(String(column.key))}
                >
                  <div className="flex items-center gap-2">
                    <span>{column.header}</span>
                    {column.sortable && (
                      <div className="flex flex-col">
                        <ChevronUpIcon
                          className={`w-3 h-3 -mb-1 ${
                            sortKey === column.key && sortDirection === 'asc'
                              ? 'text-[var(--color-accent)]'
                              : 'text-[var(--color-text-muted)]'
                          }`}
                        />
                        <ChevronDownIcon
                          className={`w-3 h-3 ${
                            sortKey === column.key && sortDirection === 'desc'
                              ? 'text-[var(--color-accent)]'
                              : 'text-[var(--color-text-muted)]'
                          }`}
                        />
                      </div>
                    )}
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {/* Loading State */}
            {isLoading && (
              <>
                {Array.from({ length: 5 }).map((_, i) => (
                  <tr key={i}>
                    {selectable && (
                      <td>
                        <Skeleton className="w-5 h-5 rounded-md" />
                      </td>
                    )}
                    {columns.map((column) => (
                      <td key={String(column.key)}>
                        <Skeleton className="h-5 w-full rounded" />
                      </td>
                    ))}
                  </tr>
                ))}
              </>
            )}

            {/* Data Rows */}
            {!isLoading &&
              sortedData.map((item, index) => {
                const rowId = getRowId(item);
                const isSelected = selectedIds.includes(rowId);

                return (
                  <tr
                    key={rowId}
                    className={isSelected ? 'bg-[var(--color-accent-muted)]' : ''}
                  >
                    {/* Selection Checkbox */}
                    {selectable && (
                      <td>
                        <label className="flex items-center justify-center cursor-pointer">
                          <input
                            type="checkbox"
                            checked={isSelected}
                            onChange={() => handleSelectRow(rowId)}
                            className="sr-only peer"
                          />
                          <div className="w-5 h-5 rounded-md border border-[var(--color-border)] bg-[var(--color-surface)] peer-checked:bg-[var(--color-accent)] peer-checked:border-[var(--color-accent)] transition-all duration-200 flex items-center justify-center">
                            <svg
                              className="w-3 h-3 text-white opacity-0 peer-checked:opacity-100"
                              fill="none"
                              viewBox="0 0 24 24"
                              stroke="currentColor"
                              strokeWidth={3}
                            >
                              <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                            </svg>
                          </div>
                        </label>
                      </td>
                    )}

                    {/* Data Cells */}
                    {columns.map((column) => (
                      <td key={String(column.key)}>
                        {getCellValue(item, column, index)}
                      </td>
                    ))}
                  </tr>
                );
              })}
          </tbody>
        </table>

        {/* Empty State */}
        {!isLoading && sortedData.length === 0 && emptyState && (
          <EmptyState
            icon={emptyState.icon}
            title={emptyState.title}
            description={emptyState.description}
            action={emptyState.action}
          />
        )}
      </div>

      {/* Pagination */}
      {pagination && pagination.totalPages > 1 && (
        <div className="flex items-center justify-between px-2">
          <p className="text-sm text-[var(--color-text-muted)]">
            Showing{' '}
            <span className="font-medium text-[var(--color-text-secondary)]">
              {(pagination.currentPage - 1) * pagination.itemsPerPage + 1}
            </span>{' '}
            to{' '}
            <span className="font-medium text-[var(--color-text-secondary)]">
              {Math.min(pagination.currentPage * pagination.itemsPerPage, pagination.totalItems)}
            </span>{' '}
            of{' '}
            <span className="font-medium text-[var(--color-text-secondary)]">
              {pagination.totalItems}
            </span>{' '}
            results
          </p>

          <div className="flex items-center gap-1">
            {/* Previous Button */}
            <button
              onClick={() => pagination.onPageChange(pagination.currentPage - 1)}
              disabled={pagination.currentPage === 1}
              className="p-2 text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)] rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <ChevronLeftIcon className="w-5 h-5" />
            </button>

            {/* Page Numbers */}
            {Array.from({ length: Math.min(5, pagination.totalPages) }, (_, i) => {
              let page: number;
              if (pagination.totalPages <= 5) {
                page = i + 1;
              } else if (pagination.currentPage <= 3) {
                page = i + 1;
              } else if (pagination.currentPage >= pagination.totalPages - 2) {
                page = pagination.totalPages - 4 + i;
              } else {
                page = pagination.currentPage - 2 + i;
              }

              return (
                <button
                  key={page}
                  onClick={() => pagination.onPageChange(page)}
                  className={`w-9 h-9 text-sm font-medium rounded-lg transition-colors ${
                    pagination.currentPage === page
                      ? 'bg-[var(--color-accent)] text-white'
                      : 'text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)]'
                  }`}
                >
                  {page}
                </button>
              );
            })}

            {/* Next Button */}
            <button
              onClick={() => pagination.onPageChange(pagination.currentPage + 1)}
              disabled={pagination.currentPage === pagination.totalPages}
              className="p-2 text-[var(--color-text-muted)] hover:text-[var(--color-text-primary)] hover:bg-[var(--color-surface-hover)] rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <ChevronRightIcon className="w-5 h-5" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

export default DataTable;