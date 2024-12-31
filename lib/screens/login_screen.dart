import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryanawe/screens/home_screen.dart';
import 'package:ryanawe/screens/sign_up_screen.dart';
import 'package:ryanawe/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ryanǎwe"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Login",
                style: TextStyle(
                    fontSize: 35,
                    color: Colors.indigo.shade900,
                    fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                          labelText: 'Password', border: OutlineInputBorder()),
                      obscureText: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    MaterialButton(
                        minWidth: double.infinity,
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final success =
                                await context.read<AuthService>().signIn(
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                            if (success) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeScreen()));
                            }
                          }
                        },
                        color: Colors.indigo.shade900,
                        textColor: Colors.white,
                        child: const Text("Login")),
                    const SizedBox(height: 50),
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: <TextSpan>[
                          const TextSpan(
                              text: "You don't have an account yet? \n",
                              style: TextStyle(color: Colors.black)),
                          TextSpan(
                              text: "Sign up here",
                              style: const TextStyle(color: Colors.indigo),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignUpScreen()));
                                }),
                        ]))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
