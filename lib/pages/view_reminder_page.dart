import 'package:ebucare_app/pages/set_reminder_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewReminderPage extends StatefulWidget {
  const ViewReminderPage({super.key});

  @override
  State<ViewReminderPage> createState() => _ViewReminderPageState();
}

class _ViewReminderPageState extends State<ViewReminderPage> {
//Fetch Reminders Function
  Future<List<dynamic>> fetchReminders() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return []; // Prevents the error
    final response = await Supabase.instance.client
        .from('reminders')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: true);
    return response;
  }

//Delete Reminder Function
  Future<void> deleteReminder(int id) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await Supabase.instance.client
        .from('reminders')
        .delete()
        .eq('user_id', userId)
        .eq('reminder_id', id); // <-- filter by id too!
    setState(() {});
  }

  void editReminder(Map reminder) async {
    // Navigate to your edit page, passing the reminder data
    // After editing, call setState() to refresh
    // Example:

    final title = reminder['title'] ?? 'Reminder';
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SetReminderPage(title: title, reminder: reminder),
        ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        title: Text(
          "View Reminder",
          style: TextStyle(
            fontFamily: "Calsans",
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_outlined)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchReminders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final reminders = snapshot.data ?? [];
                  if (reminders.isEmpty) {
                    return Center(
                        child: Text(
                      'No existing reminders.',
                      style: TextStyle(fontFamily: "Calsans", fontSize: 20),
                    ));
                  }
                  return ListView.builder(
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        child: ListTile(
                          title: Text(
                            reminder['title'] ?? 'No Title',
                            style: TextStyle(
                              fontFamily: "Calsans",
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            (reminder['date'] ?? '') +
                                ' ' +
                                (reminder['time'] ?? ''),
                            style: TextStyle(
                              fontFamily: "Calsans",
                              fontSize: 15,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.mode_edit_outlined,
                                    color: Colors.blue[900]),
                                onPressed: () {
                                  editReminder(reminder);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_rounded,
                                    color: Colors.red[900]),
                                onPressed: () {
                                  final id = reminder['reminder_id'];
                                  if (id != null) {
                                    deleteReminder(reminder['reminder_id']);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Reminder ID is missing!')),
                                    );
                                  }
                                },
                              ),
                              if (reminder['is_daily'] == true)
                                Icon(Icons.repeat_rounded,
                                    color: Colors.indigo[900]),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
