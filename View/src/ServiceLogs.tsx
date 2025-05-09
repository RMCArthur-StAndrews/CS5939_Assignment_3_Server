import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Table, Form } from 'react-bootstrap';
import 'bootstrap/dist/css/bootstrap.min.css';

/**
 * Establishes base URL for API requests.
 */
const api = axios.create({
  baseURL: "http://localhost:5000",
});

/**
 * Template for inbound monitoring data
 */
interface MonitoringData {
  time_of_occurence: string;
  execution_hash: string;
  data: string;
  execution_time: number;
  memory_usage: number;
  processing_info: {
    cpu_usage: {
      user_time: number;
      system_time: number;
    };
  };
}

/**
 * Component to display service logs in a table format.
 */
const ServiceLogs: React.FC = () => {
  const [logs, setLogs] = useState<MonitoringData[]>([]);
  const [filterValue, setFilterValue] = useState<string>(''); // State for filter value
  const [startDate, setStartDate] = useState<string>(''); // State for start date
  const [endDate, setEndDate] = useState<string>(''); // State for end date

  /**
   * Fetch data from the API set the current data
   */
  useEffect(() => {
    api.get('/cloud-data-monitoring')
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

  /**
   * Filter logs based on the filter value and date-time range
   */
  const filteredLogs = logs.filter(log => {
    const logDate = new Date(log.time_of_occurence);
    const isWithinDateRange =
      (!startDate || logDate >= new Date(startDate)) &&
      (!endDate || logDate <= new Date(endDate));
    return (
      log.data.toLowerCase().includes(filterValue.toLowerCase()) && isWithinDateRange
    );
  });

  /**
   * Render the service logs table.
   */
  return (
    <div>
      <h2>Service Logs</h2>
      <Form.Group controlId="filterData">
        <Form.Label>Filter by Data</Form.Label>
        <Form.Control
          type="text"
          placeholder="Enter value to filter"
          value={filterValue}
          onChange={(e) => setFilterValue(e.target.value)}
        />
      </Form.Group>
      <Form.Group controlId="filterStartDate">
        <Form.Label>Start Date</Form.Label>
        <Form.Control
          type="datetime-local"
          value={startDate}
          onChange={(e) => setStartDate(e.target.value)}
        />
      </Form.Group>
      <Form.Group controlId="filterEndDate">
        <Form.Label>End Date</Form.Label>
        <Form.Control
          type="datetime-local"
          value={endDate}
          onChange={(e) => setEndDate(e.target.value)}
        />
      </Form.Group>
      <Table striped bordered hover>
        <thead>
          <tr>
            <th>Timestamp</th>
            <th>Execution Hash</th>
            <th>Data</th>
            <th>Execution Time</th>
            <th>Memory Usage (Mbs)</th>
            <th>User CPU Time (0.00 Seconds)</th>
            <th>System CPU Time (0.00 Seconds)</th>
          </tr>
        </thead>
        <tbody>
          {filteredLogs.map((log, index) => (
            <tr key={index}>
              <td>{log.time_of_occurence}</td>
              <td>{log.execution_hash}</td>
              <td>{log.data}</td>
              <td>{log.execution_time}</td>
              <td>{log.memory_usage}</td>
              <td>{log.processing_info.cpu_usage.user_time}</td>
              <td>{log.processing_info.cpu_usage.system_time}</td>
            </tr>
          ))}
        </tbody>
      </Table>
    </div>
  );
};

export default ServiceLogs;