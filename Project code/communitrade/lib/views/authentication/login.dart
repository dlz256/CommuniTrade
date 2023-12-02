import 'package:firebase_auth/firebase_auth.dart';
// import 'package:communitrade/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'register.dart';
import '../../firebase_auth.dart';
import 'validator.dart';
import '../HomePage.dart';



class LoginView extends StatefulWidget {
  const LoginView({Key? key, required this.title, required this.firebaseApp}) : super(key: key);

  final String title;
  final FirebaseApp firebaseApp;

  @override
  State<LoginView> createState() => _LoginViewState();
}


class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  Future<void> _initializeFirebase() async {
    // FirebaseApp firebaseApp = await Firebase.initializeApp();
    User? user = FirebaseAuth.instanceFor(app: widget.firebaseApp).currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePageView(
            user: user,
            filter: "All"
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _emailTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Email"),
                        validator: (value) =>
                            Validator.validateEmail(email: value),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _passwordTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Password"),
                        obscureText: true,
                        validator: (value) =>
                            Validator.validatePassword(password: value),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () async {
                          try{
                          if (_formKey.currentState!.validate()) {
                            User? user =
                                await FireAuth.signInUsingEmailPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text,
                            );                          
                            if (user != null) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => HomePageView(user: user, filter:"All")),
                              );                           
                            } else {
                              print("THERE WAS AN ERROR!");
                              const AlertDialog(
                                  title: Text("Sign in failed!"));
                            }
                          }
                          }
                          catch (e){
                            showErrorSnackBar(context, 'An error occurred: $e');

                          }
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const RegisterView()),
                          );
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ));
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

void showErrorSnackBar(BuildContext context, String errorMessage) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        errorMessage,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    ),
  );
}