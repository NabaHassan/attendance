import 'package:attendance/bloc/auth__bloc.dart';
import 'package:attendance/bloc/auth_event.dart';
import 'package:attendance/bloc/auth_state.dart';
import 'package:attendance/consts/constants.dart';
import 'package:attendance/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    // Reusable labeled field builder
    Widget buildField({
      required String label,
      required TextEditingController controller,
      String? hint,
      IconData? prefixIcon,
      bool obscure = false,
      Widget? suffix,
      TextInputType keyboardType = TextInputType.text,
      TextInputAction textInputAction = TextInputAction.next,
      String? Function(String?)? validator,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: sw / 26),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            textInputAction: textInputAction,
            decoration: InputDecoration(
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: Constants.primary)
                  : null,
              hintText: hint,
              hintStyle: TextStyle(color: Constants.muted, fontSize: sw / 28),
              filled: true,
              fillColor: Colors.grey[50],
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: validator,
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Constants.background,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AuthError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Constants.error,
                ),
              );
            });
          }
          if (state is Authenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Verify your email to login")),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            });
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Container(
                    height: sh * 0.32,
                    width: double.infinity,
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
                        Icons.app_registration,
                        color: Colors.white,
                        size: sw * 0.20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

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
                          'Create an account',
                          style: TextStyle(
                            fontSize: sw / 26,
                            color: Constants.muted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                    child: Form(
                      key: _formKey,
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
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

                              // Full name
                              buildField(
                                label: 'Full name',
                                controller: _nameController,
                                hint: 'e.g. John Doe',
                                prefixIcon: Icons.person,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Email
                              buildField(
                                label: 'Email',
                                controller: _emailController,
                                hint: 'you@example.com',
                                prefixIcon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  ).hasMatch(v)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Password
                              buildField(
                                label: 'Password',
                                controller: _passwordController,
                                hint: 'Create a password',
                                prefixIcon: Icons.lock,
                                obscure: _obscurePassword,
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
                                    return 'Please enter a password';
                                  }
                                  if (v.length < 4) return 'Password too short';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Confirm password
                              buildField(
                                label: 'Confirm password',
                                controller: _confirmController,
                                hint: 'Re-enter password',
                                prefixIcon: Icons.lock,
                                obscure: _obscureConfirm,
                                textInputAction: TextInputAction.done,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Constants.muted,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (v != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Accept terms
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _acceptTerms,
                                      onChanged: (v) => setState(
                                        () => _acceptTerms = v ?? false,
                                      ),
                                      activeColor: Constants.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(
                                        () => _acceptTerms = !_acceptTerms,
                                      ),
                                      child: Text(
                                        'I agree to the Terms & Conditions',
                                        style: TextStyle(
                                          color: Constants.muted,
                                          fontSize: sw / 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final isValid =
                                        _formKey.currentState?.validate() ??
                                        false;
                                    if (!isValid) {
                                      return;
                                    }
                                    if (!_acceptTerms) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please accept the terms to continue',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    final pass = _passwordController.text
                                        .trim();
                                    final email = _emailController.text.trim();
                                    final employeeName = _nameController.text;

                                    context.read<AuthBloc>().add(
                                      SignUpRequested(
                                        email,
                                        pass,
                                        employeeName,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Constants.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                  ),
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: TextStyle(color: Constants.muted),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Sign In',
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
