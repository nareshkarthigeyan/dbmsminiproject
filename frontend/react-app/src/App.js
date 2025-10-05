import React from 'react';
import { Routes, Route, Link } from 'react-router-dom';
import RestaurantList from './components/RestaurantList';
import Menu from './components/Menu';
import Checkout from './components/Checkout';
import BookRide from './components/BookRide';

function App() {
  return (
    <div className="app">
      <div className="header">
        <div className="container">
          <h1>MultiService Demo</h1>
          <nav>
            <Link to="/">Restaurants</Link> | <Link to="/book-ride">Book Ride</Link>
          </nav>
        </div>
      </div>
      <div className="container">
        <Routes>
          <Route path="/" element={<RestaurantList />} />
          <Route path="/restaurants/:id" element={<Menu />} />
          <Route path="/checkout" element={<Checkout />} />
          <Route path="/book-ride" element={<BookRide />} />
        </Routes>
      </div>
    </div>
  );
}

export default App;
