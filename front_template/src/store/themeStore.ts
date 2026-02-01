import { create } from 'zustand';
import { persist } from 'zustand/middleware';

type Theme = 'light' | 'dark' | 'system';
type ResolvedTheme = 'light' | 'dark';

interface ThemeState {
  theme: Theme;
  resolvedTheme: ResolvedTheme;
  setTheme: (theme: Theme) => void;
  toggleTheme: () => void;
  initializeTheme: () => void;
}

// Get system preference
const getSystemTheme = (): ResolvedTheme => {
  if (typeof window !== 'undefined') {
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }
  return 'dark';
};

// Apply theme to document
const applyTheme = (theme: ResolvedTheme) => {
  const root = document.documentElement;
  
  // Add transition class for smooth theme change
  root.classList.add('theme-transition');
  
  // Set the theme attribute
  if (theme === 'dark') {
    root.removeAttribute('data-theme');
  } else {
    root.setAttribute('data-theme', theme);
  }
  
  // Remove transition class after animation completes
  setTimeout(() => {
    root.classList.remove('theme-transition');
  }, 300);
};

// Resolve the actual theme (handles 'system' option)
const resolveTheme = (theme: Theme): ResolvedTheme => {
  if (theme === 'system') {
    return getSystemTheme();
  }
  return theme;
};

const useThemeStore = create<ThemeState>()(
  persist(
    (set, get) => ({
      theme: 'dark',
      resolvedTheme: 'dark',

      setTheme: (theme: Theme) => {
        const resolved = resolveTheme(theme);
        applyTheme(resolved);
        set({ theme, resolvedTheme: resolved });
      },

      toggleTheme: () => {
        const { resolvedTheme } = get();
        const newTheme: Theme = resolvedTheme === 'dark' ? 'light' : 'dark';
        const resolved = resolveTheme(newTheme);
        applyTheme(resolved);
        set({ theme: newTheme, resolvedTheme: resolved });
      },

      initializeTheme: () => {
        const { theme } = get();
        const resolved = resolveTheme(theme);
        applyTheme(resolved);
        set({ resolvedTheme: resolved });

        // Listen for system theme changes (when theme is 'system')
        if (typeof window !== 'undefined') {
          const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
          
          const handleChange = () => {
            const currentTheme = get().theme;
            if (currentTheme === 'system') {
              const newResolved = getSystemTheme();
              applyTheme(newResolved);
              set({ resolvedTheme: newResolved });
            }
          };

          mediaQuery.addEventListener('change', handleChange);
        }
      },
    }),
    {
      name: 'neuracraft-theme',
      partialize: (state) => ({ theme: state.theme }),
    }
  )
);

export default useThemeStore;