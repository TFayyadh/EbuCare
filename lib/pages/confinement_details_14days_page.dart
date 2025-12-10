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

  // Nannies state
  List<Map<String, dynamic>> _nannies = [];
  List<Map<String, dynamic>> _availableNannies = [];
  String? _selectedNannyId;
  bool _isLoadingNannies = true;
  bool _checkingAvailability = false;
  String? _nannyError;

  @override
  void initState() {
    super.initState();
    _loadNannies();
  }

  // Helper: format date as yyyy-MM-dd
  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  // Fetch all nannies from Supabase
  Future<void> _loadNannies() async {
    try {
      final data =
          await Supabase.instance.client.from('nanny').select().order('name');

      setState(() {
        _nannies = List<Map<String, dynamic>>.from(data);
        _availableNannies = _nannies;
        _isLoadingNannies = false;
      });
    } catch (e) {
      setState(() {
        _nannyError = 'Failed to load nannies';
        _isLoadingNannies = false;
      });
    }
  }

  // Filter nannies using overlap logic:
  // existing_start <= new_end AND existing_end >= new_start
  Future<void> _filterNanniesForDate(DateTime startDate) async {
    if (_nannies.isEmpty) return;

    setState(() {
      _checkingAvailability = true;
      _nannyError = null;
      _selectedNannyId = null;
    });

    final startStr = _formatDate(startDate);
    final endStr = _formatDate(startDate.add(const Duration(days: 6)));

    try {
      final conflictData = await Supabase.instance.client
          .from('confinement_bookings')
          .select('nanny_id, start_date, end_date')
          .lte('start_date', endStr) // start_date <= new_end
          .gte('end_date', startStr); // end_date >= new_start

      final List<dynamic> conflictList = conflictData;
      final Set<String> busyNannyIds =
          conflictList.map((b) => b['nanny_id'].toString()).toSet();

      final filtered = _nannies
          .where((n) => !busyNannyIds.contains(n['id'].toString()))
          .toList();

      setState(() {
        _availableNannies = filtered;
        _checkingAvailability = false;
      });
    } catch (e) {
      setState(() {
        _nannyError = 'Failed to check nanny availability';
        _checkingAvailability = false;
      });
    }
  }

  Map<String, dynamic>? _getSelectedNanny() {
    if (_selectedNannyId == null) return null;
    return _availableNannies.firstWhere(
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
              // Package info card
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
                            "14 Days Care Package",
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

                    // Date row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () async {
                            DateTime now = DateTime.now();
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? now,
                              firstDate: now,
                              lastDate: DateTime(now.year + 2),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                              await _filterNanniesForDate(pickedDate);
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

                    // Address row
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

                    // Phone row
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

                    // Nanny selection
                    const Center(
                      child: Text(
                        "Choose Nanny / Confinement Lady",
                        style: TextStyle(
                          fontFamily: "Calsans",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_isLoadingNannies || _checkingAvailability)
                      const Center(child: CircularProgressIndicator())
                    else if (_nannyError != null)
                      Text(
                        _nannyError!,
                        style: const TextStyle(color: Colors.red),
                      )
                    else if (selectedDate == null)
                      const Text(
                        "Please select your start date first to see available nannies.",
                        style: TextStyle(
                          fontFamily: "Calsans",
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      )
                    else if (_availableNannies.isEmpty)
                      const Text(
                        "No nanny is available for the selected dates. Please choose another date.",
                        style: TextStyle(
                          fontFamily: "Calsans",
                          fontSize: 14,
                          color: Colors.redAccent,
                        ),
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
                        items: _availableNannies.map((nanny) {
                          final id = nanny['id'].toString();
                          final name = nanny['name']?.toString() ?? 'No name';

                          return DropdownMenuItem<String>(
                            value: id,
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min, // 👈 shrink-wrap row
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: "Calsans",
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.info_outline,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets
                                          .zero, // optional: make it tighter
                                      constraints:
                                          const BoxConstraints(), // optional
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                NannyLadyProfilePage(
                                                    nanny: nanny),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
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
                  if (selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please select your booking date")),
                    );
                    return;
                  }

                  if (_selectedNannyId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Please select a nanny / confinement lady")),
                    );
                    return;
                  }

                  if (addressController.text.isEmpty ||
                      phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  final user = Supabase.instance.client.auth.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User not logged in")),
                    );
                    return;
                  }

                  // EXTRA SAFETY: re-check overlap for this nanny
                  final startStr = _formatDate(selectedDate!);
                  final endStr =
                      _formatDate(selectedDate!.add(const Duration(days: 6)));

                  final conflicts = await Supabase.instance.client
                      .from('confinement_bookings')
                      .select('id')
                      .eq('nanny_id', _selectedNannyId.toString())
                      .lte('start_date', endStr)
                      .gte('end_date', startStr);

                  if ((conflicts as List).isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Sorry, this nanny has just been booked for these dates. Please pick another nanny or change dates.",
                        ),
                      ),
                    );
                    await _filterNanniesForDate(selectedDate!);
                    return;
                  }

                  final selectedNanny = _getSelectedNanny();

                  final bookingData = {
                    'user_id': user.id,
                    'package_type': '14 Days Care Package',
                    'start_date': startStr,
                    'end_date': endStr,
                    'address': addressController.text,
                    'phone': phoneController.text,
                    'status': 'Pending',
                    'price': 1500,
                    'created_at': DateTime.now().toIso8601String(),
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

class NannyLadyProfilePage extends StatelessWidget {
  final Map<String, dynamic> nanny;

  const NannyLadyProfilePage({super.key, required this.nanny});

  @override
  Widget build(BuildContext context) {
    final name = nanny['name']?.toString() ?? 'Unknown';
    final role = nanny['role']?.toString() ?? 'Not provided';
    final qualification = nanny['qualification']?.toString() ?? 'Not provided';
    final experience = nanny['experience']?.toString() ?? '0';
    final phone = nanny['phone']?.toString() ?? '-';
    final avatarUrl = nanny['avatar_url']?.toString();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        title: const Text(
          "Nanny Profile",
          style: TextStyle(fontFamily: "Calsans"),
        ),
        backgroundColor: const Color.fromARGB(255, 251, 182, 183),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ⭐ Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : const AssetImage("assets/default_avatar.png")
                      as ImageProvider,
            ),

            const SizedBox(height: 20),

            // ⭐ Name
            Text(
              name,
              style: const TextStyle(
                fontFamily: "Calsans",
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // ⭐ Role
            Text(
              role,
              style: const TextStyle(
                fontFamily: "Calsans",
                fontSize: 18,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            // ⭐ Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow("Qualification", qualification),
                  const SizedBox(height: 12),
                  _infoRow("Experience", "$experience years"),
                  const SizedBox(height: 12),
                  _infoRow("Phone", phone),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable row widget
  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            fontFamily: "Calsans",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: "Calsans",
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
