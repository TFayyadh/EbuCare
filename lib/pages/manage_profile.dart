import 'package:ebucare_app/auth/auth_service.dart';
import 'package:ebucare_app/pages/home_page.dart';
import 'package:ebucare_app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageProfile extends StatefulWidget {
  final int initialIndex;
  const ManageProfile({super.key, this.initialIndex = 1});

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

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    emailController.text =
        Supabase.instance.client.auth.currentUser?.email ?? '';
    _loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    ageController.dispose();
    emailController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      if (!mounted) return;

      setState(() {
        nameController.text = response['name'] ?? '';
        phoneNumberController.text = response['phone_number'] ?? '';
        ageController.text = response['age']?.toString() ?? '';
        birthDateController.text = response['baby_birthdate'] ?? '';
      });
    } catch (e) {
      // optional snackbar
    }
  }

  void _saveEntry() async {
    final payload = {
      "name": nameController.text.trim(),
      "phone_number": phoneNumberController.text.trim(),
      "age": ageController.text.trim(),
      "baby_birthdate": birthDateController.text.trim(),
      "updated_at": DateTime.now().toIso8601String(),
    };

    try {
      await Supabase.instance.client
          .from('profiles')
          .update(payload)
          .eq('id', userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully updated!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving entry: $e')),
      );
    }
  }

  Future<void> logout() async {
    try {
      await authService.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    DateTime initial = now;

    // if already has value yyyy-MM-dd, parse it
    try {
      if (birthDateController.text.isNotEmpty) {
        initial = DateTime.parse(birthDateController.text);
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() {
        birthDateController.text = "$y-$m-$d";
      });
    }
  }

  InputDecoration _dec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54, fontFamily: "Raleway"),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: "Raleway",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 226, 226),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 247, 226, 226),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Manage Profile",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Calsans",
                  color: Color.fromARGB(255, 106, 63, 114),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // ✅ Column layout (no overflow)
                    _fieldLabel("Full Name"),
                    TextField(
                      controller: nameController,
                      decoration: _dec("Enter full name"),
                      style: const TextStyle(fontFamily: "Raleway"),
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel("Email"),
                    TextField(
                      controller: emailController,
                      readOnly: true,
                      decoration: _dec("Email"),
                      style: const TextStyle(fontFamily: "Raleway"),
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel("Phone Number"),
                    TextField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: _dec("Enter phone number"),
                      style: const TextStyle(fontFamily: "Raleway"),
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel("Age"),
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: _dec("Enter age"),
                      style: const TextStyle(fontFamily: "Raleway"),
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel("Baby's Birth Date"),
                    TextField(
                      controller: birthDateController,
                      readOnly: true,
                      onTap: _pickBirthDate,
                      decoration: _dec("Select birth date").copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range_outlined),
                          onPressed: _pickBirthDate,
                        ),
                      ),
                      style: const TextStyle(fontFamily: "Raleway"),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saveEntry,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 243, 229, 245),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontFamily: "Raleway",
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          setState(() => _selectedIndex = index);

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
              break;

            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ManageProfile(initialIndex: index),
                ),
              );
              break;

            case 2:
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await logout();
              }
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}
