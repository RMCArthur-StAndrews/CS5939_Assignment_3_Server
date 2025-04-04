// src/components/Navbar.tsx
import React from 'react';

interface NavbarProps {
  onSelect: (section: string) => void;
}

const Navbar: React.FC<NavbarProps> = ({ onSelect }) => {
    /**
     * Render the navigation bar with links to different sections.
     */
  return (
    <div className="navbar">
      <a href="#" onClick={() => onSelect('serviceLogs')}>Service Logs</a>
      <a href="#" onClick={() => onSelect('visualisedMetrics')}>Visualised Metrics</a>
    </div>
  );
};

export default Navbar;