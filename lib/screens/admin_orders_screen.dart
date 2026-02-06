import 'package:flutter/material.dart';
import '../providers/order_provider.dart' show OrderProvider, DummyOrders;
import '../providers/auth_provider.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import 'package:provider/provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  OrderStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.loadAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Admin - Order Tracking',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          PopupMenuButton<OrderStatus?>(
            icon: Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() => _filterStatus = status);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Orders'),
              ),
              const PopupMenuItem(
                value: OrderStatus.pending,
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: OrderStatus.confirmed,
                child: Text('Confirmed'),
              ),
              const PopupMenuItem(
                value: OrderStatus.inProgress,
                child: Text('In Progress'),
              ),
              const PopupMenuItem(
                value: OrderStatus.completed,
                child: Text('Completed'),
              ),
              const PopupMenuItem(
                value: OrderStatus.cancelled,
                child: Text('Cancelled'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer2<AuthProvider, OrderProvider>(
        builder: (context, authProvider, orderProvider, _) {
          if (!authProvider.isAdmin) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Access Denied',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Admin access required',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredOrders = _filterStatus == null
              ? orderProvider.orders
              : orderProvider.orders.where((o) => o.status == _filterStatus).toList();

          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _filterStatus == null
                        ? 'No orders have been placed yet'
                        : 'No ${_filterStatus!.name} orders',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats summary
              _buildStatsSummary(context, orderProvider.orders),
              // Orders list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    try {
                      final user = DummyOrders.getUserForOrder(order.userId);
                      return _buildAdminOrderCard(context, order, user);
                    } catch (e) {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (!authProvider.isAdmin) {
            return const SizedBox.shrink();
          }
          return AppBottomNavigationBar(
            currentIndex: 4,
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              } else if (index == 1) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              } else if (index == 2) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                  (route) => false,
                );
              } else if (index == 3) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  (route) => false,
                );
              } else if (index == 4) {
                // Already on admin
                return;
              } else if (index == 5) {
                // Messages
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MessagesScreen()),
                  (route) => false,
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context, List<Order> orders) {
    final pending = orders.where((o) => o.status == OrderStatus.pending).length;
    final inProgress = orders.where((o) => o.status == OrderStatus.inProgress).length;
    final completed = orders.where((o) => o.status == OrderStatus.completed).length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, 'Pending', pending, Colors.orange),
          _buildStatItem(context, 'In Progress', inProgress, Theme.of(context).colorScheme.primary),
          _buildStatItem(context, 'Completed', completed, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildAdminOrderCard(BuildContext context, Order order, User user) {
    final statusColor = _getStatusColor(context, order.status);
    final typeIcon = order.type == OrderType.cleaning
        ? Icons.cleaning_services
        : Icons.local_laundry_service;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Builder(
        builder: (context) {
          final pickupLocation = order.details['pickupLocation'];
          final dropoffLocation = order.details['dropoffLocation'];
          final location = order.details['location'];
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with order info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          typeIcon,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.typeLabel,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Order #${order.id.substring(order.id.length - 6)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),
              // Customer Information
              _buildInfoRow(context, Icons.person, 'Customer', user.name),
              const SizedBox(height: 8),
              _buildInfoRow(context, Icons.email, 'Email', user.email),
              const SizedBox(height: 8),
              _buildInfoRow(context, Icons.phone, 'Phone', user.phone),
              const SizedBox(height: 12),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),
              // Location Information
              if (pickupLocation != null) ...[
                _buildInfoRow(
                  context,
                  Icons.location_on,
                  'Pickup Location',
                  pickupLocation.toString(),
                ),
                const SizedBox(height: 8),
              ],
              if (dropoffLocation != null)
                _buildInfoRow(
                  context,
                  Icons.location_on,
                  'Drop-off Location',
                  dropoffLocation.toString(),
                ),
              if (location != null && pickupLocation == null) ...[
                if (dropoffLocation != null) const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  Icons.location_on,
                  'Location',
                  location.toString(),
                ),
              ],
              const SizedBox(height: 12),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),
              // Order Details
              ..._buildOrderDetails(context, order),
              if (order.amount != null) ...[
                const SizedBox(height: 12),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'KSh ${order.amount!.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              // Timestamps
              _buildInfoRow(
                context,
                Icons.access_time,
                'Created',
                _formatTimestamp(order.createdAt),
              ),
              if (order.scheduledAt != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  Icons.schedule,
                  'Scheduled',
                  _formatTimestamp(order.scheduledAt!),
                ),
              ],
              if (order.completedAt != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  Icons.check_circle,
                  'Completed',
                  _formatTimestamp(order.completedAt!),
                ),
              ],
              const SizedBox(height: 16),
              // Status update buttons
              if (order.status != OrderStatus.completed && order.status != OrderStatus.cancelled)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateOrderStatus(context, order.id, OrderStatus.confirmed),
                        child: const Text('Confirm'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateOrderStatus(context, order.id, OrderStatus.inProgress),
                        child: const Text('Start'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateOrderStatus(context, order.id, OrderStatus.completed),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text('Complete'),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildOrderDetails(BuildContext context, Order order) {
    final details = <Widget>[];

    if (order.type == OrderType.cleaning) {
      final service = order.details['service'];
      if (service != null) {
        details.add(_buildInfoRow(
          context,
          Icons.cleaning_services,
          'Service',
          service.toString(),
        ));
        details.add(const SizedBox(height: 8));
      }
      final rooms = order.details['rooms'];
      if (rooms != null) {
        details.add(_buildInfoRow(
          context,
          Icons.home,
          'Rooms',
          rooms.toString(),
        ));
        details.add(const SizedBox(height: 8));
      }
      final frequency = order.details['frequency'];
      if (frequency != null) {
        details.add(_buildInfoRow(
          context,
          Icons.repeat,
          'Frequency',
          frequency.toString(),
        ));
      }
    } else if (order.type == OrderType.laundry) {
      final pickupStation = order.details['pickupStation'];
      if (pickupStation != null && pickupStation.toString().trim().isNotEmpty) {
        details.add(_buildInfoRow(
          context,
          Icons.store,
          'Pickup Station',
          pickupStation.toString(),
        ));
        details.add(const SizedBox(height: 8));
      }

      final itemCount = order.details['itemCount'];
      final basketCount = order.details['basketCount'];
      final weightKg = order.details['weightKg'];
      if (itemCount != null || basketCount != null || weightKg != null) {
        final parts = <String>[];
        if (itemCount != null) parts.add('$itemCount items');
        if (basketCount != null) parts.add('$basketCount basket${basketCount == 1 ? '' : 's'}');
        if (weightKg != null) parts.add('~${weightKg.toString()} kg');
        details.add(_buildInfoRow(
          context,
          Icons.inventory,
          'Load',
          parts.join(' • '),
        ));
        details.add(const SizedBox(height: 8));
      }

      final turnaroundDays = order.details['turnaroundDays'];
      final readyBy = order.details['readyBy'];
      if (turnaroundDays != null) {
        details.add(_buildInfoRow(
          context,
          Icons.schedule,
          'Turnaround',
          '$turnaroundDays day${turnaroundDays == 1 ? '' : 's'}',
        ));
        details.add(const SizedBox(height: 8));
      }
      if (readyBy != null) {
        DateTime? readyDt;
        try {
          readyDt = DateTime.parse(readyBy.toString());
        } catch (_) {
          readyDt = null;
        }
        details.add(_buildInfoRow(
          context,
          Icons.event_available,
          'Ready By',
          readyDt != null ? _formatTimestamp(readyDt) : readyBy.toString(),
        ));
        details.add(const SizedBox(height: 8));
      }

      final method = order.details['method'];
      if (method != null) {
        details.add(_buildInfoRow(
          context,
          Icons.delivery_dining,
          'Method',
          method.toString(),
        ));
        details.add(const SizedBox(height: 8));
      }
      final serviceType = order.details['serviceType'];
      if (serviceType != null) {
        details.add(_buildInfoRow(
          context,
          Icons.local_laundry_service,
          'Service Type',
          serviceType.toString(),
        ));
        details.add(const SizedBox(height: 8));
      }
      final items = order.details['items'];
      if (items != null && items is List) {
        details.add(_buildInfoRow(
          context,
          Icons.list,
          'Items',
          items.map((e) => e.toString()).join(', '),
        ));
      }
    }

    return details;
  }

  Color _getStatusColor(BuildContext context, OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.inProgress:
        return Theme.of(context).colorScheme.primary;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateOrderStatus(BuildContext context, String orderId, OrderStatus status) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.updateOrderStatus(orderId, status);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to ${status.name}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
