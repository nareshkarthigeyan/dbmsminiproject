from django.urls import path
from . import views

urlpatterns = [
    path('restaurants/', views.list_restaurants, name='list_restaurants'),
    path('restaurants/<int:restaurant_id>/menu/', views.get_menu, name='get_menu'),
    path('orders/', views.place_order, name='place_order'),
    path('orders/<int:order_id>/', views.get_order, name='get_order'),
    path('rides/', views.request_ride, name='request_ride'),
]
