import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _loggedInUser; // Declare _loggedInUser as nullable

  bool _isLoading = false; // Track loading state for asynchronous operations

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true; // Set loading state while signing in
      });

      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleSignInAuthentication = await googleSignInAccount?.authentication;
      AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(authCredential);
      User? user = userCredential.user;
      if (user != null) {
        setState(() {
          _loggedInUser = user; // Assign non-null user to _loggedInUser
          _isLoading = false; // Reset loading state after successful sign-in
        });
        if (kDebugMode) {
          print('Name: ${user.displayName}\nEmail: ${user.email}');
        }
        _showSnackBar(context, 'Logged in as: ${user.displayName}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
      _showSnackBar(context, 'Failed to sign in with Google');
      setState(() {
        _isLoading = false; // Reset loading state after sign-in failure
      });
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _logout() {
    setState(() {
      _loggedInUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Show loading indicator while signing in
        ),
      );
    } else if (_loggedInUser == null) {
      // Show login UI if user is not logged in
      return Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 345),
                  child: Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              labelText: 'Email or Phone Number',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              labelText: 'Password',
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                // Implement forgot password functionality
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed('/main');
                            },
                            child: const Text('Login'),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.login),
                            label: const Text('Continue with Google'),
                            onPressed: () {
                              signInWithGoogle(context); // Pass context to signInWithGoogle
                            },
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text('Register'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      // Show profile UI if user is logged in
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Name: ${_loggedInUser!.displayName ?? "Unknown"}'), // Use null-aware operator to safely access properties
              Text('Email: ${_loggedInUser!.email ?? "Unknown"}'), // Use null-aware operator to safely access properties
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      );
    }
  }
}