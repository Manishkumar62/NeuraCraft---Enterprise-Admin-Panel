import { BrowserRouter } from 'react-router-dom';
import QueryProvider from './providers/QueryProvider';
import AppRoutes from './routes/AppRoutes';
import useThemeInitializer from './hooks/useThemeInitializer';

function App() {
  useThemeInitializer();
  return (
    <QueryProvider>
      <BrowserRouter>
        <AppRoutes />
      </BrowserRouter>
    </QueryProvider>
  );
}

export default App;