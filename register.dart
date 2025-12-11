

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// // Import your Login Page
// import 'login.dart';

// // Global Supabase client
// final supabase = Supabase.instance.client;

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();

//   bool isLoading = false;

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     phoneController.dispose();
//     addressController.dispose();
//     super.dispose();
//   }

//   // ---------------------------
//   // ⭐ SUPABASE REGISTER USER
//   // ---------------------------
//   Future<void> registerUser() async {
//     if (nameController.text.isEmpty ||
//         emailController.text.isEmpty ||
//         passwordController.text.isEmpty ||
//         phoneController.text.isEmpty ||
//         addressController.text.isEmpty) {
//       _showMessage("Please fill in all fields.");
//       return;
//     }

//     if (passwordController.text.length < 6) {
//       _showMessage("Password must be at least 6 characters long.");
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       // Create auth user
//       final AuthResponse response = await supabase.auth.signUp(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );

//       if (response.user == null) {
//         throw const AuthException("Registration failed: user is null.");
//       }

//       final uid = response.user!.id;

//       // Insert user profile in "users" table
//       await supabase.from('users').insert({
//         "id": uid,
//         "name": nameController.text.trim(),
//         "email": emailController.text.trim(),
//         "phone": phoneController.text.trim(),
//         "address": addressController.text.trim(),
//         "created_at": DateTime.now().toIso8601String(),
//       });

//       _showMessage("Registration successful! Please log in.");

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//     } on AuthException catch (e) {
//       _showMessage(e.message);
//     } catch (e) {
//       _showMessage("An error occurred: $e");
//     }

//     setState(() => isLoading = false);
//   }

//   // Snackbar message
//   void _showMessage(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   // Reusable input field widget
//   Widget _inputField(String label, String hint,
//       {bool isPassword = false,
//       TextInputType input = TextInputType.text,
//       required TextEditingController controller}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label,
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           TextField(
//             controller: controller,
//             obscureText: isPassword,
//             keyboardType: input,
//             decoration: InputDecoration(
//               hintText: hint,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(100),
//                 borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(100),
//                 borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(100),
//                 borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
//               ),
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   // ---------------------------
//   // ⭐ UI BUILD
//   // ---------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 40),

//             // Back Button
//             InkWell(
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 padding: const EdgeInsets.all(8.0),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.grey.shade300, width: 1),
//                 ),
//                 child: const Icon(
//                   Icons.arrow_back_ios_new,
//                   color: Colors.black,
//                   size: 20,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 40),

//             const Text(
//               "Join with EcoClan",
//               style: TextStyle(
//                 fontSize: 32,
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Sign up now and start your journey to make the world greener",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontFamily: 'Poppins',
//                 color: Colors.grey.shade600,
//               ),
//             ),

//             const SizedBox(height: 32),

//             // INPUT FIELDS
//             _inputField("Name", "Full name", controller: nameController),
//             _inputField("Email", "example@gmail.com",
//                 controller: emailController,
//                 input: TextInputType.emailAddress),
//             _inputField("Password", "Enter password",
//                 isPassword: true, controller: passwordController),
//             _inputField("Mobile Number", "0912*******",
//                 controller: phoneController, input: TextInputType.phone),
//             _inputField("Address", "Street address, City",
//                 controller: addressController,
//                 input: TextInputType.streetAddress),

//             const SizedBox(height: 30),

//             // REGISTER BUTTON
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: isLoading ? null : registerUser,
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: Colors.white,
//                   backgroundColor: const Color(0xFF0D47A1),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(100),
//                   ),
//                 ),
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         "Register",
//                         style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
//                       ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text("Already have an account?",
//                     style: TextStyle(color: Colors.grey.shade700)),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (c) => const LoginPage(),
//                       ),
//                     );
//                   },
//                   child: const Text(
//                     "Login here",
//                     style: TextStyle(
//                         color: Color(0xFF0D47A1),
//                         fontWeight: FontWeight.bold),
//                   ),
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

final supabase = Supabase.instance.client;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // --------------------------------
  // ⭐ ENHANCED SUPABASE REGISTER
  // --------------------------------
  Future<void> registerUser() async {
    if (_isFormInvalid()) return;

    setState(() => isLoading = true);

    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user == null) {
        _showMessage("Registration failed. Try again.");
        return;
      }

      final uid = response.user!.id;

      await supabase.from('users').insert({
        "id": uid,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "address": addressController.text.trim(),
        "created_at": DateTime.now().toIso8601String(),
      });

      _showMessage("Registration successful! Please log in.");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );

    } on AuthException catch (e) {
      _handleAuthError(e.message);
    } catch (e) {
      _showMessage("Something went wrong. Please try again.");
      debugPrint("REGISTRATION ERROR: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // Validate fields
  bool _isFormInvalid() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty) {
      _showMessage("Please fill in all fields.");
      return true;
    }

    if (passwordController.text.length < 6) {
      _showMessage("Password must be at least 6 characters.");
      return true;
    }

    if (!emailController.text.contains("@")) {
      _showMessage("Enter a valid email address.");
      return true;
    }

    return false;
  }

  // Supabase-specific error messages
  void _handleAuthError(String msg) {
    if (msg.contains("already registered")) {
      _showMessage("This email is already registered.");
    } else if (msg.contains("rate limit")) {
      _showMessage("Too many attempts. Try again later.");
    } else {
      _showMessage(msg);
    }
  }

  // Snackbar
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // -----------------------------
  // Reusable Input Field
  // -----------------------------
  Widget _inputField(
    String label,
    String hint, {
    bool isPassword = false,
    TextInputType input = TextInputType.text,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: input,
            style: const TextStyle(fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: const BorderSide(color: Color(0xFF0D47A1)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // ⭐ UI BUILD
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Join with EcoClan",
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign up now and start your journey to make the world greener!",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 30),

              _inputField("Name", "Full name", controller: nameController),
              _inputField("Email", "example@gmail.com",
                  input: TextInputType.emailAddress,
                  controller: emailController),
              _inputField("Password", "Enter password",
                  isPassword: true, controller: passwordController),
              _inputField("Mobile Number", "0912*******",
                  input: TextInputType.phone, controller: phoneController),
              _inputField("Address", "Street address, City",
                  input: TextInputType.streetAddress,
                  controller: addressController),

              const SizedBox(height: 30),

              // Register button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Register",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?",
                        style: TextStyle(color: Colors.grey.shade700)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login here",
                        style: TextStyle(
                            color: Color(0xFF0D47A1),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
