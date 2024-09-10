import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationState createState() => RegistrationState();
}

class RegistrationState extends State<RegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void register() async {
    if (!_formKey.currentState!.validate()) {
      // If the form is not valid, display validation errors
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Register with Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Save additional user info (e.g., name, age, phone) to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': nameController.text,
        'age': int.parse(ageController.text),
        'phone': phoneController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      // Navigate to another page if needed
      // Navigator.pushReplacementNamed(context, '/home'); // Example navigation
    } on FirebaseAuthException catch (e) {
      // Handle registration errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                  'Create Your MediKen Account',
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
                    labelText: 'Full Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name.';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: emailController,
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
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible, // Toggle visibility
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
              Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible, // Toggle visibility
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Age',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age.';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age <= 0) {
                      return 'Please enter a valid age.';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone Number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number.';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid phone number.';
                    }
                    return null;
                  },
                ),
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
                  onPressed: isLoading ? null : register,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
