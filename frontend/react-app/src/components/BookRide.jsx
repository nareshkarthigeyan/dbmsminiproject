import React, { useState } from 'react';
import api from '../api';

export default function BookRide(){
  const [userId, setUserId] = useState(1);
  const [source, setSource] = useState('');
  const [destination, setDestination] = useState('');
  const [fare, setFare] = useState('100');

  async function book(){
    try{
      const res = await api.post('/rides/', { user_id: userId, source, destination, fare });
      alert('Ride requested: ' + res.data.ride_id);
    }catch(e){
      alert('Error: ' + (e.response?.data?.detail || e.message));
    }
  }

  return (
    <div>
      <h2>Book Ride</h2>
      <label>User ID: <input value={userId} onChange={e=>setUserId(Number(e.target.value))} /></label>
      <br/>
      <label>From: <input value={source} onChange={e=>setSource(e.target.value)} /></label>
      <br/>
      <label>To: <input value={destination} onChange={e=>setDestination(e.target.value)} /></label>
      <br/>
      <label>Fare: <input value={fare} onChange={e=>setFare(e.target.value)} /></label>
      <br/>
      <button className="button" onClick={book}>Request Ride</button>
    </div>
  );
}
