import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import api from '../api';

export default function Menu(){
  const { id } = useParams();
  const navigate = useNavigate();
  const [items, setItems] = useState([]);
  const [cart, setCart] = useState([]);

  useEffect(() => {
    api.get(`/restaurants/${id}/menu/`).then(res => setItems(res.data)).catch(console.error);
  }, [id]);

  function addToCart(item){
    setCart(prev => {
      const existing = prev.find(p => p.item_id === item.item_id);
      if(existing){
        return prev.map(p => p.item_id === item.item_id ? {...p, quantity: p.quantity + 1} : p);
      }
      return [...prev, {...item, quantity: 1, unit_price: item.price}];
    });
  }

  function goCheckout(){
    localStorage.setItem('cart', JSON.stringify({restaurant_id: parseInt(id), items: cart}));
    navigate('/checkout');
  }

  return (
    <div>
      <h2>Menu</h2>
      {items.map(it => (
        <div key={it.item_id} className="card">
          <h4>{it.name} — ₹{it.price}</h4>
          <p>{it.description}</p>
          <button className="button" onClick={() => addToCart(it)}>Add</button>
        </div>
      ))}
      {cart.length > 0 && (
        <div className="card">
          <h3>Cart</h3>
          {cart.map(c => (<div key={c.item_id}>{c.name} x {c.quantity}</div>))}
          <button className="button" onClick={goCheckout}>Checkout</button>
        </div>
      )}
    </div>
  );
}
