import 'package:attendance/bloc/auth__bloc.dart';
import 'package:attendance/bloc/auth_event.dart';
import 'package:attendance/bloc/auth_state.dart';
import 'package:attendance/consts/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _remember = false;
  late SharedPreferences _preferences;

  @override
  void dispose() {
    _employeeNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _labeledField({
    required String label,
    required TextEditingController controller,
    String hint = '',
    Widget? prefix,
    Widget? suffix,
    bool obscure = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    final sw = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: sw / 26),
        ),
        const SizedBox(height: 8),
        TextFormField(
          cursorColor: Constants.primary,
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Constants.muted, fontSize: sw / 28),
            prefixIcon: prefix,
            suffixIcon: suffix,
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            labelStyle: TextStyle(color: Constants.muted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator:
              validator ??
              (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your $label'.toLowerCase();
                }
                return null;
              },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Constants.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is Authenticated) {
            _preferences = await SharedPreferences.getInstance();
            if (_remember) {
              await _preferences.setString(
                'employeeEmail',
                _employeeNameController.text.trim(),
              );
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/attendance');
            });
          }

          if (state is AuthError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final snackBar = SnackBar(
                content: Text(state.message),
                backgroundColor: Constants.error,
                duration: const Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            });
          }
        },

        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Top graphic
                  Container(
                    height: sh * 0.32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Constants.primary,
                          Constants.primary.withOpacity(0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(70),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: sw * 0.20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: sw / 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: sw / 26,
                            color: Constants.muted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Form card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                    child: Form(
                      key: _formKey,
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),

                              // Employee ID (refactored)
                              _labeledField(
                                label: 'Employee Email',
                                controller: _employeeNameController,
                                hint: 'e.g. 123@example.com',

                                prefix: Icon(
                                  Icons.badge,
                                  color: Constants.primary,
                                ),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Please enter your employee ID';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // Password (refactored)
                              _labeledField(
                                label: 'Password',
                                controller: _passwordController,
                                hint: 'Enter your password',
                                prefix: Icon(
                                  Icons.lock,
                                  color: Constants.primary,
                                ),
                                obscure: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Constants.muted,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (v.length < 4) {
                                    return 'Password too short';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: _remember,
                                            onChanged: (v) => setState(() {
                                              _remember = v ?? false;
                                            }),
                                            activeColor: Constants.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => setState(
                                            () => _remember = !_remember,
                                          ),
                                          child: Text(
                                            'Remember me',
                                            style: TextStyle(
                                              color: Constants.muted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Forgot password not implemented',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Forgot?',
                                      style: TextStyle(color: Constants.muted),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Login button
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (!(_formKey.currentState?.validate() ??
                                        false)) {
                                      return;
                                    }
                                    final id = _employeeNameController.text
                                        .trim();
                                    final password = _passwordController.text;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 1),
                                        content: Text('Logging in as $id'),
                                      ),
                                    );
                                    context.read<AuthBloc>().add(
                                      SignInRequested(id, password),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Constants.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    // dispatch login event to AuthBloc
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Divider with text
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: Colors.grey[300]),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      'or continue with',
                                      style: TextStyle(
                                        color: Constants.muted,
                                        fontSize: sw / 36,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: Colors.grey[300]),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Social buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                            content: Text(
                                              'Logging in From Google...',
                                            ),
                                          ),
                                        );
                                        context.read<AuthBloc>().add(
                                          GoogleSignInRequested(),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.g_mobiledata,
                                        color: Constants.primary,
                                      ),
                                      label: Text(
                                        'Google',
                                        style: TextStyle(
                                          color: Constants.primary,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Apple sign-in not implemented',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.apple,
                                        color: Colors.black,
                                      ),
                                      label: Text(
                                        'Apple',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Footer: sign up
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Don\'t have an account?',
                                    style: TextStyle(color: Constants.muted),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/signUp');
                                    },
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Constants.primaryLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
