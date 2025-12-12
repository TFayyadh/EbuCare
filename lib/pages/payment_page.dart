import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentPage extends StatefulWidget {
  final int amountMYR; // e.g. 159 or 1500
  final String description; // e.g. "Relaxation Massage (1h 30m)"
  final String bookingId; // inserted booking row id (uuid string)

  const PaymentPage({
    super.key,
    required this.amountMYR,
    required this.description,
    required this.bookingId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _loading = false;

  Future<void> _payNow() async {
    if (_loading) return;

    // ✅ IMPORTANT: flutter_stripe PaymentSheet is NOT supported on Web.
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment only available on mobile app")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Stripe expects smallest currency unit (MYR -> sen)
      final amountInSen = widget.amountMYR * 100;

      // ✅ Call Supabase Edge Function (must return client_secret)
      final res = await Supabase.instance.client.functions.invoke(
        'create-payment-intent',
        body: {
          "amount": amountInSen,
          "currency": "myr",
          "booking_id": widget.bookingId,
          "description": widget.description,
        },
      );

      debugPrint("Function status: ${res.status}");
      debugPrint("Function raw data: ${res.data}");

      // ✅ Edge Function response may be Map or String JSON
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

      // ✅ Extract intent id safely (if server didn’t provide)
      final intentId = paymentIntentId ??
          (clientSecret.contains('_secret_')
              ? clientSecret.split('_secret_').first
              : null);

      // ✅ Payment success → update booking row
      await Supabase.instance.client.from('confinement_bookings').update({
        'payment_status': 'Paid',
        'status': 'Confirmed',
        if (intentId != null) 'payment_intent_id': intentId,
      }).eq('id', widget.bookingId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful ✅")),
      );

      Navigator.pop(context, true); // return success
    } on StripeException catch (e) {
      if (!mounted) return;

      final msg = e.error.localizedMessage ?? "Payment cancelled/failed.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(fontFamily: "Calsans"),
        ),
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}
