import 'package:ebucare_app/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BabySleepPage extends StatefulWidget {
  @override
  _BabySleepPageState createState() => _BabySleepPageState();
}

class _BabySleepPageState extends State<BabySleepPage> {
  final authService = AuthService();
  final String userId = Supabase.instance.client.auth.currentUser!.id;

  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 6, minute: 0);
  String sleepQuality = 'Good';
  TextEditingController notesController = TextEditingController();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _saveEntry() async {
    final sleepEntry = {
      'user_id': userId,
      'date': selectedDate.toIso8601String(),
      'start_time': startTime.format(context),
      'end_time': endTime.format(context),
      'sleep_quality': sleepQuality,
      'notes': notesController.text,
    };

    try {
      final response =
          await Supabase.instance.client.from('baby_sleep').insert(sleepEntry);

      if (response != null) {
        throw Exception('Insert failed');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sleep entry saved!')),
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
                    "Sleep Tracker",
                    textAlign: TextAlign.center,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Date:',
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
                              onPressed: _selectDate,
                              child: Text(
                                  "${selectedDate.toLocal()}".split(' ')[0]),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Start Time:',
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
                              onPressed: () => _selectTime(context, true),
                              child: Text(startTime.format(context)),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('End Time:',
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
                              onPressed: () => _selectTime(context, false),
                              child: Text(endTime.format(context)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sleep Quality:',
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
                                  value: sleepQuality,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      sleepQuality = newValue!;
                                    });
                                  },
                                  items: <String>['Good', 'Okay', 'Poor']
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
                      Text('Notes:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Raleway")),
                      SizedBox(height: 24),
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
