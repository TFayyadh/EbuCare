import 'package:flutter/material.dart';

class BookingDetailPage extends StatelessWidget {
  final Map bookings;

  const BookingDetailPage({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookings["name"] ?? "Detail",
            style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: "Raleway",
                fontWeight: FontWeight.bold)),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "${bookings['start_date']?.toString() ?? "No start date"} - ${bookings['end_date']?.toString() ?? "No end date"}",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Calsans",
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                bookings["package_type"]?.toString() ?? "No dates provided",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Calsans",
                    fontWeight: FontWeight.normal),
              ),
              Text(
                bookings["address"]?.toString() ?? "No addresses provided",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Calsans",
                    fontWeight: FontWeight.normal),
              ),
              Text(
                bookings["notes"]?.toString() ?? "No notes provided",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Calsans",
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
