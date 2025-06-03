import 'package:ebucare_app/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final authService = AuthService();
  final String userId = Supabase.instance.client.auth.currentUser!.id;
  TextEditingController nameController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String package = '24/7';
  TextEditingController addressController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate)
      setState(() {
        startDate = picked;
      });
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate)
      setState(() {
        endDate = picked;
      });
  }

  void _saveEntry() async {
    final confinementBooking = {
      'user_id': userId,
      "name": nameController.text,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'package_type': package,
      'address': addressController.text,
      'notes': notesController.text,
    };

    try {
      final response = await Supabase.instance.client
          .from('confinement_bookings')
          .insert(confinementBooking);

      if (response != null) {
        throw Exception('Insert failed');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully booked!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving entry: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0, top: 0.0),
                  child: Text(
                    "Confinement Lady ",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Calsans",
                      color: const Color.fromARGB(255, 106, 63, 114),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ...all your form widgets (date, dropdowns, etc.)...

                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Full Name:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Raleway")),
                          Expanded(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter full name',
                                    hintStyle: TextStyle(
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        fontFamily: "Raleway"),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  style: TextStyle(
                                      fontFamily: "Raleway",
                                      color:
                                          const Color.fromARGB(255, 0, 0, 0)),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Start Date:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Raleway")),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor:
                                    const Color.fromARGB(255, 231, 228, 228),
                                textStyle: TextStyle(
                                    fontFamily: "Raleway",
                                    fontSize: 16,
                                    color: const Color.fromARGB(
                                        255, 106, 63, 114)),
                              ),
                              onPressed: _selectStartDate,
                              child:
                                  Text("${startDate.toLocal()}".split(' ')[0]),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('End Date:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Raleway")),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor:
                                    const Color.fromARGB(255, 231, 228, 228),
                                textStyle: TextStyle(
                                    fontFamily: "Raleway",
                                    fontSize: 16,
                                    color: const Color.fromARGB(
                                        255, 106, 63, 114)),
                              ),
                              onPressed: _selectEndDate,
                              child: Text("${endDate.toLocal()}".split(' ')[0]),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Package:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Raleway")),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromARGB(255, 231, 228, 228),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: DropdownButton<String>(
                                  value: package,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      package = newValue!;
                                    });
                                  },
                                  items: <String>[
                                    'Day: 8:00AM - 5:00PM',
                                    'Night: 8:00PM - 5:AM',
                                    '24/7'
                                  ]
                                      .map<DropdownMenuItem<String>>((String
                                              value) =>
                                          DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value,
                                                  style: TextStyle(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              106,
                                                              63,
                                                              114),
                                                      fontFamily: "Raleway"))))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),
                      Text('Address:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Raleway")),

                      SizedBox(height: 8),

                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          hintText: 'Enter address here...',
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontFamily: "Raleway"),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 8),
                      Text('Notes:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Raleway")),
                      SizedBox(height: 8),

                      TextField(
                        controller: notesController,
                        decoration: InputDecoration(
                          hintText: 'Any notes...',
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontFamily: "Raleway"),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 48),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveEntry,
                          child: Text('Save'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 243, 229, 245),
                            textStyle: TextStyle(
                                fontFamily: "Raleway",
                                fontSize: 16,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
// ...existing code...
    );
  }
}
