import { useState } from 'react';
import { SunIcon, MoonIcon } from '@heroicons/react/24/outline';
import useThemeStore from '../../store/themeStore';

const ThemeToggle = () => {
  const { resolvedTheme, toggleTheme } = useThemeStore();
  const [isAnimating, setIsAnimating] = useState(false);

  const handleToggle = () => {
    setIsAnimating(true);
    toggleTheme();
    
    // Reset animation state after animation completes
    setTimeout(() => {
      setIsAnimating(false);
    }, 500);
  };

  const isDark = resolvedTheme === 'dark';

  return (
    <button
      onClick={handleToggle}
      className={`
        relative p-2.5 rounded-xl
        text-[var(--color-text-muted)] 
        hover:text-[var(--color-text-primary)] 
        hover:bg-[var(--color-surface-hover)]
        transition-all duration-200
        overflow-hidden
        group
      `}
      aria-label={isDark ? 'Switch to light mode' : 'Switch to dark mode'}
      title={isDark ? 'Switch to light mode' : 'Switch to dark mode'}
    >
      {/* Background glow on hover */}
      <span className="absolute inset-0 rounded-xl bg-[var(--color-accent-muted)] opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
      
      {/* Icon container */}
      <span className={`relative block w-5 h-5 ${isAnimating ? 'animate-theme-toggle' : ''}`}>
        {isDark ? (
          <SunIcon className="w-5 h-5" />
        ) : (
          <MoonIcon className="w-5 h-5" />
        )}
      </span>
    </button>
  );
};

export default ThemeToggle;