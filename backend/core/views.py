from django.db import connection, transaction
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

@api_view(['GET'])
def list_restaurants(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT restaurant_id, name, location, cuisine, rating FROM restaurants ORDER BY name")
        rows = cursor.fetchall()
    data = [
        {"restaurant_id": r[0], "name": r[1], "location": r[2], "cuisine": r[3], "rating": float(r[4]) if r[4] is not None else None}
        for r in rows
    ]
    return Response(data)

@api_view(['GET'])
def get_menu(request, restaurant_id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT item_id, name, description, price, available, stock FROM menu_items WHERE restaurant_id = %s", [restaurant_id])
        rows = cursor.fetchall()
    data = [
        {"item_id": r[0], "name": r[1], "description": r[2], "price": float(r[3]), "available": r[4], "stock": r[5]}
        for r in rows
    ]
    return Response(data)

@api_view(['POST'])
def place_order(request):
    payload = request.data
    user_id = payload.get('user_id')
    restaurant_id = payload.get('restaurant_id')
    items = payload.get('items', [])  # list of {item_id, quantity, unit_price}
    mode = payload.get('mode', 'card')

    if not user_id or not restaurant_id or not items:
        return Response({'detail': 'Missing fields'}, status=status.HTTP_400_BAD_REQUEST)

    total = sum(int(i['quantity']) * float(i['unit_price']) for i in items)

    try:
        with transaction.atomic():
            with connection.cursor() as cursor:
                cursor.execute(
                    "INSERT INTO orders (user_id, restaurant_id, total_amount, status) VALUES (%s,%s,%s,%s) RETURNING order_id",
                    [user_id, restaurant_id, total, 'placed']
                )
                order_id = cursor.fetchone()[0]
                for it in items:
                    cursor.execute("INSERT INTO order_items (order_id, item_id, quantity, unit_price) VALUES (%s,%s,%s,%s)",
                                   [order_id, it['item_id'], it['quantity'], it['unit_price']])
                cursor.execute("INSERT INTO payments (user_id, order_id, amount, mode, status) VALUES (%s,%s,%s,%s,%s)",
                               [user_id, order_id, total, mode, 'pending'])
        return Response({'order_id': order_id}, status=status.HTTP_201_CREATED)
    except Exception as e:
        return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def get_order(request, order_id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT order_id, user_id, restaurant_id, total_amount, status, placed_at, delivered_at FROM orders WHERE order_id = %s", [order_id])
        row = cursor.fetchone()
    if not row:
        return Response({'detail': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
    data = {
        'order_id': row[0], 'user_id': row[1], 'restaurant_id': row[2], 'total_amount': float(row[3]),
        'status': row[4], 'placed_at': row[5], 'delivered_at': row[6]
    }
    return Response(data)

@api_view(['POST'])
def request_ride(request):
    payload = request.data
    user_id = payload.get('user_id')
    source = payload.get('source')
    destination = payload.get('destination')
    fare = payload.get('fare', 0)

    if not user_id or not source or not destination:
        return Response({'detail': 'Missing fields'}, status=status.HTTP_400_BAD_REQUEST)

    with connection.cursor() as cursor:
        cursor.execute("INSERT INTO rides (user_id, source, destination, fare, status) VALUES (%s,%s,%s,%s,%s) RETURNING ride_id",
                       [user_id, source, destination, fare, 'requested'])
        ride_id = cursor.fetchone()[0]
    return Response({'ride_id': ride_id}, status=status.HTTP_201_CREATED)
