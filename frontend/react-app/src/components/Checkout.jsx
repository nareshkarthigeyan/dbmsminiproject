import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api';

export default function Checkout(){
  const navigate = useNavigate();
  const stored = JSON.parse(localStorage.getItem('cart') || '{}');
  const [userId, setUserId] = useState(1);
  const [loading, setLoading] = useState(false);

  const items = stored.items || [];
  const restaurant_id = stored.restaurant_id;
  const total = items.reduce((s,i) => s + i.quantity * i.unit_price, 0);

  async function placeOrder(){
    setLoading(true);
    try{
      const payload = { user_id: userId, restaurant_id, items: items.map(i=> ({item_id: i.item_id, quantity: i.quantity, unit_price: i.unit_price})), mode: 'card' };
      const res = await api.post('/orders/', payload);
      alert('Order placed: ' + res.data.order_id);
      localStorage.removeItem('cart');
      navigate('/');
    }catch(e){
      alert('Error: ' + (e.response?.data?.detail || e.message));
    }finally{setLoading(false)}
  }

  return (
    <div>
      <h2>Checkout</h2>
      <p>Restaurant: {restaurant_id}</p>
      <p>Total: ₹{total}</p>
      <label>User ID: <input value={userId} onChange={e=>setUserId(Number(e.target.value))} /></label>
      <div>
        <button className="button" onClick={placeOrder} disabled={loading}>{loading ? 'Placing...' : 'Place Order'}</button>
      </div>
    </div>
  );
}
