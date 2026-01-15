import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/membership_model.dart';

// Dummy users database - replace with API later
class DummyUsers {
  static final List<User> users = [
    // Premium user - All services
    User(
      id: 'user_premium_all',
      name: 'Meshack',
      email: 'meshack@example.com',
      phone: '+254712345678',
      membership: Membership(
        type: MembershipType.premium,
        subscriptions: [
          Subscription(
            id: 'sub_1',
            service: ServiceType.all,
            duration: SubscriptionDuration.monthly,
            startDate: DateTime.now().subtract(const Duration(days: 10)),
            endDate: DateTime.now().add(const Duration(days: 20)),
            isActive: true,
          ),
        ],
        expiresAt: DateTime.now().add(const Duration(days: 20)),
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    // Premium user - Saka Keja only
    User(
      id: 'user_premium_saka',
      name: 'Premium Saka User',
      email: 'premiumsaka@example.com',
      phone: '+254712345679',
      membership: Membership(
        type: MembershipType.premium,
        subscriptions: [
          Subscription(
            id: 'sub_2',
            service: ServiceType.sakaKeja,
            duration: SubscriptionDuration.annual,
            startDate: DateTime.now().subtract(const Duration(days: 60)),
            endDate: DateTime.now().add(const Duration(days: 305)),
            isActive: true,
          ),
        ],
        expiresAt: DateTime.now().add(const Duration(days: 305)),
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    // Premium user - Fresh Keja only (weekly)
    User(
      id: 'user_premium_fresh',
      name: 'Premium Fresh User',
      email: 'premiumfresh@example.com',
      phone: '+254712345680',
      membership: Membership(
        type: MembershipType.premium,
        subscriptions: [
          Subscription(
            id: 'sub_3',
            service: ServiceType.freshKeja,
            duration: SubscriptionDuration.weekly,
            startDate: DateTime.now().subtract(const Duration(days: 2)),
            endDate: DateTime.now().add(const Duration(days: 5)),
            isActive: true,
          ),
        ],
        expiresAt: DateTime.now().add(const Duration(days: 5)),
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    // Freemium user
    User(
      id: 'user_freemium',
      name: 'Freemium User',
      email: 'freemium@example.com',
      phone: '+254712345681',
      membership: Membership(
        type: MembershipType.freemium,
        subscriptions: [],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    // Admin user
    User(
      id: 'user_admin',
      name: 'Admin',
      email: 'admin@juax.com',
      phone: '+254712345682',
      membership: Membership(
        type: MembershipType.premium,
        subscriptions: [
          Subscription(
            id: 'sub_admin',
            service: ServiceType.all,
            duration: SubscriptionDuration.annual,
            startDate: DateTime.now().subtract(const Duration(days: 365)),
            endDate: DateTime.now().add(const Duration(days: 365)),
            isActive: true,
          ),
        ],
        expiresAt: DateTime.now().add(const Duration(days: 365)),
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      isAdmin: true,
    ),
    // Agent user (manages Apartments & BnBs inventory)
    User(
      id: 'user_agent',
      name: 'Agent Kenya',
      email: 'agent@juax.com',
      phone: '+254700000001',
      membership: Membership(
        type: MembershipType.premium,
        subscriptions: [
          Subscription(
            id: 'sub_agent',
            service: ServiceType.all,
            duration: SubscriptionDuration.annual,
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            endDate: DateTime.now().add(const Duration(days: 335)),
            isActive: true,
          ),
        ],
        expiresAt: DateTime.now().add(const Duration(days: 335)),
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      isAgent: true,
    ),
  ];
}

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isAgent => _currentUser?.isAgent ?? false;

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Find user by email (dummy authentication)
      final user = DummyUsers.users.firstWhere(
        (u) => u.email == email,
        orElse: () => throw Exception('User not found'),
      );

      // In real app, verify password here
      // For now, any password works for demo

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign up new user
  Future<bool> signUp(String name, String email, String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Check if email already exists
      final exists = DummyUsers.users.any((u) => u.email == email);
      if (exists) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new freemium user
      final newUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        membership: Membership(
          type: MembershipType.freemium,
          subscriptions: [],
        ),
        createdAt: DateTime.now(),
      );

      // Add to dummy database
      DummyUsers.users.add(newUser);

      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
