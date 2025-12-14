import 'package:flutter/material.dart';

class BookingDetailPage extends StatelessWidget {
  final Map bookings;

  const BookingDetailPage({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          bookings["name"] ?? "Detail",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontFamily: "Raleway",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dates
            Text(
              "${bookings['start_date']?.toString() ?? "No start date"} - "
              "${bookings['end_date']?.toString() ?? "No end date"}",
              style: const TextStyle(
                fontSize: 16,
                fontFamily: "Calsans",
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16),

            // Package type
            Text(
              bookings["package_type"]?.toString() ?? "No package type",
              style: const TextStyle(
                fontSize: 16,
                fontFamily: "Calsans",
                fontWeight: FontWeight.normal,
              ),
            ),

            // NEW: Nanny name
            const SizedBox(height: 8),
            Text(
              "Nanny: ${bookings['nanny_name']?.toString() ?? "Not selected"}",
              style: const TextStyle(
                fontSize: 16,
                fontFamily: "Calsans",
                fontWeight: FontWeight.normal,
              ),
            ),

            const SizedBox(height: 8),

            // Address
            Text(
              bookings["address"]?.toString() ?? "No addresses provided",
              style: const TextStyle(
                fontSize: 16,
                fontFamily: "Calsans",
                fontWeight: FontWeight.normal,
              ),
            ),

            const SizedBox(height: 8),

            // Notes
            Text(
              bookings["notes"]?.toString() ?? "No notes provided",
              style: const TextStyle(
                fontSize: 16,
                fontFamily: "Calsans",
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
