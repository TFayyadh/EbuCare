import 'package:ebucare_app/auth/auth_service.dart';
import 'package:ebucare_app/pages/forgot_password_page.dart';
import 'package:ebucare_app/pages/register_page.dart';
import 'package:ebucare_app/pages/start_decider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _passwordVisible = false;

  void login() async {
    final email = emailController.text;
    final password = passwordController.text;

    try {
      await authService.signInWithEmailPassword(email, password);

      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id;

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const StartDecider()),
          (route) => false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

//BUILD UI
  @override
  void initState() {
    _passwordVisible = false;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 226, 226),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    controller: emailController,
                    style: TextStyle(
                        fontFamily: "Raleway", fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                          fontFamily: "Raleway", fontWeight: FontWeight.bold),
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
                          fontFamily: "Raleway", fontWeight: FontWeight.bold),
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
                ],
              ),
              SizedBox(
                height: 20,
              ),
              //Forgot Password?

              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SizedBox(
                  width: 350,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 205, 222, 158)),
                    onPressed: login,
                    child: Text("Login",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: "Raleway",
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: SizedBox(
                  width: double.maxFinite,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: Text("Forgot Password? ",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Calsans",
                            fontSize: 14,
                            fontWeight: FontWeight.w200)),
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
                            builder: (context) => const RegisterPage()),
                      );
                    },
                    child: Text(
                        "Don't have an account yet? Click here to sign up.",
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
