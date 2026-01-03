import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptPage extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String userEmail;

  const ReceiptPage({
    super.key,
    required this.booking,
    required this.userEmail,
  });

  String _safeStr(dynamic v, [String fallback = "-"]) {
    if (v == null) return fallback;
    final s = v.toString();
    return s.isEmpty ? fallback : s;
  }

  int _safeInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString()) ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final bookingId = _safeStr(booking['id']);
    final packageType = _safeStr(booking['package_type']);
    final status = _safeStr(booking['status']);
    final paymentStatus = _safeStr(booking['payment_status']);
    final startDate = _safeStr(booking['start_date']);
    final startTime = _safeStr(booking['start_time']);
    final endDate = _safeStr(booking['end_date']);
    final endTime = _safeStr(booking['end_time']);
    final phone = _safeStr(booking['phone']);
    final amountMYR = _safeInt(booking['price'], 0);

    final createdAtRaw = booking['created_at'];
    DateTime? createdAt;
    if (createdAtRaw != null) {
      createdAt = DateTime.tryParse(createdAtRaw.toString());
    }
    final createdAtStr = createdAt == null
        ? '-'
        : DateFormat.yMMMMd().format(createdAt.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #$bookingId'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= RECEIPT CARD =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EbuCare',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Confinement Booking Receipt',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  _row('Invoice Date', createdAtStr),
                  _row('Invoice To', userEmail),
                  _row('Contact No', phone),
                  const Divider(height: 24),
                  _row('Booking ID', bookingId),
                  _row('Package', packageType),
                  _row('Booking Status', status),
                  _row('Payment Status', paymentStatus),
                  _row(
                    'Booked On',
                    '$startDate $startTime  -  $endDate $endTime',
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'RM $amountMYR',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= DUMMY DOWNLOAD BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.download_outlined),
                label: const Text(
                  'Download Receipt',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Download feature will be available soon.',
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              'Note: This receipt is for reference only.',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              left,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(right)),
        ],
      ),
    );
  }
}
