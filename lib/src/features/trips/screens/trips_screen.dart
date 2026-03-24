import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_models.dart';
import '../providers/trip_provider.dart';
import 'trip_detail_screen.dart';

/// Screen listing all delivery trips with Active/Completed tabs.
class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initial load
    ref.read(tripProvider.notifier).loadTrips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<DeliveryTrip> _active(List<DeliveryTrip> all) =>
      all.where((t) => t.isCreated || t.isOutForDelivery).toList();

  List<DeliveryTrip> _completed(List<DeliveryTrip> all) =>
      all.where((t) => t.isCompleted).toList();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Trips'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(tripProvider.notifier).loadTrips(),
          ),
        ],
      ),
      body: state.isLoading && state.trips.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.trips.isEmpty
              ? Center(child: Text('Error: ${state.error}'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTripList(_active(state.trips)),
                    _buildTripList(_completed(state.trips)),
                  ],
                ),
    );
  }

  Widget _buildTripList(List<DeliveryTrip> trips) {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('No trips', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(tripProvider.notifier).loadTrips(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: trips.length,
        itemBuilder: (context, index) => _buildTripCard(trips[index]),
      ),
    );
  }

  Widget _buildTripCard(DeliveryTrip trip) {
    final statusColor = switch (trip.status) {
      'Created' => Colors.blue,
      'Out for Delivery' => Colors.orange,
      'Completed' => Colors.green,
      _ => Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => TripDetailScreen(tripName: trip.name),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_shipping, size: 18, color: statusColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trip.name,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trip.status,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(trip.courierDisplayName, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  Text(trip.tripDate, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('${trip.totalOrders} orders', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const Spacer(),
                  if (trip.isDoubleShipping) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.amber[700]!),
                      ),
                      child: Text('2×', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber[800])),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '\$${trip.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
