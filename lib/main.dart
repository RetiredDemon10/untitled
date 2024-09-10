import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'RegistrationPage.dart'; // Import the registration screen
import 'reminder_setup_page.dart'; // Import the ReminderSetupPage
import 'package:flutter_svg/flutter_svg.dart'; // Add this if using SVG icons

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediKen Health Reminder System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false, // Disable the debug banner
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isPasswordVisible =
      false; // State variable to toggle password visibility

  void login() async {
    if (!_formKey.currentState!.validate()) {
      // If the form is not valid, display validation errors
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Simulate a network call with a delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    // Navigate to ReminderSetupPage after successful login
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReminderSetupPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MediKen Health Reminder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Welcome to MediKen HRS',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextFormField(
                  obscureText: !_isPasswordVisible, // Toggle visibility
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Password must be at least 6 characters long.';
                    }
                    return null;
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement forgot password functionality
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
                child: const Text('Forgot Password'),
              ),
              Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Login'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Haven't registered?"),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrationPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Or login with',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SocialMediaButton(
                    iconPath: 'assets/images/gmail_logo.svg',
                    onPressed: () {
                      // TODO: Implement Gmail login
                    },
                  ),
                  const SizedBox(width: 20),
                  SocialMediaButton(
                    iconPath: 'assets/images/facebook_logo.svg',
                    onPressed: () {
                      // TODO: Implement Facebook login
                    },
                  ),
                  const SizedBox(width: 20),
                  SocialMediaButton(
                    iconPath: 'assets/images/linkedin_logo.svg',
                    onPressed: () {
                      // TODO: Implement LinkedIn login
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SocialMediaButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;

  const SocialMediaButton({
    super.key,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
