import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api from '../api';

export default function RestaurantList() {
  const [list, setList] = useState([]);
  useEffect(() => {
    api.get('/restaurants/').then(res => setList(res.data)).catch(console.error);
  }, []);

  return (
    <div>
      <h2>Restaurants</h2>
      {list.map(r => (
        <div key={r.restaurant_id} className="card">
          <h3>{r.name}</h3>
          <p>{r.location} · {r.cuisine}</p>
          <Link to={`/restaurants/${r.restaurant_id}`} className="button">View Menu</Link>
        </div>
      ))}
    </div>
  );
}
