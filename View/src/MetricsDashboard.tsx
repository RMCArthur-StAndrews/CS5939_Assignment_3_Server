// src/App.tsx
import React, { useState } from 'react';
import './app.css';
import Navbar from './Navbar';
import ServiceLogs from './ServiceLogs';
import VisualisedMetrics from './VisualisedMetrics';
import CurrentDevice from './CurrentDevice';

const App: React.FC = () => {
  const [selectedSection, setSelectedSection] = useState<string>('serviceLogs');

  const renderContent = () => {
    switch (selectedSection) {
      case 'serviceLogs':
        return <ServiceLogs />;
      case 'visualisedMetrics':
        return <VisualisedMetrics />;
      case 'currentDevices':
        return <CurrentDevice />;
      default:
        return null;
    }
  };

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