import React from 'react';
import ReactDOM from 'react-dom/client';
import MetricsDashboard from './MetricsDashboard';

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement);
root.render(
  <React.StrictMode>
    <MetricsDashboard />
  </React.StrictMode>
);