import { useEffect } from 'react';
import useThemeStore from '../store/themeStore';

/**
 * Hook to initialize theme on app startup
 * Use this in your App.tsx or main layout component
 * 
 * Example usage:
 * ```tsx
 * import useThemeInitializer from './hooks/useThemeInitializer';
 * 
 * function App() {
 *   useThemeInitializer();
 *   return <RouterProvider router={router} />;
 * }
 * ```
 */
const useThemeInitializer = () => {
  const initializeTheme = useThemeStore((state) => state.initializeTheme);

  useEffect(() => {
    initializeTheme();
  }, [initializeTheme]);
};

export default useThemeInitializer;