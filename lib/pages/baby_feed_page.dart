import 'package:ebucare_app/auth/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BabyFeedPage extends StatefulWidget {
  @override
  _BabyFeedPageState createState() => _BabyFeedPageState();
}

class _BabyFeedPageState extends State<BabyFeedPage> {
  final authService = AuthService();
  final String userId = Supabase.instance.client.auth.currentUser!.id;

  DateTime selectedDate = DateTime.now();
  TimeOfDay Time = TimeOfDay(hour: 22, minute: 0);
  String feedingType = 'Breast Milk';
  String? breastSide;
  final List<String> durations = [
    '5 minutes',
    '10 minutes',
    '15 minutes',
    '20 minutes',
    '25 minutes',
    '30 minutes',
    '35 minutes',
    '40 minutes',
    '45 minutes',
    '50 minutes',
    '55 minutes',
    '60 minutes',
    '> 60 minutes',
  ];
  String? selectedDuration;
  final List<String> amount = [
    '<50 ml',
    '100 ml',
    '150 ml',
    '200 ml',
    '250 ml',
    '300 ml',
    '350 ml',
    '400 ml',
    '450 ml',
    '500 ml',
    '550 ml',
    '600 ml',
    '> 500 ml',
  ];
  String? selectedAmount;
  TextEditingController notesController = TextEditingController();
  TextEditingController foodDescController = TextEditingController();

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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked != null) {
      setState(() {
        Time = picked;
      });
    } else {
      Time = TimeOfDay.now();
    }
  }

  void _saveEntry() async {
    if (feedingType == "Breast Milk" &&
        (breastSide == null || selectedDuration == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select breast side and duration.')),
      );
      return;
    }

    if (feedingType == 'Formula Milk' && selectedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select amount.')),
      );
      return;
    }

    final feedEntry = {
      'user_id': userId,
      'date': selectedDate.toIso8601String(),
      'time': Time.format(context),
      'feeding_type': feedingType,
      'notes': notesController.text,
      'food_description': foodDescController.text,
    };

    if (feedingType == 'Breast Milk') {
      feedEntry['breast_side'] = breastSide!;
      feedEntry['duration'] = selectedDuration!;
    } else if (feedingType == 'Formula Milk') {
      feedEntry['amount'] = selectedAmount!;
    }

    try {
      final response =
          await Supabase.instance.client.from('baby_feed').insert(feedEntry);

      if (response != null) {
        throw Exception('Insert failed');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feed entry saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving entry: $e')),
      );
    }
  }

  Widget breastSides(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Breast Side:',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontFamily: "Raleway")),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 231, 228, 228),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: DropdownButton<String>(
                value: breastSide,
                hint: Text('Select side'),
                onChanged: (String? newValue) {
                  setState(() {
                    breastSide = newValue;
                  });
                },
                items: <String>[
                  'Left',
                  'Right',
                ]
                    .map<DropdownMenuItem<String>>((String value) =>
                        DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 106, 63, 114),
                                    fontFamily: "Raleway"))))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget durationTime(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Duration:',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontFamily: "Raleway")),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 231, 228, 228),
              ),
              child: CupertinoButton(
                  color: const Color.fromARGB(255, 231, 228, 228),
                  child: Text(selectedDuration ?? 'Select duration'),
                  onPressed: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (_) => SizedBox(
                              width: double.infinity,
                              height: 250,
                              child: CupertinoPicker(
                                backgroundColor:
                                    const Color.fromARGB(255, 231, 228, 228),
                                itemExtent: 40,
                                scrollController:
                                    FixedExtentScrollController(initialItem: 0),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedDuration = durations[index];
                                  });
                                },
                                children: const [
                                  Text(
                                    '5 minutes',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '10 minutes',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '15 minutes',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '20 minutes',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '25 minutes',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '30 minutes',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '35 minutes',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '40 minutes',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '45 minutes',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '50 minutes',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '55 minutes',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '60 minutes',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '> 60 minutes',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                ],
                              ),
                            ));
                  })),
        ),
      ],
    );
  }

  Widget feedAmount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Amount:',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontFamily: "Raleway")),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 231, 228, 228),
              ),
              child: CupertinoButton(
                  color: const Color.fromARGB(255, 231, 228, 228),
                  child: Text(selectedAmount ?? 'Select amount'),
                  onPressed: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (_) => SizedBox(
                              width: double.infinity,
                              height: 250,
                              child: CupertinoPicker(
                                backgroundColor:
                                    const Color.fromARGB(255, 231, 228, 228),
                                itemExtent: 40,
                                scrollController:
                                    FixedExtentScrollController(initialItem: 0),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedAmount = amount[index];
                                  });
                                },
                                children: const [
                                  Text(
                                    '50 ml',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '100 ml',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '150 ml',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '200 ml',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '250 ml',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '300 ml',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '350 ml',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '400 ml',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '450 ml',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '500 ml',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                  Text(
                                    '> 500 ml',
                                    style: TextStyle(
                                      fontFamily: "Calsans",
                                    ),
                                  ),
                                ],
                              ),
                            ));
                  })),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 226, 226),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 247, 226, 226),
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
                    "Feed Tracker",
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
                          Text('Time:',
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
                              onPressed: () => _selectTime(
                                context,
                              ),
                              child: Text(Time.format(context)),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Feeding Type:',
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
                                  value: feedingType,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      feedingType = newValue!;
                                    });
                                  },
                                  items: <String>[
                                    'Breast Milk',
                                    'Formula Milk',
                                    'Solid Food'
                                  ]
                                      .map<DropdownMenuItem<String>>(
                                          (String value) =>
                                              DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value,
                                                      style: TextStyle(
                                                          color: const Color
                                                              .fromARGB(255,
                                                              106, 63, 114),
                                                          fontFamily:
                                                              "Raleway"))))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      if (feedingType == 'Breast Milk') ...[
                        breastSides(context),
                      ],
                      if (feedingType == 'Breast Milk') ...[
                        SizedBox(height: 24),
                        durationTime(context),
                      ],

                      if (feedingType == 'Formula Milk') ...[
                        feedAmount(context),
                      ],

                      SizedBox(height: 24),
                      if (feedingType == "Breast Milk" ||
                          feedingType == "Formula Milk") ...[
                        Text('Notes:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Raleway")),
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
                      ],
                      if (feedingType == "Solid Food") ...[
                        Text('Food Description:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Raleway")),
                        TextField(
                          controller: foodDescController,
                          decoration: InputDecoration(
                            hintText: 'Describe the food here...',
                            hintStyle: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontFamily: "Raleway"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          maxLines: 3,
                        ),
                      ],
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
