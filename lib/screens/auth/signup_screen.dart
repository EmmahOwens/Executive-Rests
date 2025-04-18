import 'package:provider/provider.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_container.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _userType = 'tenant'; // Default to tenant
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      // Check if passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Passwords do not match';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        userType: _userType,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (_userType == 'tenant') {
          Navigator.of(context).pushReplacementNamed('/tenant-dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/landlord-dashboard');
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to create account. Email may already be in use.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A8A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
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
                  "Create Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Sign up to get started",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                
                // User type selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: NeumorphicRadio(
                        style: NeumorphicRadioStyle(
                          selectedDepth: -4,
                          unselectedDepth: 4,
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                        ),
                        groupValue: _userType,
                        value: 'tenant',
                        onChanged: (value) {
                          setState(() {
                            _userType = value.toString();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Tenant',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: _userType == 'tenant' ? FontWeight.bold : FontWeight.normal,
                              color: _userType == 'tenant' ? const Color(0xFF1E3A8A) : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: NeumorphicRadio(
                        style: NeumorphicRadioStyle(
                          selectedDepth: -4,
                          unselectedDepth: 4,
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                        ),
                        groupValue: _userType,
                        value: 'landlord',
                        onChanged: (value) {
                          setState(() {
                            _userType = value.toString();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Landlord',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: _userType == 'landlord' ? FontWeight.bold : FontWeight.normal,
                              color: _userType == 'landlord' ? const Color(0xFF1E3A8A) : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Signup form with glass effect
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
                          // Name field
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
                              controller: _nameController,
                              decoration: const InputDecoration(
                                hintText: 'Full Name',
                                prefixIcon: Icon(Icons.person_outline),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 20,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          
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
                          const SizedBox(height: 15),
                          
                          // Phone field
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
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_outlined),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 20,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          
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
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          
                          // Confirm Password field
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
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
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
                                  return 'Please confirm your password';
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
                          
                          const SizedBox(height: 25),
                          
                          // Signup button
                          NeumorphicButton(
                            style: NeumorphicStyle(
                              depth: 5,
                              intensity: 0.8,
                              color: const Color(0xFF1E3A8A),
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _signup,
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
                                      'Create Account',
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
                const SizedBox(height: 20),
                
                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Sign In',
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