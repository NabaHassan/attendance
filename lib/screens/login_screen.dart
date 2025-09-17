import 'package:attendance/bloc/auth__bloc.dart';
import 'package:attendance/bloc/auth_event.dart';
import 'package:attendance/bloc/auth_state.dart';
import 'package:attendance/consts/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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
    bool obscure = false,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: textInputAction,
      cursorColor: Constants.primary,
      decoration: InputDecoration(
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffix,
      ),
      validator:
          validator ??
          (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      width: sw,
      decoration: BoxDecoration(
        image: DecorationImage(
          repeat: ImageRepeat.repeat,
          image: AssetImage('assets/case-study-bg.jpg'),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is Authenticated) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool("rememberMe", _remember);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/attendance');
                }
              });
            }

            if (state is AuthError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  final snackBar = SnackBar(
                    content: Text(state.message),
                    backgroundColor: Constants.error,
                    duration: const Duration(seconds: 2),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              });
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Gradient header
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    child: Container(
                      height: sh / 5,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/Neusco-Logo.png"),
                        ),
                      ),
                    ),
                  ),
                ),

                // Login form
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(50),
                    ),

                    child: Container(
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Center(
                                    child: const Text(
                                      "Welcome Back",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: Text(
                                      "Enter your details below",
                                      style: TextStyle(
                                        color: Constants.secondaryText,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  _labeledField(
                                    label: "Email Address",
                                    controller: _employeeNameController,
                                    hint: "yourname@email.com",
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 14),
                                  _labeledField(
                                    label: "Password",
                                    controller: _passwordController,
                                    hint: "Enter your password",
                                    obscure: _obscurePassword,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Sign In button with gradient
                                  SizedBox(
                                    height: 50,
                                    width: sw / 1.2,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade700,
                                            Colors.purple.shade400,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (!(_formKey.currentState
                                                  ?.validate() ??
                                              false))
                                            return;

                                          final id = _employeeNameController
                                              .text
                                              .trim();
                                          final password =
                                              _passwordController.text;

                                          try {
                                            // 🚀 Trigger sign in via Bloc
                                            context.read<AuthBloc>().add(
                                              SignInRequested(id, password),
                                            );
                                          } catch (e) {
                                            // ⚠️ Handle any Firebase errors with persistence
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Something went wrong. Try again.",
                                                ),
                                                backgroundColor:
                                                    Constants.error,
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "Sign In",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: _remember,

                                        onChanged: (value) {
                                          setState(() {
                                            _remember = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        "Remember Me",
                                        style: TextStyle(
                                          color: Constants.muted,
                                          fontSize: sw / 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: sh / 9),
                              // Social login buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Constants.primary,
                                      border: Border.all(
                                        color: Constants
                                            .secondaryText, // mimic the outlined border
                                      ),
                                    ),
                                    height: sh / 15,
                                    width: sw / 1.2,
                                    child: GestureDetector(
                                      onTap: () {
                                        context.read<AuthBloc>().add(
                                          GoogleSignInRequested(),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Container(
                                              width: 50,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(60),
                                                color: Colors.white,
                                              ),
                                              child: const Center(
                                                child: FaIcon(
                                                  FontAwesomeIcons.google,
                                                  color: Colors.red,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Sign in with Google",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Dont have an account?",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/signUp');
                                    },
                                    child: Text(
                                      " Get Started",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue.shade700,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
