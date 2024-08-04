import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp_/main.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late bool isSignIn;
  bool isFormInteracted = false;
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool agreedToTerms = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    isSignIn = true; // Initially, set it to sign in
  }

  String? validateEmail(String? value) {
    if (isFormInteracted && (value == null || value.isEmpty)) {
      return 'Please enter your email';
    }

    if (value != null && !value.isEmpty) {
      // Custom email format validation
      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (!isSignIn && isFormInteracted) {
      // Only validate during registration
      if (value == null || value.isEmpty) {
        return 'Please enter your password';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters long';
      }
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (!isSignIn) {
      // Only validate during registration
      if (isFormInteracted &&
          (value == null || value.isEmpty || value.length < 6)) {
        return 'Password must be at least 6 characters long';
      }
      if (value != null && value != passwordController.text) {
        return 'Passwords do not match';
      }
    }
    return null;
  }

  void switchAuthMode() {
    setState(() {
      isSignIn = !isSignIn;
      // Clear text controllers when switching modes
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      isFormInteracted = false;
    });
  }

  Future<void> _submitForm() async {
    setState(() {
      isFormInteracted = true;
    });

    try {
      // Validation check before submission
      if ((validateEmail(emailController.text) != null ||
          validatePassword(passwordController.text) != null ||
          (isSignIn &&
              validateConfirmPassword(confirmPasswordController.text) !=
                  null))) {
        // Validation failed
        return;
      }

      if (!isSignIn && !agreedToTerms) {
        // Display an error message if terms are not agreed, but only for registration
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please agree to the terms and conditions.',
              style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold,
                color: Color(0xFF27bc5c),
                fontSize: 15,
              ),
            ),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Additional check for registration to validate confirm password
      if (validatePassword(passwordController.text) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password must be at least 6 characters long',
              style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold,
                color: Color(0xFF27bc5c),
                fontSize: 15,
              ),
            ),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      if (validatePassword(confirmPasswordController.text) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password must be at least 6 characters long',
              style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold,
                color: Color(0xFF27bc5c),
                fontSize: 15,
              ),
            ),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Additional check for registration to validate confirm password
      if (!isSignIn &&
          isFormInteracted &&
          (confirmPasswordController.text.isEmpty ||
              confirmPasswordController.text != passwordController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Passwords do not match',
              style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 230, 15, 0),
                fontSize: 15,
              ),
            ),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      setState(() {
        isLoading = true; // Set loading state
      });

      if (isSignIn) {
        // Sign in logic
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        // Register logic
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      }

      // If successful, reset form interaction state and navigate to the main app
      setState(() {
        isFormInteracted = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return MyApp(
            userEmail: FirebaseAuth.instance.currentUser!.email!,
          );
        }),
      );
    } on FirebaseAuthException catch (error) {
      // Handle specific authentication errors
      String errorMessage =
          'Authentication failed. please enter correct email or password';

      if (error.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      } else if (error.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      }

      // Display error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 230, 15, 0),
          content: Text(
            errorMessage,
            style: GoogleFonts.kanit(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 228, 224, 224),
              fontSize: 15,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );

      print("Authentication failed: $error");
    } catch (error) {
      // Handle other errors (e.g., display a generic error message to the user)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred. Please try again later.',
            style: GoogleFonts.kanit(
              fontWeight: FontWeight.bold,
              color: Color(0xFF27bc5c),
              fontSize: 15,
            ),
          ),
          duration: Duration(seconds: 2),
        ),
      );

      print("Authentication failed: $error");
    } finally {
      setState(() {
        isLoading = false; // Reset loading state
      });
    }
  }

  Widget buildSimpleTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    required String? Function(String?)? validator,
    required bool showPassword,
    required VoidCallback onTogglePassword,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !showPassword : false,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            TextStyle(color: Colors.white), // Set the hint text color to white
        prefixIcon:
            Icon(icon, color: Colors.white), // Set the icon color to white
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        errorText: validator != null ? validator(controller.text) : null,
      ),
    );
  }

  Widget buildAgreementCheckbox() {
    return Row(
      children: [
        Checkbox(
          checkColor: Colors.white,
          activeColor: Colors.green,
          value: agreedToTerms,
          onChanged: (value) {
            setState(() {
              agreedToTerms = value ?? false;
            });
          },
        ),
        Text(
          'I agree to the terms and conditions',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0c091c),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/Login1.png',
                height: 300,
                width: 300,
              ),
              Theme(
                data: ThemeData(hintColor: Colors.white),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: emailController,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    fillColor: Colors.white,
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.email, color: Colors.white),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    errorText: validateEmail(emailController.text),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                style: TextStyle(color: Colors.white),
                controller: passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  errorText: validatePassword(passwordController.text),
                ),
              ),
              if (!isSignIn) const SizedBox(height: 25),
              if (!isSignIn)
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.lock, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          showConfirmPassword = !showConfirmPassword;
                        });
                      },
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    errorText:
                        validateConfirmPassword(confirmPasswordController.text),
                  ),
                ),
              const SizedBox(height: 20),
              if (!isSignIn) buildAgreementCheckbox(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  // primary: Color(0xFF27bc5c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Container(
                  height: 50,
                  child: Center(
                    child: isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF27bc5c)),
                          )
                        : Text(
                            isSignIn ? 'Sign In' : 'Register',
                            style: TextStyle(
                                fontSize: 18, color: Color(0xFFFFFFFF)),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: switchAuthMode,
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isSignIn
                                ? "Don't have an account?"
                                : 'Already have an account?',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            isSignIn ? 'Register here.' : 'Sign in here.',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
