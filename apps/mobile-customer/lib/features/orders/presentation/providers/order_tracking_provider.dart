import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_customer/features/orders/data/order_repository.dart';
import 'package:mobile_customer/features/orders/domain/entities/order.dart';

/// Polls `GET /orders/:id` every 10 seconds while the order is active.
///
/// Usage:
/// ```dart
/// final asyncOrder = ref.watch(trackingProvider('your-order-id'));
/// ```
///
/// Polling stops automatically when the order reaches a terminal state
/// (`delivered` or `cancelled`). The provider auto-disposes when the
/// widget is removed from the tree, which also cancels any pending timer.
final trackingProvider = AutoDisposeAsyncNotifierProviderFamily<
    OrderTrackingNotifier, Order, String>(OrderTrackingNotifier.new);

class OrderTrackingNotifier extends AutoDisposeFamilyAsyncNotifier<Order, String> {
  static const _pollInterval = Duration(seconds: 10);

  Timer? _timer;
  // Tracks disposal to avoid mutating state after the notifier is gone.
  bool _disposed = false;

  @override
  Future<Order> build(String orderId) async {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    return _fetch(orderId);
  }

  Future<Order> _fetch(String orderId) async {
    final repo = ref.read(orderRepositoryProvider);
    final order = await repo.fetchOrder(orderId);
    _scheduleNext(order);
    return order;
  }

  void _scheduleNext(Order order) {
    _timer?.cancel();

    final isTerminal = order.status == OrderStatus.delivered ||
        order.status == OrderStatus.cancelled;
    if (isTerminal) return;

    _timer = Timer(_pollInterval, () async {
      if (_disposed) return;
      try {
        final updated = await ref.read(orderRepositoryProvider).fetchOrder(arg);
        if (_disposed) return;
        state = AsyncData(updated);
        _scheduleNext(updated);
      } catch (e, st) {
        if (_disposed) return;
        // Preserve previous value so the UI doesn't blank out on a transient error.
        final previous = state.valueOrNull;
        state = AsyncError(e, st);
        // Keep retrying after the interval even on error.
        if (previous != null) _scheduleNext(previous);
      }
    });
  }

  /// Force an immediate refresh — e.g. triggered by pull-to-refresh.
  Future<void> refresh() async {
    if (_disposed) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }
}
