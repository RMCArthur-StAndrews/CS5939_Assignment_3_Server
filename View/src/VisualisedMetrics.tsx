// src/components/VisualisedMetrics.tsx
import React, { useEffect } from 'react';
import Plotly from 'plotly.js-dist';

const VisualisedMetrics: React.FC = () => {
  useEffect(() => {
    const data = [{
      x: [1, 2, 3, 4, 5],
      y: [10, 15, 13, 17, 21],
      type: 'scatter'
    }];
    Plotly.newPlot('plotlyGraph', data);
  }, []);

  return (
    <div>
      <h2>Visualised Metrics</h2>
      <div id="plotlyGraph"></div>
    </div>
  );
};

export default VisualisedMetrics;