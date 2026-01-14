// Database-ready Membership model
enum MembershipType {
  freemium,
  premium,
}

enum ServiceType {
  sakaKeja,
  freshKeja,
  all,
}

enum SubscriptionDuration {
  daily,
  weekly,
  monthly,
  annual,
}

class Membership {
  final MembershipType type;
  final List<Subscription> subscriptions;
  final DateTime? expiresAt;

  Membership({
    required this.type,
    required this.subscriptions,
    this.expiresAt,
  });

  bool get isPremium => type == MembershipType.premium;
  bool get isFreemium => type == MembershipType.freemium;

  // Check if user has premium access to a specific service
  bool hasPremiumAccess(ServiceType service) {
    if (!isPremium) return false;
    if (expiresAt != null && expiresAt!.isBefore(DateTime.now())) return false;
    
    return subscriptions.any((sub) {
      if (sub.service == ServiceType.all) return true;
      return sub.service == service && sub.isActive;
    });
  }

  // Get active subscription for a service
  Subscription? getActiveSubscription(ServiceType service) {
    return subscriptions.firstWhere(
      (sub) => (sub.service == service || sub.service == ServiceType.all) && sub.isActive,
      orElse: () => subscriptions.firstWhere(
        (sub) => sub.service == ServiceType.all && sub.isActive,
        orElse: () => subscriptions.first,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      type: MembershipType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MembershipType.freemium,
      ),
      subscriptions: (json['subscriptions'] as List)
          .map((s) => Subscription.fromJson(s as Map<String, dynamic>))
          .toList(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }
}

class Subscription {
  final String id;
  final ServiceType service;
  final SubscriptionDuration duration;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Subscription({
    required this.id,
    required this.service,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  String get durationLabel {
    switch (duration) {
      case SubscriptionDuration.daily:
        return 'Daily';
      case SubscriptionDuration.weekly:
        return 'Weekly';
      case SubscriptionDuration.monthly:
        return 'Monthly';
      case SubscriptionDuration.annual:
        return 'Annual';
    }
  }

  String get serviceLabel {
    switch (service) {
      case ServiceType.sakaKeja:
        return 'Saka Keja';
      case ServiceType.freshKeja:
        return 'Fresh Keja';
      case ServiceType.all:
        return 'All Services';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service.name,
      'duration': duration.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      service: ServiceType.values.firstWhere(
        (e) => e.name == json['service'],
        orElse: () => ServiceType.sakaKeja,
      ),
      duration: SubscriptionDuration.values.firstWhere(
        (e) => e.name == json['duration'],
        orElse: () => SubscriptionDuration.monthly,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
    );
  }
}
