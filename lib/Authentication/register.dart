import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalController = TextEditingController();

  void _signup() async {
    try {
      if (!Hive.isBoxOpen('users')) {
        await Hive.openBox('users');
      }
      var box = Hive.box('users');
      String username = _usernameController.text.trim();
      String password = _passwordController.text.trim();

      if (username.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username and Password cannot be empty")),
        );
        return;
      }

      int age = int.tryParse(_ageController.text) ?? 0;
      int weight = int.tryParse(_weightController.text) ?? 0;
      int goal = int.tryParse(_goalController.text) ?? 0;

      if (!box.containsKey(username)) {
        await box.put(username, {
          'password': password,
          'age': age,
          'weight': weight,
          'goal': goal,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful!")),
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/Login');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User already exists!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: "Weight"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _goalController,
                decoration: const InputDecoration(labelText: "Goal (e.g., target weight)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signup,
                child: const Text("Sign Up"),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/Login'),
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
