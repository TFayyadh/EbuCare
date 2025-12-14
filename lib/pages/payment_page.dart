import 'dart:convert';

import 'package:ebucare_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ CHANGE this import path to match your project

class PaymentPage extends StatefulWidget {
  final int amountMYR;
  final String description;
  final String bookingId;

  // ✅ invoice email
  final String userEmail;

  const PaymentPage({
    super.key,
    required this.amountMYR,
    required this.description,
    required this.bookingId,
    required this.userEmail,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _loading = false;

  // ✅ Send invoice email (best-effort)
  Future<void> _sendInvoiceEmail({
    required String bookingId,
    required int amountMYR,
    required String description,
    required String toEmail,
    String? paymentIntentId,
  }) async {
    final res = await Supabase.instance.client.functions.invoke(
      'send-invoice-email',
      body: {
        "to": toEmail,
        "booking_id": bookingId,
        "description": description,
        "amount_myr": amountMYR,
        "payment_intent_id": paymentIntentId,
      },
    );

    if (res.status != 200) {
      throw Exception("Invoice email failed: ${res.data}");
    }
  }

  Future<void> _payNow() async {
    if (_loading) return;

    // PaymentSheet not supported on web
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment only available on mobile app")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // ✅ Block payment if cancelled
      final booking = await Supabase.instance.client
          .from('confinement_bookings')
          .select('status, payment_status')
          .eq('id', widget.bookingId)
          .single();

      final st = (booking['status'] ?? '').toString().toLowerCase();
      final ps = (booking['payment_status'] ?? '').toString().toLowerCase();

      if (st == 'cancelled' || ps == 'cancelled') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment disabled: booking cancelled.")),
        );
        return;
      }

      // Stripe expects smallest unit (MYR -> sen)
      final amountInSen = widget.amountMYR * 100;

      // ✅ Call Supabase Edge Function (returns client_secret)
      final res = await Supabase.instance.client.functions.invoke(
        'create-payment-intent',
        body: {
          "amount": amountInSen,
          "currency": "myr",
          "booking_id": widget.bookingId,
          "description": widget.description,
        },
      );

      Map<String, dynamic>? json;
      final data = res.data;

      if (data is Map) {
        json = Map<String, dynamic>.from(data);
      } else if (data is String) {
        json = jsonDecode(data) as Map<String, dynamic>;
      }

      if (json == null) {
        throw Exception("Unexpected response type: ${data.runtimeType}");
      }

      final clientSecret = json['client_secret']?.toString();
      final paymentIntentId = json['payment_intent_id']?.toString();
      final error = json['error']?.toString();

      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception("No client_secret. Server said: $error | Full: $json");
      }

      // ✅ Init PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "EbuCare",
          style: ThemeMode.light,
        ),
      );

      // ✅ Show PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      // ✅ Extract intent id
      final intentId = paymentIntentId ??
          (clientSecret.contains('_secret_')
              ? clientSecret.split('_secret_').first
              : null);

      // ✅ Update booking row as paid
      await Supabase.instance.client.from('confinement_bookings').update({
        'payment_status': 'Paid',
        'status': 'Confirmed',
        if (intentId != null) 'payment_intent_id': intentId,
      }).eq('id', widget.bookingId);

      // ✅ Send invoice email (DON’T fail payment if email fails)
      if (widget.userEmail.isNotEmpty) {
        try {
          await _sendInvoiceEmail(
            bookingId: widget.bookingId,
            amountMYR: widget.amountMYR,
            description: widget.description,
            toEmail: widget.userEmail,
            paymentIntentId: intentId,
          );
        } catch (e) {
          debugPrint("Invoice send failed (ignored): $e");
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful ✅")),
      );

      Navigator.pop(context, true);
    } on StripeException catch (e) {
      if (!mounted) return;
      final msg = e.error.localizedMessage ?? "Payment cancelled/failed.";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment error: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _payLater() {
    Navigator.pop(context, false);
  }

  Future<void> _cancelBooking() async {
    if (_loading) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel booking?"),
        content: const Text(
          "Are you sure you want to cancel this booking? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes, cancel"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    try {
      await Supabase.instance.client.from('confinement_bookings').update({
        'status': 'Cancelled',
        'payment_status': 'Cancelled',
        'payment_intent_id': null,
      }).eq('id', widget.bookingId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking cancelled ❌")),
      );

      // ✅ Redirect to HomePage and clear stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cancel failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        title: const Text("Payment", style: TextStyle(fontFamily: "Calsans")),
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: _loading ? null : _payLater,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Order Summary",
                      style: TextStyle(
                        fontFamily: "Calsans",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontFamily: "Calsans",
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Total: RM ${widget.amountMYR}",
                      style: const TextStyle(
                        fontFamily: "Calsans",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Booking ID: ${widget.bookingId}",
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Invoice email: ${widget.userEmail.isEmpty ? "Not available" : widget.userEmail}",
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // PAY NOW
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _payNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 251, 182, 183),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Pay Now (Card)",
                          style: TextStyle(
                            fontFamily: "Calsans",
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // PAY LATER
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _loading ? null : _payLater,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Pay Later",
                    style: TextStyle(
                      fontFamily: "Calsans",
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // CANCEL
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _loading ? null : _cancelBooking,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Cancel Booking",
                    style: TextStyle(
                      fontFamily: "Calsans",
                      fontSize: 16,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
