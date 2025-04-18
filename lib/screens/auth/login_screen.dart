import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (authService.currentUser?.userType == 'tenant') {
          Navigator.of(context).pushReplacementNamed('/tenant-dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/landlord-dashboard');
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: size.height - MediaQuery.of(context).padding.top,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo and title
                Center(
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      depth: 8,
                      intensity: 0.7,
                      shape: NeumorphicShape.concave,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(20),
                      ),
                      color: const Color(0xFFF0F4F8),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: const Text(
                        "ER",
                        style: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Executive Rests",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Sign in to your account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                // Login form with glass effect
                GlassContainer(
                  borderRadius: BorderRadius.circular(20),
                  blur: 10,
                  opacity: 0.2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email field
                          Neumorphic(
                            style: NeumorphicStyle(
                              depth: -3,
                              intensity: 0.7,
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(12),
                              ),
                              color: Colors.white.withOpacity(0.8),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 20,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Password field
                          Neumorphic(
                            style: NeumorphicStyle(
                              depth: -3,
                              intensity: 0.7,
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(12),
                              ),
                              color: Colors.white.withOpacity(0.8),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 20,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (_errorMessage != null) ...[  
                            const SizedBox(height: 10),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          // Forgot password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Navigate to forgot password screen
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Login button
                          NeumorphicButton(
                            style: NeumorphicStyle(
                              depth: 5,
                              intensity: 0.8,
                              color: const Color(0xFF1E3A8A),
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/signup');
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
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
    );
  }
}