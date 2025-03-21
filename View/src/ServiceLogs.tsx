import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Table } from 'react-bootstrap';
import 'bootstrap/dist/css/bootstrap.min.css';

interface MonitoringData {
  time_of_occurence: string;
  execution_hash: string;
  data: string;
  execution_time: number;
  memory_usage: number;
  processing_info: {
    peak_memory_usage: number;
  };
}

const ServiceLogs: React.FC = () => {
  const [logs, setLogs] = useState<MonitoringData[]>([]);

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
          setLogs(parsedData);
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

  return (
    <div>
      <h2>Service Logs</h2>
      <Table striped bordered hover>
        <thead>
          <tr>
            <th>Timestamp</th>
            <th>Execution Hash</th>
            <th>Data</th>
            <th>Execution Time</th>
            <th>Memory Usage</th>
            <th>Peak Memory Usage</th>
          </tr>
        </thead>
        <tbody>
          {logs.map((log, index) => (
            <tr key={index}>
              <td>{log.time_of_occurence}</td>
              <td>{log.execution_hash}</td>
              <td>{log.data}</td>
              <td>{log.execution_time}</td>
              <td>{log.memory_usage}</td>
              <td>{log.processing_info.peak_memory_usage}</td>
            </tr>
          ))}
        </tbody>
      </Table>
    </div>
  );
};

export default ServiceLogs;