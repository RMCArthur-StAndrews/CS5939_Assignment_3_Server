import React, { useEffect, useState } from 'react';
import axios from 'axios';
import Plotly from 'plotly.js-dist';

interface CloudMetric {
  time_of_occurence: string;
  execution_hash: string;
  data: string;
  execution_time: number;
  memory_usage: number;
  processing_info: {
    peak_memory_usage: number;
  };
}

interface GroupedData {
  [key: string]: {
    x: string[];
    y: number[];
    type: string;
    name: string;
  };
}

const VisualisedMetrics: React.FC = () => {
  const [metrics, setMetrics] = useState<CloudMetric[]>([]);
  const [selectedGraph, setSelectedGraph] = useState<string>('memory');

  useEffect(() => {
    axios.get('http://127.0.0.1:5000/cloud-data-monitoring')
      .then(response => {
        console.log('Fetched data:', response.data); // Debugging log
        let parsedData;
        try {
          parsedData = JSON.parse(response.data);
        } catch (error) {
          console.error('Error parsing data:', error);
          return;
        }
        if (Array.isArray(parsedData)) {
          setMetrics(parsedData);
        } else {
          console.error('Parsed data is not an array:', parsedData);
          console.log('Type of parsed data:', typeof parsedData);
          console.log('Keys of parsed data:', Object.keys(parsedData));
        }
      })
      .catch(error => {
        console.error('Error fetching data:', error);
      });
  }, []);

  useEffect(() => {
    if (metrics.length > 0) {
      let data;
      if (selectedGraph === 'memory') {
        const groupedData = metrics.reduce<GroupedData>((acc, metric) => {
          const date = metric.time_of_occurence.split(' ')[0];
          if (!acc[date]) {
            acc[date] = { x: [], y: [], type: 'bar', name: date };
          }
          acc[date].x.push(metric.time_of_occurence);
          acc[date].y.push(metric.memory_usage);
          return acc;
        }, {});
        data = Object.values(groupedData);
      } else if (selectedGraph === 'task') {
        const groupedData = metrics.reduce<GroupedData>((acc, metric) => {
          const date = metric.time_of_occurence.split(' ')[0];
          if (!acc[date]) {
            acc[date] = { x: [], y: [], type: 'bar', name: date };
          }
          const taskIndex = acc[date].x.indexOf(metric.data);
          if (taskIndex === -1) {
            acc[date].x.push(metric.data);
            acc[date].y.push(1);
          } else {
            acc[date].y[taskIndex] += 1;
          }
          return acc;
        }, {});
        data = Object.values(groupedData);
      }
      Plotly.newPlot('plotlyGraph', data);
    }
  }, [metrics, selectedGraph]);

  return (
    <div>
      <h2>Visualised Metrics</h2>
      <select onChange={(e) => setSelectedGraph(e.target.value)} value={selectedGraph}>
        <option value="memory">Memory Consumption</option>
        <option value="task">Task Count</option>
      </select>
      <div id="plotlyGraph"></div>
    </div>
  );
};

export default VisualisedMetrics;