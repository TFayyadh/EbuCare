import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConfinementDetails14DaysPage extends StatefulWidget {
  const ConfinementDetails14DaysPage({super.key});

  @override
  State<ConfinementDetails14DaysPage> createState() =>
      _ConfinementDetails14DaysPageState();
}

class _ConfinementDetails14DaysPageState
    extends State<ConfinementDetails14DaysPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  DateTime? selectedDate;

  List<DateTime> getSevenDays(DateTime start) {
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        title: Text(
          "Booking Details",
          style: TextStyle(
            fontFamily: "Calsans",
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_outlined)),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color.fromARGB(255, 251, 182, 183)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.house, size: 80, color: Colors.white70),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "14 Days Care Package",
                            style: TextStyle(
                                fontFamily: "Calsans",
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          Container(
                            width: 100,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(
                              child: Text(
                                "Pending",
                                style: TextStyle(
                                    fontFamily: "Calsans",
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Details",
                      style: TextStyle(
                          fontFamily: "Calsans",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 2),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          icon: Icon(Icons.date_range_outlined),
                        ),
                        if (selectedDate != null)
                          Text(
                            // Show start and end date
                            "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} - "
                            "${selectedDate!.add(Duration(days: 13)).day}/${selectedDate!.add(Duration(days: 13)).month}/${selectedDate!.add(Duration(days: 13)).year}",
                            style: TextStyle(
                              fontFamily: "Calsans",
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          )
                        else
                          Text(
                            "Date",
                            style: TextStyle(
                              fontFamily: "Calsans",
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {}, icon: Icon(Icons.home_filled)),
                        Expanded(
                          child: TextField(
                            controller: addressController,
                            decoration: InputDecoration(
                              hintText: 'Enter your address',
                              hintStyle: TextStyle(
                                  color: Colors.black54, fontFamily: "Calsans"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            maxLines: 5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.phone_android_rounded)),
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              hintText: 'Enter your phone number',
                              hintStyle: TextStyle(
                                  color: Colors.black54, fontFamily: "Calsans"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (selectedDate == null ||
                      addressController.text.isEmpty ||
                      phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill all fields")));
                  }
                  final userId = Supabase.instance.client.auth.currentUser!.id;
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("User not logged in")));
                    return;
                  }

                  final bookingData = {
                    'user_id': userId,
                    'package_type': '14 Days Care Package',
                    'start_date':
                        selectedDate!.toIso8601String().split('T').first,
                    'end_date': selectedDate!
                        .add(Duration(days: 13))
                        .toIso8601String()
                        .split('T')
                        .first,
                    'address': addressController.text,
                    'phone': phoneController.text,
                    'status': 'Pending',
                    'created_at': DateTime.now().toIso8601String(),
                  };

                  final response = await Supabase.instance.client
                      .from('confinement_bookings')
                      .insert(bookingData);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Booking submitted successfully")),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 251, 182, 183),
                  padding:
                      EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontFamily: "Calsans",
                    fontSize: 18,
                    color: Colors.white,
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
