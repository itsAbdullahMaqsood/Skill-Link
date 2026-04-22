import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skilllink/Pages/login/login_page.dart';
import 'package:skilllink/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _pastExperienceController = TextEditingController();
  final TextEditingController _portfolioLinkController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _selectedGender;
  List<String> _offeringSkills = [];
  final TextEditingController _skillController = TextEditingController();
  List<String> _learningSkills = [];
  final TextEditingController _learningSkillController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _phoneNumberController.dispose();
    _educationController.dispose();
    _pastExperienceController.dispose();
    _portfolioLinkController.dispose();
    _skillController.dispose();
    _learningSkillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    if (_skillController.text.trim().isNotEmpty) {
      setState(() {
        _offeringSkills.add(_skillController.text.trim());
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _offeringSkills.remove(skill);
    });
  }

  void _addLearningSkill() {
    if (_learningSkillController.text.trim().isNotEmpty) {
      setState(() {
        _learningSkills.add(_learningSkillController.text.trim());
        _learningSkillController.clear();
      });
    }
  }

  void _removeLearningSkill(String skill) {
    setState(() {
      _learningSkills.remove(skill);
    });
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.signup(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      age: _ageController.text.trim().isEmpty
          ? null
          : int.tryParse(_ageController.text.trim()),
      gender: _selectedGender,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim().isEmpty
          ? null
          : _phoneNumberController.text.trim(),
      education: _educationController.text.trim().isEmpty
          ? null
          : _educationController.text.trim(),
      offeringSkills: _offeringSkills.isEmpty ? null : _offeringSkills,
      learningSkills: _learningSkills.isEmpty ? null : _learningSkills,
      pastExperience: _pastExperienceController.text.trim().isEmpty
          ? null
          : _pastExperienceController.text.trim(),
      portfolioLink: _portfolioLinkController.text.trim().isEmpty
          ? null
          : _portfolioLinkController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Signup failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade500,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SvgPicture.asset(
                'assets/images/Vector.svg',
                width: 30,
                height: 30,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Skill Link",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Create Your Account",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Join the global network of skill sharing and start exchanging skills today.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.grey.shade700,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),

                        const SizedBox(height: 10),

                        const Center(
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text("Full Name *"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            hintText: "Enter your full name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Full name is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        const Text("Email Address *"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Enter your email",
                            suffixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        const Text("Password *"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: "Create a password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        const Text("Confirm Password *"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: "Confirm your password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        const Text("Phone Number"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "+1234567890",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text("Age"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "28",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text("Gender"),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: ['male', 'female', 'other']
                              .map((gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender.toUpperCase()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        const Text("Location"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            hintText: "New York, USA",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text("Bio"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _bioController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Tell us about yourself",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text("Education"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _educationController,
                          decoration: InputDecoration(
                            hintText: "Bachelor of Science in Computer Science",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text("Past Experience"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _pastExperienceController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: "5 years as Full Stack Developer",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text("Portfolio Link"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _portfolioLinkController,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            hintText: "https://portfolio.example.com",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text("Offering Skills"),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _skillController,
                                decoration: InputDecoration(
                                  hintText: "Add a skill",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onFieldSubmitted: (_) => _addSkill(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addSkill,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.blue.shade100,
                              ),
                            ),
                          ],
                        ),
                        if (_offeringSkills.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _offeringSkills.map((skill) {
                              return Chip(
                                label: Text(skill),
                                onDeleted: () => _removeSkill(skill),
                                deleteIcon: const Icon(Icons.close, size: 18),
                              );
                            }).toList(),
                          ),
                        ],

                        const SizedBox(height: 16),

                        const Text("Learning Skills"),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _learningSkillController,
                                decoration: InputDecoration(
                                  hintText: "Add a skill you want to learn",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onFieldSubmitted: (_) => _addLearningSkill(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addLearningSkill,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.green.shade100,
                              ),
                            ),
                          ],
                        ),
                        if (_learningSkills.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _learningSkills.map((skill) {
                              return Chip(
                                label: Text(skill),
                                onDeleted: () => _removeLearningSkill(skill),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                backgroundColor: Colors.green.shade50,
                                deleteIconColor: Colors.green.shade700,
                              );
                            }).toList(),
                          ),
                        ],

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _handleSignup,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Sign Up →",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text("Already have an account? Login"),
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Center(
                          child: Text(
                            "© 2024 Skill Link. All rights reserved.",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
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
  }
}
