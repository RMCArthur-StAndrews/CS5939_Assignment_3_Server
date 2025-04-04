// src/App.tsx
import React, { useState } from 'react';
import './app.css';
import Navbar from './Navbar';
import ServiceLogs from './ServiceLogs';
import VisualisedMetrics from './VisualisedMetrics';

const App: React.FC = () => {
  /**
   * State to manage the currently selected section of the dashboard.
   */
  const [selectedSection, setSelectedSection] = useState<string>('serviceLogs');

  /**
   * Function to determine which of the pages are to be rendered
   */
  const renderContent = () => {
    switch (selectedSection) {
      case 'serviceLogs':
        return <ServiceLogs />;
      case 'visualisedMetrics':
        return <VisualisedMetrics />;
      default:
        return null;
    }
  };

  /**
   * Render the main application component.
   */
  return (
    <div>
      <Navbar onSelect={setSelectedSection} />
      <div className="content">
        {renderContent()}
      </div>
    </div>
  );
};

export default App;