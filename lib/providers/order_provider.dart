import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

// Dummy orders database - replace with API later
class DummyOrders {
  static List<Order> getOrdersForUser(String userId) {
    return allOrders.where((order) => order.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<Order> getAllOrders() {
    return List.from(allOrders)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static User getUserForOrder(String userId) {
    try {
      return DummyUsers.users.firstWhere(
        (user) => user.id == userId,
      );
    } catch (e) {
      // Fallback to first user if not found
      return DummyUsers.users.isNotEmpty 
          ? DummyUsers.users.first 
          : throw Exception('No users found');
    }
  }

  static final List<Order> allOrders = [
    // Orders for premium user (meshack)
    Order(
      id: 'order_1',
      userId: 'user_premium_all',
      type: OrderType.cleaning,
      status: OrderStatus.completed,
      details: {
        'service': 'Deep Cleaning',
        'location': 'Milimani, Kisumu',
        'pickupLocation': 'Milimani, Kisumu',
        'dropoffLocation': 'Milimani, Kisumu',
        'rooms': 3,
        'frequency': 'One-time',
        'customerName': 'Meshack',
        'customerEmail': 'meshack@example.com',
        'customerPhone': '+254712345678',
      },
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      scheduledAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
      amount: 2500.0,
    ),
    Order(
      id: 'order_2',
      userId: 'user_premium_all',
      type: OrderType.laundry,
      status: OrderStatus.inProgress,
      details: {
        'quantity': 5,
        'method': 'Pickup',
        'location': 'Town Center, Kisumu',
        'pickupLocation': 'Town Center, Kisumu',
        'dropoffLocation': 'Town Center, Kisumu',
        'items': ['Shirts', 'Pants', 'Bedding'],
        'serviceType': 'Wash & Fold',
        'customerName': 'Meshack',
        'customerEmail': 'meshack@example.com',
        'customerPhone': '+254712345678',
      },
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      scheduledAt: DateTime.now().subtract(const Duration(hours: 4)),
      amount: 800.0,
    ),
    Order(
      id: 'order_3',
      userId: 'user_premium_all',
      type: OrderType.cleaning,
      status: OrderStatus.confirmed,
      details: {
        'service': 'Regular Cleaning',
        'location': 'Milimani, Kisumu',
        'pickupLocation': 'Milimani, Kisumu',
        'dropoffLocation': 'Milimani, Kisumu',
        'rooms': 2,
        'frequency': 'Weekly',
        'customerName': 'Meshack',
        'customerEmail': 'meshack@example.com',
        'customerPhone': '+254712345678',
      },
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      scheduledAt: DateTime.now().add(const Duration(days: 1)),
      amount: 1500.0,
    ),
    // Orders for freemium user
    Order(
      id: 'order_4',
      userId: 'user_freemium',
      type: OrderType.laundry,
      status: OrderStatus.completed,
      details: {
        'quantity': 3,
        'method': 'Drop-off',
        'location': 'Nyalenda, Kisumu',
        'pickupLocation': 'Nyalenda, Kisumu',
        'dropoffLocation': 'Nyalenda, Kisumu',
        'items': ['Shirts', 'Pants'],
        'serviceType': 'Wash & Fold',
        'customerName': 'Freemium User',
        'customerEmail': 'freemium@example.com',
        'customerPhone': '+254712345681',
      },
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      scheduledAt: DateTime.now().subtract(const Duration(days: 5)),
      completedAt: DateTime.now().subtract(const Duration(days: 4)),
      amount: 500.0,
    ),
    Order(
      id: 'order_5',
      userId: 'user_freemium',
      type: OrderType.cleaning,
      status: OrderStatus.pending,
      details: {
        'service': 'Basic Cleaning',
        'location': 'Nyalenda, Kisumu',
        'pickupLocation': 'Nyalenda, Kisumu',
        'dropoffLocation': 'Nyalenda, Kisumu',
        'rooms': 1,
        'frequency': 'One-time',
        'customerName': 'Freemium User',
        'customerEmail': 'freemium@example.com',
        'customerPhone': '+254712345681',
      },
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      scheduledAt: DateTime.now().add(const Duration(days: 2)),
      amount: 1000.0,
    ),
  ];
}

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _currentUserId;
  bool _isAdminView = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  // Load all orders for admin
  Future<void> loadAllOrders() async {
    _isAdminView = true;
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    _orders = DummyOrders.getAllOrders();
    _isLoading = false;
    notifyListeners();
  }

  // Load orders for a user
  Future<void> loadOrders(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    _orders = DummyOrders.getOrdersForUser(userId);
    _isLoading = false;
    notifyListeners();
  }

  // Add new order
  Future<void> addOrder(Order order) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Add to dummy database
    DummyOrders.allOrders.add(order);
    
    // Reload orders if for current user
    if (_currentUserId == order.userId) {
      _orders = DummyOrders.getOrdersForUser(order.userId);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 300));

    final orderIndex = DummyOrders.allOrders.indexWhere((o) => o.id == orderId);
    if (orderIndex != -1) {
      final order = DummyOrders.allOrders[orderIndex];
      final updatedOrder = Order(
        id: order.id,
        userId: order.userId,
        type: order.type,
        status: status,
        details: order.details,
        createdAt: order.createdAt,
        scheduledAt: order.scheduledAt,
        completedAt: status == OrderStatus.completed ? DateTime.now() : order.completedAt,
        amount: order.amount,
      );
      DummyOrders.allOrders[orderIndex] = updatedOrder;
      
      // Reload orders if for current user
      if (_currentUserId != null) {
        _orders = DummyOrders.getOrdersForUser(_currentUserId!);
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}
