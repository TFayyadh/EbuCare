import 'package:ebucare_app/auth/auth_service.dart';
import 'package:ebucare_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageProfile extends StatefulWidget {
  const ManageProfile({super.key});

  @override
  State<ManageProfile> createState() => _ManageProfileState();
}

class _ManageProfileState extends State<ManageProfile> {
  final authService = AuthService();
  final String userId = Supabase.instance.client.auth.currentUser!.id;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  void _saveEntry() async {
    final ManageProfile = {
      'id': userId,
      "name": nameController.text,
      'phone_number': phoneNumberController.text,
      'age': ageController.text,
      'baby_birthdate': birthDateController.text,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .update(ManageProfile)
          .eq('id', userId);

      if (response != null) {
        throw Exception('Insert failed');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully updated!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving entry: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Set the email from Supabase user
    emailController.text =
        Supabase.instance.client.auth.currentUser?.email ?? '';
  }

  Future<void> _loadProfile() async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    if (response != null) {
      setState(() {
        nameController.text = response['name'] ?? '';
        phoneNumberController.text = response['phone_number'] ?? '';
        ageController.text = response['age']?.toString() ?? '';
        birthDateController.text = response['baby_birthdate'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
            icon: Icon(Icons.arrow_back_ios_new_outlined)),
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
                    "Manage Profile",
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
                          Text('Email:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Raleway")),
                          Container(
                            width: 255,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: TextField(
                                  controller: emailController,
                                  readOnly: true,
                                  decoration: InputDecoration(
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
                          Text('Phone Number:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Raleway")),
                          Container(
                            width: 200,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: TextField(
                                  controller: phoneNumberController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter phone number',
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
                          Text('Age:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Raleway")),
                          Container(
                            width: 200,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: TextField(
                                  controller: ageController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter age',
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
                          Text("Baby's Birth Date:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Raleway")),
                          Container(
                            width: 200,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: TextField(
                                  controller: birthDateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: 'Enter birth date',
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
    );
  }
}
