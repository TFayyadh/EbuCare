import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/cupertino.dart';

class SetReminderPage extends StatefulWidget {
  const SetReminderPage({super.key});

  @override
  State<SetReminderPage> createState() => _SetReminderPageState();
}

class _SetReminderPageState extends State<SetReminderPage> {
  DateTime selectedDate = DateTime.now();
  int selectedHour = 12;
  int selectedMinute = 0;
  String selectedPeriod = "PM";
  bool isDaily = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        title: Text(
          "Set Reminder",
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 40,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            "Date",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Calsans",
                              color: const Color.fromARGB(255, 106, 63, 114),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Daily Reminder",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Calsans",
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 10),
                          CupertinoSwitch(
                            value: isDaily,
                            onChanged: (value) {
                              setState(() {
                                isDaily = value;
                              });
                            },
                            activeTrackColor:
                                const Color.fromARGB(255, 190, 179, 218),
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Opacity(
                    opacity: isDaily ? 0.5 : 1.0,
                    // Disable interaction when isDaily is true
                    child: AbsorbPointer(
                      absorbing: isDaily,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 123, 101, 180),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DatePicker(DateTime.now(),
                              initialSelectedDate: DateTime.now(),
                              selectionColor: Colors.deepPurple,
                              selectedTextColor: Colors.white,
                              daysCount: 365, onDateChange: (date) {
                            setState(() {
                              selectedDate = date;
                            });
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 20.0),
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 123, 101, 180),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Transform.translate(
                          offset: Offset(0, -50),
                          child: Container(
                            height: 40,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "Time",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: "Calsans",
                                  color:
                                      const Color.fromARGB(255, 106, 63, 114),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //Hour Picker
                              SizedBox(
                                width: 100,
                                child: CupertinoPicker(
                                  itemExtent: 40,
                                  scrollController: FixedExtentScrollController(
                                      initialItem: selectedHour - 1),
                                  onSelectedItemChanged: (value) =>
                                      setState(() => selectedHour = value + 1),
                                  children: List.generate(12, (index) {
                                    return Center(
                                        child: Text("${index + 1}",
                                            style: TextStyle(
                                                fontSize: 30,
                                                fontFamily: "Calsans")));
                                  }),
                                ),
                              ),
                              Text(":",
                                  style: TextStyle(
                                      fontSize: 30, fontFamily: "Calsans")),
                              // Minute picker
                              SizedBox(
                                width: 100,
                                child: CupertinoPicker(
                                  itemExtent: 40,
                                  scrollController: FixedExtentScrollController(
                                    initialItem: selectedMinute,
                                  ),
                                  onSelectedItemChanged: (value) =>
                                      setState(() => selectedMinute = value),
                                  children: List.generate(60, (index) {
                                    return Center(
                                      child: Text(
                                        index.toString().padLeft(2, '0'),
                                        style: TextStyle(
                                            fontFamily: "Calsans",
                                            fontSize: 30),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: CupertinoPicker(
                                  itemExtent: 40,
                                  scrollController: FixedExtentScrollController(
                                    initialItem: selectedPeriod == "AM" ? 0 : 1,
                                  ),
                                  onSelectedItemChanged: (value) => setState(
                                      () => selectedPeriod =
                                          value == 0 ? "AM" : "PM"),
                                  children: ["AM", "PM"]
                                      .map(
                                        (p) => Center(
                                            child: Text(
                                          p,
                                          style: TextStyle(
                                              fontFamily: "Calsans",
                                              fontSize: 30),
                                        )),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Transform.translate(
                            offset: Offset(0, 0),
                            child: Container(
                              height: 50,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextButton(
                                child: Text(
                                  "Set Reminder",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: "Calsans",
                                      color: Colors.black),
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
