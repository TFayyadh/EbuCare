import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewBookingsPage extends StatefulWidget {
  const ViewBookingsPage({super.key});

  @override
  State<ViewBookingsPage> createState() => _ViewBookingsPageState();
}

class _ViewBookingsPageState extends State<ViewBookingsPage> {
  final String userId = Supabase.instance.client.auth.currentUser?.id ?? '';

  Future<List<dynamic>> fetchResources() async {
    final data = await Supabase.instance.client
        .from('confinement_bookings') // e.g., 'resources'
        .select()
        .eq('user_id', userId);

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  "View Bookings",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Calsans",
                      color: const Color.fromARGB(255, 106, 63, 114)),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: FutureBuilder<List<dynamic>>(
                      future: fetchResources(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        }

                        final resources = snapshot.data!;

                        return RefreshIndicator(
                          onRefresh: () async {
                            setState(() {});
                          },
                          child: ListView.builder(
                            itemCount: resources.length,
                            itemBuilder: (context, index) {
                              final resource = resources[index];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 0),
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resource["package_type"],
                                        style: TextStyle(
                                            fontFamily: "Calsans",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        resource['status'],
                                        style: TextStyle(
                                            fontFamily: "Calsans",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        maxLines: 4,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "${resource['start_date']} - ${resource['end_date']}",
                                        style: TextStyle(
                                            fontFamily: "Raleway",
                                            fontWeight: FontWeight.normal,
                                            fontSize: 16),
                                        maxLines: 4,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        resource['phone'],
                                        style: TextStyle(
                                            fontFamily: "Raleway",
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14),
                                        maxLines: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
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
