import 'package:ebucare_app/pages/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SciaticMassagePage extends StatefulWidget {
  const SciaticMassagePage({super.key});

  @override
  State<SciaticMassagePage> createState() => _SciaticMassagePageState();
}

class _SciaticMassagePageState extends State<SciaticMassagePage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // ✅ User selects start date+time, end auto = +1h30m
  DateTime? startDateTime;
  DateTime? endDateTime;

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

  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // ✅ Date only: YYYY-MM-DD (for Supabase DATE column)
  String _toDateOnly(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  // ✅ Time only: HH:MM:SS (for Supabase TIME column)
  String _toTimeOnly(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    final ss = d.second.toString().padLeft(2, '0');
    return "$hh:$mm:$ss";
  }

  // ✅ Display helper: dd/MM/yyyy HH:mm
  String _fmtDisplay(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return "$dd/$mm/$yy $hh:$min";
  }

  // Fetch all nannies
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
        _nannyError = 'Failed to load nannies: $e';
        _isLoadingNannies = false;
      });
    }
  }

  // ✅ Pick DATE + TIME, end auto = +1h30m, then filter nannies
  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: startDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: startDateTime != null
          ? TimeOfDay.fromDateTime(startDateTime!)
          : TimeOfDay.fromDateTime(now),
    );
    if (pickedTime == null) return;

    final start = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final end = start.add(const Duration(hours: 2, minutes: 0));

    // ✅ Prevent crossing midnight (because you store date & time separately)
    if (start.day != end.day ||
        start.month != end.month ||
        start.year != end.year) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please choose a time that doesn't cross midnight (end time must be same day).",
          ),
        ),
      );
      return;
    }

    setState(() {
      startDateTime = start;
      endDateTime = end;
      _selectedNannyId = null;
    });

    await _filterNanniesForDateTime(start, end);
  }

  // ✅ Availability check using DATE + TIME overlap
  // Conflict on same date:
  // existing_start_time <= new_end_time AND existing_end_time >= new_start_time
  Future<void> _filterNanniesForDateTime(DateTime start, DateTime end) async {
    if (_nannies.isEmpty) return;

    setState(() {
      _checkingAvailability = true;
      _nannyError = null;
      _selectedNannyId = null;
    });

    try {
      final dateStr = _toDateOnly(start);
      final startTimeStr = _toTimeOnly(start);
      final endTimeStr = _toTimeOnly(end);

      final conflictData = await Supabase.instance.client
          .from('confinement_bookings')
          .select('nanny_id, start_date, start_time, end_time, status')
          .neq('status', 'Cancelled')
          .eq('start_date', dateStr)
          .lte('start_time', endTimeStr)
          .gte('end_time', startTimeStr);

      final conflictList = conflictData as List<dynamic>;
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
      debugPrint("❌ Availability error: $e");
      if (!mounted) return;
      setState(() {
        _nannyError = 'Failed to check nanny availability: $e';
        _checkingAvailability = false;
      });
    }
  }

  Map<String, dynamic>? _getSelectedNanny() {
    if (_selectedNannyId == null) return null;
    final found = _availableNannies
        .where((n) => n['id'].toString() == _selectedNannyId)
        .toList();
    if (found.isEmpty) return null;
    return found.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 226, 226),
      appBar: AppBar(
        title: const Text(
          "Booking Details",
          style: TextStyle(
            fontFamily: "Calsans",
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 247, 226, 226),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
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
                            "Sciatic Nerve Pain Relief",
                            style: TextStyle(
                              fontFamily: "Calsans",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            width: 120,
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

                    // Date+Time row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _pickDateTime,
                          icon: const Icon(Icons.date_range_outlined),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child:
                                (startDateTime != null && endDateTime != null)
                                    ? Text(
                                        "${_fmtDisplay(startDateTime!)}  →  ${_fmtDisplay(endDateTime!)}",
                                        style: const TextStyle(
                                          fontFamily: "Calsans",
                                          fontSize: 15,
                                          color: Colors.black54,
                                        ),
                                        textAlign: TextAlign.right,
                                      )
                                    : const Text(
                                        "Select Date & Time",
                                        style: TextStyle(
                                          fontFamily: "Calsans",
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
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
                      Text(_nannyError!,
                          style: const TextStyle(color: Colors.red))
                    else if (startDateTime == null || endDateTime == null)
                      const Text(
                        "Please select your booking date & time first to see available nannies.",
                        style: TextStyle(
                          fontFamily: "Calsans",
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      )
                    else if (_availableNannies.isEmpty)
                      const Text(
                        "No nanny is available for the selected time. Please choose another time.",
                        style: TextStyle(
                          fontFamily: "Calsans",
                          fontSize: 14,
                          color: Colors.redAccent,
                        ),
                      )
                    else ...[
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
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
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
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: _selectedNannyId == null
                              ? null
                              : () {
                                  final selected = _getSelectedNanny();
                                  if (selected == null) return;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NannyLadyProfilePage(
                                        nanny: selected,
                                      ),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.info_outline),
                          label: const Text(
                            "View Selected Nanny Profile",
                            style: TextStyle(fontFamily: "Calsans"),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SUBMIT BUTTON
              ElevatedButton(
                onPressed: () async {
                  if (startDateTime == null || endDateTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select booking date & time"),
                      ),
                    );
                    return;
                  }

                  if (_selectedNannyId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Please select a nanny / confinement lady"),
                      ),
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

                  // ✅ EXTRA SAFETY: re-check overlap for this nanny (DATE + TIME)
                  final dateStr = _toDateOnly(startDateTime!);
                  final startTimeStr = _toTimeOnly(startDateTime!);
                  final endTimeStr = _toTimeOnly(endDateTime!);

                  final conflicts = await Supabase.instance.client
                      .from('confinement_bookings')
                      .select('id')
                      .eq('nanny_id', _selectedNannyId.toString())
                      .neq('status', 'Cancelled')
                      .eq('start_date', dateStr)
                      .lte('start_time', endTimeStr)
                      .gte('end_time', startTimeStr);

                  if ((conflicts as List).isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Sorry, this nanny has just been booked for that time. Please pick another nanny or change time.",
                        ),
                      ),
                    );
                    await _filterNanniesForDateTime(
                        startDateTime!, endDateTime!);
                    return;
                  }

                  final selectedNanny = _getSelectedNanny();

                  final bookingData = {
                    'user_id': user.id,
                    'package_type': 'Sciatic Nerve Pain Relief',

                    // ✅ keep DATE separate from TIME
                    'start_date': _toDateOnly(startDateTime!),
                    'end_date': _toDateOnly(endDateTime!),
                    'start_time': _toTimeOnly(startDateTime!),
                    'end_time': _toTimeOnly(endDateTime!),

                    'address': addressController.text,
                    'phone': phoneController.text,
                    'status': 'Pending',
                    'price': 219,
                    'created_at': DateTime.now().toIso8601String(),
                    'nanny_id': _selectedNannyId,
                    if (selectedNanny != null)
                      'nanny_name': selectedNanny['name'],
                    'payment_status': 'Unpaid',
                  };

                  try {
                    final insertRes = await Supabase.instance.client
                        .from('confinement_bookings')
                        .insert(bookingData)
                        .select()
                        .single();

                    final bookingId = insertRes['id'].toString();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Booking submitted successfully"),
                      ),
                    );

                    final paid = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentPage(
                          amountMYR: 219,
                          description: "Sciatic Nerve Pain Relief",
                          bookingId: bookingId,
                          userEmail: user.email ?? '',
                        ),
                      ),
                    );

                    if (!mounted) return;

                    if (paid == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Booking confirmed & paid"),
                        ),
                      );
                      Navigator.pop(context);
                    } else if (paid == "cancelled") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Booking cancelled")),
                      );
                      Navigator.pop(context);
                    } else {
                      // pay later
                      Navigator.pop(context);
                    }
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
                    horizontal: 50.0,
                    vertical: 15.0,
                  ),
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
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : const AssetImage("assets/default_avatar.png")
                      as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(
                fontFamily: "Calsans",
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              role,
              style: const TextStyle(
                fontFamily: "Calsans",
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
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
