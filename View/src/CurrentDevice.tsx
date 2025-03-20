// src/components/CurrentDevices.tsx
import React from 'react';

const CurrentDevice: React.FC = () => {
  return (
    <div>
      <h2>Current Connected Devices</h2>
      <table border={1}>
        <tr>
          <th>Device ID</th>
          <th>Device Name</th>
          <th>Status</th>
        </tr>
        <tr>
          <td>1</td>
          <td>Device A</td>
          <td>Connected</td>
        </tr>
        {/* Add more rows as needed */}
      </table>
    </div>
  );
};

export default CurrentDevice;