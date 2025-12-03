import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConfinementDetails7DaysPage extends StatefulWidget {
  const ConfinementDetails7DaysPage({super.key});

  @override
  State<ConfinementDetails7DaysPage> createState() =>
      _ConfinementDetails7DaysPageState();
}

class _ConfinementDetails7DaysPageState
    extends State<ConfinementDetails7DaysPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  DateTime? selectedDate;

  // NEW: State for nannies
  List<Map<String, dynamic>> _nannies = [];
  String? _selectedNannyId;
  bool _isLoadingNannies = true;
  String? _nannyError;

  List<DateTime> getSevenDays(DateTime start) {
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  @override
  void initState() {
    super.initState();
    _loadNannies(); // NEW
  }

  // NEW: Fetch nannies from Supabase
  Future<void> _loadNannies() async {
    try {
      final data = await Supabase.instance.client
          .from('nanny') // your table name
          .select()
          .order('name'); // assuming you have a 'name' column

      setState(() {
        _nannies = List<Map<String, dynamic>>.from(data);
        _isLoadingNannies = false;
      });
    } catch (e) {
      setState(() {
        _nannyError = 'Failed to load nannies';
        _isLoadingNannies = false;
      });
    }
  }

  Map<String, dynamic>? _getSelectedNanny() {
    if (_selectedNannyId == null) return null;
    return _nannies.firstWhere(
      (n) => n['id'].toString() == _selectedNannyId,
      orElse: () => {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        title: const Text(
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
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Package info card (unchanged)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 251, 182, 183),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Icon(Icons.house, size: 80, color: Colors.white70),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "7 Days Care Package",
                            style: TextStyle(
                              fontFamily: "Calsans",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                "Pending",
                                style: TextStyle(
                                  fontFamily: "Calsans",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
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
              const SizedBox(height: 20),

              // DETAILS CARD
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Details",
                      style: TextStyle(
                        fontFamily: "Calsans",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Date row (unchanged)
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
                          icon: const Icon(Icons.date_range_outlined),
                        ),
                        if (selectedDate != null)
                          Text(
                            "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} - "
                            "${selectedDate!.add(const Duration(days: 6)).day}/${selectedDate!.add(const Duration(days: 6)).month}/${selectedDate!.add(const Duration(days: 6)).year}",
                            style: const TextStyle(
                              fontFamily: "Calsans",
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          )
                        else
                          const Text(
                            "Date",
                            style: TextStyle(
                              fontFamily: "Calsans",
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Address row (unchanged)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.home_filled),
                        ),
                        Expanded(
                          child: TextField(
                            controller: addressController,
                            decoration: InputDecoration(
                              hintText: 'Enter your address',
                              hintStyle: const TextStyle(
                                color: Colors.black54,
                                fontFamily: "Calsans",
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            maxLines: 5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Phone row (unchanged)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.phone_android_rounded),
                        ),
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              hintText: 'Enter your phone number',
                              hintStyle: const TextStyle(
                                color: Colors.black54,
                                fontFamily: "Calsans",
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            maxLines: 1,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // NEW: Nanny selection
                    Center(
                      child: const Text(
                        "Choose Nanny / Confinement Lady",
                        style: TextStyle(
                          fontFamily: "Calsans",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingNannies)
                      const Center(child: CircularProgressIndicator())
                    else if (_nannyError != null)
                      Text(
                        _nannyError!,
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedNannyId,
                        decoration: InputDecoration(
                          hintText: "Select nanny",
                          hintStyle: const TextStyle(
                            fontFamily: "Calsans",
                            color: Colors.black54,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _nannies.map((nanny) {
                          return DropdownMenuItem<String>(
                            value: nanny['id'].toString(),
                            child: Text(
                              nanny['name']?.toString() ?? 'No name',
                              style: const TextStyle(fontFamily: "Calsans"),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedNannyId = value;
                          });
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SUBMIT BUTTON
              ElevatedButton(
                onPressed: () async {
                  // Validation
                  if (_selectedNannyId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Please select a nanny / confinement lady")),
                    );
                    return;
                  }

                  if (selectedDate == null ||
                      addressController.text.isEmpty ||
                      phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                    return; // IMPORTANT: stop here if invalid
                  }

                  final user = Supabase.instance.client.auth.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User not logged in")),
                    );
                    return;
                  }

                  final selectedNanny = _getSelectedNanny();

                  final bookingData = {
                    'user_id': user.id,
                    'package_type': '7 Days Care Package',
                    'start_date':
                        selectedDate!.toIso8601String().split('T').first,
                    'end_date': selectedDate!
                        .add(const Duration(days: 6))
                        .toIso8601String()
                        .split('T')
                        .first,
                    'address': addressController.text,
                    'phone': phoneController.text,
                    'status': 'Pending',
                    'created_at': DateTime.now().toIso8601String(),

                    // NEW: nanny info
                    'nanny_id': _selectedNannyId,
                    if (selectedNanny != null)
                      'nanny_name': selectedNanny['name'],
                  };

                  try {
                    await Supabase.instance.client
                        .from('confinement_bookings')
                        .insert(bookingData);

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Booking submitted successfully")),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 251, 182, 183),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
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
