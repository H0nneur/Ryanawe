import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryanawe/screens/home_screen.dart';
import 'package:ryanawe/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordCheckController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordCheckController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ryanǎwe")),
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Sign up",
                style: TextStyle(
                    fontSize: 35,
                    color: Colors.indigo.shade900,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              labelText: "Email", border: OutlineInputBorder()),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your email';
                            }
                            return null;
                          }),
                      const SizedBox(height: 10),
                      TextFormField(
                          controller: _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          decoration: const InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder()),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your password';
                            }
                            return null;
                          }),
                      const SizedBox(height: 10),
                      TextFormField(
                          controller: _passwordCheckController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          decoration: const InputDecoration(
                              labelText: "Confirm password",
                              border: OutlineInputBorder()),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please confirm your password';
                            }
                            if (_passwordController.text != value) {
                              return 'Please match with the entered password';
                            }
                            return null;
                          }),
                      const SizedBox(height: 10),
                      MaterialButton(
                          minWidth: double.infinity,
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final success =
                                  await context.read<AuthService>().signUp(
                                        _emailController.text,
                                        _passwordController.text,
                                      );
                              if (success) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const HomeScreen()));
                              }
                            }
                          },
                          color: Colors.indigo.shade900,
                          textColor: Colors.white,
                          child: const Text("Sign Up"))
                    ],
                  ),
                ),
              )
            ]),
      ),
    );
  }
}
