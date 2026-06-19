import 'package:flutter/material.dart';
import 'package:rahiq_driver/data/api/api_client.dart';
import 'package:rahiq_driver/data/api/driver/driver_orders_api.dart';
import 'package:rahiq_driver/data/models/driver/driver_order.dart';
import 'package:rahiq_driver/ui/shared/proof_submission_page.dart';
import 'package:rahiq_driver/utils/colors.dart';

class OrderDetailsPage extends StatefulWidget {
  final DriverOrder order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late DriverOrdersApi _api;
  bool _isLoading = true;
  String? _error;
  List<String> _subOrders = [];

  @override
  void initState() {
    super.initState();
    _api = DriverOrdersApi(ApiClient());
    _fetchSubOrders();
  }

  Future<void> _fetchSubOrders() async {
    try {
      final response = await _api.getNormalOrderSubOrders(widget.order.id);
      setState(() {
        _subOrders = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.order.id.split('-').first.toUpperCase()}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.red.withOpacity(0.1),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  _buildInfoCard(context),
                  const SizedBox(height: 16),
                  if (_subOrders.isNotEmpty) _buildSubOrdersSection(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProofSubmissionPage(
                              isAutoOrder: false,
                              orderId: widget.order.id,
                              subOrders: _subOrders,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Submit Delivery Proof'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.buttonBlue),
            ),
            const Divider(),
            _buildDetailRow(Icons.person, 'Name', widget.order.customerName ?? 'N/A'),
            _buildDetailRow(Icons.phone, 'Phone', widget.order.customerPhone ?? 'N/A'),
            _buildDetailRow(Icons.location_on, 'Address', widget.order.deliveryAddress ?? 'N/A'),
            const SizedBox(height: 16),
            const Text(
              'Order Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.buttonBlue),
            ),
            const Divider(),
            _buildDetailRow(Icons.info, 'Status', widget.order.status ?? 'N/A'),
            _buildDetailRow(Icons.payment, 'Payment', widget.order.paymentMethod ?? 'N/A'),
            if (widget.order.totalAmount != null)
              _buildDetailRow(Icons.monetization_on, 'Total', '\$${widget.order.totalAmount}'),
          ],
        ),
      ),
    );
  }

  Widget _buildSubOrdersSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sub Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.buttonBlue),
            ),
            const Divider(),
            ..._subOrders.map((subId) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(subId, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
