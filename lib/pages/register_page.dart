import 'package:ebucare_app/auth/auth_service.dart';
import 'package:ebucare_app/pages/login_page.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  void SignUp() async {
    final email = emailController.text;
    final name = nameController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords don't match.")));
      return;
    }

    try {
      await authService.signUpUser(
          email: email, password: password, name: name);

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  void initState() {
    _passwordVisible = false;
    _confirmPasswordVisible = false;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 233, 224),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/logo1transparent.png"),
                        fit: BoxFit.contain),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                        fontFamily: "Raleway", fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(
                          fontFamily: "Raleway", fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: emailController,
                    style: TextStyle(
                        fontFamily: "Raleway", fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                          fontFamily: "Raleway", fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: passwordController,
                    style: TextStyle(
                        fontFamily: "Raleway", fontWeight: FontWeight.bold),
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                          fontFamily: "Raleway", fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                        icon: Icon(_passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    style: TextStyle(
                        fontFamily: "Raleway", fontWeight: FontWeight.bold),
                    obscureText: !_confirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      labelStyle: TextStyle(
                          fontFamily: "Raleway", fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                        icon: Icon((_confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SizedBox(
                  width: 350,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(231, 108, 190, 0.757)),
                    onPressed: SignUp,
                    child: Text("Register",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: Text("Already have an account? Click here to login.",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Calsans",
                            fontSize: 14,
                            fontWeight: FontWeight.w200)),
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
