import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void loginUser() async {
    try {
      if (!Hive.isBoxOpen('users')) {
        await Hive.openBox('users');
      }
      if (!Hive.isBoxOpen('currentUser')) {
        await Hive.openBox('currentUser');
      }

      var usersBox = Hive.box('users');
      var sessionBox = Hive.box('currentUser');

      String username = usernameController.text.trim();
      String password = passwordController.text.trim();

      if (username.isEmpty || password.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter username and password")),
          );
        }
        return;
      }

      if (usersBox.containsKey(username)) {
        final dynamic userData = usersBox.get(username);

        if (userData is Map && userData['password'] == password) {
          await sessionBox.put('username', username);

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/Home');
          }
        } else if (userData is Map) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Wrong password")),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Corrupted user data. Please re-register.")),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User not found")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: loginUser, child: const Text("Login")),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/Sign'),
              child: const Text("Don’t have an account? Signup"),
            ),
          ],
        ),
      ),
    );
  }
}
