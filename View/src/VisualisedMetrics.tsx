// src/components/VisualisedMetrics.tsx
import React, { useEffect, useState } from 'react';
import Plotly from 'plotly.js-dist';

interface CloudMetric {
  timestamp: string;
  metric_name: string;
  value: number;
  unit: string;
}

interface GroupedData {
  [key: string]: {
    x: string[];
    y: number[];
    type: string;
    name: string;
  };
}

const sampleCloudMetrics: CloudMetric[] = [
  {
    timestamp: '2023-10-01T12:00:00Z',
    metric_name: 'CPU Usage',
    value: 75.5,
    unit: '%'
  },
  {
    timestamp: '2023-10-01T12:05:00Z',
    metric_name: 'Memory Usage',
    value: 60.2,
    unit: 'MB'
  },
  {
    timestamp: '2023-10-01T12:10:00Z',
    metric_name: 'Disk I/O',
    value: 120.4,
    unit: 'MB/s'
  },
  {
    timestamp: '2023-10-01T12:15:00Z',
    metric_name: 'Network Throughput',
    value: 300.1,
    unit: 'Mbps'
  },
  {
    timestamp: '2023-10-01T12:20:00Z',
    metric_name: 'CPU Usage',
    value: 80.3,
    unit: '%'
  }
];

const VisualisedMetrics: React.FC = () => {
  const [metrics, setMetrics] = useState<CloudMetric[]>(sampleCloudMetrics);

  useEffect(() => {
    if (metrics.length > 0) {
      const groupedData = metrics.reduce<GroupedData>((acc, metric) => {
        if (!acc[metric.metric_name]) {
          acc[metric.metric_name] = { x: [], y: [], type: 'scatter', name: metric.metric_name };
        }
        acc[metric.metric_name].x.push(metric.timestamp);
        acc[metric.metric_name].y.push(metric.value);
        return acc;
      }, {});

      const data = Object.values(groupedData);
      Plotly.newPlot('plotlyGraph', data);
    }
  }, [metrics]);

  return (
    <div>
      <h2>Visualised Metrics</h2>
      <div id="plotlyGraph"></div>
    </div>
  );
};

export default VisualisedMetrics;