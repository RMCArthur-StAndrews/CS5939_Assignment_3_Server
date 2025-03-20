// src/components/ServiceLogs.tsx
import React from 'react';

const ServiceLogs: React.FC = () => {
  return (
    <div>
      <h2>Service Logs</h2>
      <table border={1}>
        <tr>
          <th>Timestamp</th>
          <th>Service</th>
          <th>Status</th>
        </tr>
        <tr>
          <td>2023-10-01 12:00:00</td>
          <td>API Service</td>
          <td>Running</td>
        </tr>
        {/* Add more rows as needed */}
      </table>
    </div>
  );
};

export default ServiceLogs;