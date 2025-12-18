import 'package:ebucare_app/pages/confinement_feedback_page.dart';
import 'package:ebucare_app/pages/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewBookingsPage extends StatefulWidget {
  const ViewBookingsPage({super.key});

  @override
  State<ViewBookingsPage> createState() => _ViewBookingsPageState();
}

class _ViewBookingsPageState extends State<ViewBookingsPage> {
  final String userId = Supabase.instance.client.auth.currentUser?.id ?? '';

  Future<List<dynamic>> fetchBookings() async {
    final data = await Supabase.instance.client
        .from('confinement_bookings')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return data;
  }

  bool _isPaid(dynamic booking) {
    final s = (booking['payment_status'] ?? '').toString().toLowerCase();
    return s == 'paid';
  }

  bool _isUnpaid(dynamic booking) {
    final status = (booking['payment_status'] ?? '').toString().toLowerCase();
    return status == 'unpaid';
  }

  bool _isCancelled(dynamic booking) {
    final s = (booking['status'] ?? '').toString().toLowerCase();
    return s == 'cancelled';
  }

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

  DateTime? _parseDateTime(String dateStr, String timeStr,
      {bool endOfDayFallback = false}) {
    try {
      final d = dateStr.trim();
      var t = timeStr.trim();

      if (d.isEmpty) return null;

      if (t.isEmpty) {
        t = endOfDayFallback ? "23:59:59" : "00:00:00";
      } else {
        // normalize: HH:mm -> HH:mm:00
        if (RegExp(r'^\d{2}:\d{2}$').hasMatch(t)) t = "$t:00";
      }

      return DateTime.parse("${d}T$t");
    } catch (_) {
      return null;
    }
  }

  bool _bookingEnded(dynamic b) {
    final endDate = _safeStr(b['end_date'], "");
    final endTime = _safeStr(b['end_time'], "");
    final endDT = _parseDateTime(endDate, endTime, endOfDayFallback: true);
    if (endDT == null) return false;
    return endDT.isBefore(DateTime.now());
  }

  Future<bool> _hasFeedback(int bookingId) async {
    final data = await Supabase.instance.client
        .from('confinement_feedback')
        .select('id')
        .eq('booking_id', bookingId)
        .maybeSingle();
    return data != null;
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await Supabase.instance.client.from('confinement_bookings').update({
        'status': 'Cancelled',
        'payment_status': 'Cancelled',
        'payment_intent_id': null, // optional (if column exists)
      }).eq('id', bookingId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking cancelled ✅")),
      );

      setState(() {}); // refresh list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cancel failed: $e")),
      );
    }
  }

  Future<bool> _confirmCancelDialog() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel booking?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
    return res == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                "View Bookings",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Calsans",
                  color: Color.fromARGB(255, 106, 63, 114),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FutureBuilder<List<dynamic>>(
                  future: fetchBookings(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final bookings = snapshot.data ?? [];

                    if (bookings.isEmpty) {
                      return const Center(
                        child: Text(
                          "No bookings yet.",
                          style: TextStyle(fontFamily: "Calsans"),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {});
                      },
                      child: ListView.builder(
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final b = bookings[index];

                          final unpaid = _isUnpaid(b);
                          final cancelled = _isCancelled(b);
                          final canPay = unpaid && !cancelled;

                          final ended = _bookingEnded(b);
                          final paid = _isPaid(b);

                          // ✅ FEEDBACK RULE: only when booking ended + not cancelled + (optional) paid
                          final canFeedbackByDate = ended && !cancelled && paid;

                          final int bookingId = _safeInt(b['id']);
                          final status = _safeStr(b['status']);
                          final packageType = _safeStr(b['package_type']);
                          final startDate = _safeStr(b['start_date']);
                          final endDate = _safeStr(b['end_date']);
                          final startTime = _safeStr(b['start_time']);
                          final endTime = _safeStr(b['end_time']);
                          final phone = _safeStr(b['phone']);
                          final paymentStatus = _safeStr(b['payment_status']);

                          final amountMYR = _safeInt(b['price'], 0);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 0,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: canPay
                                  ? () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PaymentPage(
                                            amountMYR: amountMYR,
                                            description: packageType,
                                            bookingId: bookingId.toString(),
                                            userEmail: Supabase.instance.client
                                                    .auth.currentUser?.email ??
                                                '',
                                          ),
                                        ),
                                      );
                                      if (!mounted) return;
                                      setState(() {});
                                    }
                                  : null,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Booking ID
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Booking Id:',
                                            style: TextStyle(
                                              fontFamily: "Calsans",
                                              fontSize: 16,
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              bookingId.toString(),
                                              style: const TextStyle(
                                                fontFamily: "Calsans",
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Status
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Status:',
                                            style: TextStyle(
                                              fontFamily: "Calsans",
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            status,
                                            style: TextStyle(
                                              fontFamily: "Calsans",
                                              color: cancelled
                                                  ? Colors.grey
                                                  : (status.toLowerCase() ==
                                                          'confirmed'
                                                      ? Colors.green
                                                      : Colors.redAccent),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Package
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Package:',
                                            style: TextStyle(
                                              fontFamily: "Calsans",
                                              fontSize: 16,
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              packageType,
                                              style: const TextStyle(
                                                fontFamily: "Calsans",
                                                color: Colors.black87,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Date + Time
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Booked On:',
                                            style: TextStyle(
                                              fontFamily: "Calsans",
                                              fontSize: 16,
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              "$startDate $startTime  -  $endDate $endTime",
                                              style: const TextStyle(
                                                fontFamily: "Calsans",
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Phone
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Contact No:",
                                            style: TextStyle(
                                              fontFamily: "Calsans",
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            phone,
                                            style: const TextStyle(
                                              fontFamily: "Calsans",
                                              color: Colors.black87,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Payment
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Payment:",
                                            style: TextStyle(
                                              fontFamily: "Calsans",
                                              fontSize: 16,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                paymentStatus,
                                                style: TextStyle(
                                                  fontFamily: "Calsans",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: cancelled
                                                      ? Colors.grey
                                                      : (unpaid
                                                          ? Colors.orange
                                                          : Colors.green),
                                                ),
                                              ),
                                              if (canPay) ...[
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.chevron_right,
                                                  color: Colors.black54,
                                                )
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),

                                      if (canPay) ...[
                                        const SizedBox(height: 6),
                                        const Text(
                                          "Tap to pay now",
                                          style: TextStyle(
                                            fontFamily: "Calsans",
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],

                                      // ✅ Cancel button only when UNPAID and NOT cancelled
                                      if (!cancelled && unpaid) ...[
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 44,
                                          child: OutlinedButton.icon(
                                            icon: const Icon(
                                              Icons.cancel_outlined,
                                            ),
                                            label: const Text(
                                              "Cancel Booking",
                                              style: TextStyle(
                                                fontFamily: "Calsans",
                                              ),
                                            ),
                                            onPressed: () async {
                                              final confirm =
                                                  await _confirmCancelDialog();
                                              if (!confirm) return;
                                              await _cancelBooking(
                                                  bookingId.toString());
                                            },
                                          ),
                                        ),
                                      ],

                                      // ✅ Feedback: only after date ended + paid + not cancelled
                                      if (canFeedbackByDate) ...[
                                        const SizedBox(height: 12),
                                        FutureBuilder<bool>(
                                          future: _hasFeedback(bookingId),
                                          builder: (context, snap) {
                                            final submitted = snap.data == true;

                                            if (submitted) {
                                              return SizedBox(
                                                width: double.infinity,
                                                height: 44,
                                                child: OutlinedButton.icon(
                                                  onPressed: null,
                                                  icon: const Icon(Icons
                                                      .check_circle_outline),
                                                  label: const Text(
                                                    "Feedback Submitted ✅",
                                                    style: TextStyle(
                                                        fontFamily: "Calsans"),
                                                  ),
                                                ),
                                              );
                                            }

                                            return SizedBox(
                                              width: double.infinity,
                                              height: 44,
                                              child: ElevatedButton.icon(
                                                icon: const Icon(
                                                    Icons.rate_review_outlined),
                                                label: const Text(
                                                  "Give Feedback",
                                                  style: TextStyle(
                                                      fontFamily: "Calsans"),
                                                ),
                                                onPressed: () async {
                                                  final ok = await Navigator
                                                      .push<bool>(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          ConfinementFeedbackPage(
                                                        bookingId: bookingId,
                                                        userId: userId,
                                                        packageType:
                                                            packageType,
                                                      ),
                                                    ),
                                                  );

                                                  if (!mounted) return;
                                                  if (ok == true) {
                                                    setState(() {});
                                                  }
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
