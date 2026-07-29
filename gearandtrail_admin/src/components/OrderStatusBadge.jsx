import React from 'react';

export default function OrderStatusBadge({ status }) {
  let badgeClass = 'badge-status-diproses';
  
  if (status === 'Sedang Dikirim') {
    badgeClass = 'badge-status-dikirim';
  } else if (status === 'Selesai') {
    badgeClass = 'badge-status-selesai';
  }

  return (
    <span className={`badge-status ${badgeClass}`}>
      {status}
    </span>
  );
}
