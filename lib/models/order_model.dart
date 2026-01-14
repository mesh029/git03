// Database-ready Order model
enum OrderType {
  cleaning,
  laundry,
}

enum OrderStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

class Order {
  final String id;
  final String userId;
  final OrderType type;
  final OrderStatus status;
  final Map<String, dynamic> details; // Service-specific details
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final double? amount;

  Order({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.details,
    required this.createdAt,
    this.scheduledAt,
    this.completedAt,
    this.amount,
  });

  String get typeLabel {
    switch (type) {
      case OrderType.cleaning:
        return 'House Cleaning';
      case OrderType.laundry:
        return 'Laundry Service';
    }
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'status': status.name,
      'details': details,
      'createdAt': createdAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'amount': amount,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: OrderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OrderType.cleaning,
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      details: json['details'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      amount: json['amount'] as double?,
    );
  }
}
