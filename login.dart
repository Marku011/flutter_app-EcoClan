// import 'package:flutter/material.dart';
// // 1. Supabase imports
// import 'package:supabase_flutter/supabase_flutter.dart';

// // Screens
// import 'package:EcoClan/screen/home.dart';
// import 'register.dart';
// import 'package:EcoClan/screens/welcome2.dart';
// // import 'reset.dart';

// // 2. Global Supabase instance (Assuming initialized in main.dart)
// final supabase = Supabase.instance.client;

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   // Controllers
//   final TextEditingController _emailController =
//       TextEditingController(text: 'user@gmail.com');
//   final TextEditingController _passwordController = TextEditingController();

//   bool isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   // -------------------------------
//   // ⭐ LOGIN FUNCTION WITH SUPABASE
//   // -------------------------------
//   Future<void> loginUser() async {
//     setState(() => isLoading = true);

//     try {
//       // 🟢 Supabase Login (replaces FirebaseAuth.signInWithEmailAndPassword)
//       final AuthResponse response = await supabase.auth.signInWithPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );

//       // Check if sign-in was successful
//       if (response.user == null) {
//         throw Exception("Sign in failed. No user object returned.");
//       }

//       final uid = response.user!.id;

//       // 🟢 Save login timestamp to Supabase PostgreSQL table (replaces Realtime DB)
//       // Assuming you have a 'users' table with 'id' (UUID) and 'last_login' (timestampz) columns
//       final DateTime now = DateTime.now().toUtc();
      
//       await supabase
//           .from('users')
//           .update({'last_login': now.toIso8601String()}) // Supabase prefers ISO 8601
//           .eq('id', uid)
//           .maybeSingle(); // Use maybeSingle for update operations

//       // Success → Go to Home Screen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const HomeScreen()),
//       );

//     } on AuthException catch (e) {
//       // Supabase handles errors with AuthException
//       String message = "Login failed";
      
//       // Supabase error messages are usually descriptive, but we can customize
//       // Note: Supabase intentionally gives generic login errors for security.
//       message = e.message;

//       _showMessage(message);
      
//     } catch (e) {
//       // Handle other potential errors (e.g., network, database update)
//       _showMessage(e.toString());
//     }

//     setState(() => isLoading = false);
//   }

//   // Show error dialog
//   void _showMessage(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Login Error"),
//         content: Text(message),
//         actions: [
//           TextButton(
//             child: const Text("OK"),
//             onPressed: () => Navigator.pop(context),
//           )
//         ],
//       ),
//     );
//   }

//   // ----------------------------------------------------
//   // ⭐ MAIN UI (No changes needed here)
//   // ----------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 40),

//             // Back Button
//             _buildBackButton(context),

//             const SizedBox(height: 30),

//             // Title
//             const Text(
//               'Explore EcoClan',
//               style: TextStyle(
//                 fontSize: 32,
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 8),

//             Text(
//               'Enter your email and password',
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 16,
//                 color: Colors.grey.shade600,
//               ),
//             ),

//             const SizedBox(height: 50),

//             // Email
//             const Text(
//               'Email',
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),

//             _buildInputField(
//               controller: _emailController,
//               hintText: 'user@gmail.com',
//               keyboardType: TextInputType.emailAddress,
//             ),

//             const SizedBox(height: 24),

//             // Password
//             const Text(
//               'Password',
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),

//             _buildInputField(
//               controller: _passwordController,
//               hintText: 'Enter password',
//               isPassword: true,
//             ),

//             const SizedBox(height: 8),

//             // Forgot Password
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () {
//                   // Navigator.push(
//                   //   context,
//                   //   MaterialPageRoute(
//                   //       builder: (context) => const ResetPasswordPage()),
//                   // );
//                 },
//                 child: const Text(
//                   'Forgot Password?',
//                   style: TextStyle(
//                     color: Color(0xFF0D47A1),
//                     fontFamily: 'Poppins',
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),

//             // LOGIN BUTTON
//             isLoading ? _loadingIndicator() : _buildLoginButton(),

//             const SizedBox(height: 40),

//             // Register Link
//             _buildRegisterLink(context),
//           ],
//         ),
//       ),
//     );
//   }

//   // ------------------------------
//   // WIDGET BUILDERS (No changes needed here)
//   // ------------------------------

//   Widget _loadingIndicator() {
//     return const Center(
//       child: CircularProgressIndicator(color: Color(0xFF0D47A1)),
//     );
//   }

//   Widget _buildBackButton(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const Welcome2Screen()),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(8.0),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.grey.shade300, width: 1),
//         ),
//         child: const Icon(
//           Icons.arrow_back_ios_new,
//           color: Colors.black,
//           size: 20,
//         ),
//       ),
//     );
//   }

//   Widget _buildLoginButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: loginUser,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF0D47A1),
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(100),
//           ),
//           elevation: 2,
//         ),
//         child: const Text(
//           'Login',
//           style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
//         ),
//       ),
//     );
//   }

//   Widget _buildRegisterLink(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           "Don't have an account?",
//           style: TextStyle(
//             color: Colors.grey.shade700,
//             fontFamily: 'Poppins',
//             fontSize: 15,
//           ),
//         ),
//         TextButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const RegisterPage()),
//             );
//           },
//           child: const Text(
//             'Register here',
//             style: TextStyle(
//               fontFamily: 'Poppins',
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF0D47A1),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String hintText,
//     bool isPassword = false,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(100),
//         border: Border.all(color: Colors.grey.shade300, width: 1.5),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: TextField(
//         controller: controller,
//         obscureText: isPassword,
//         keyboardType: keyboardType,
//         style: const TextStyle(fontSize: 16),
//         decoration: InputDecoration(
//           hintText: hintText,
//           hintStyle: TextStyle(color: Colors.grey.shade400),
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import 'package:EcoClan/screen/home.dart';
import 'register.dart';
import 'package:EcoClan/screens/welcome2.dart';

// Global Supabase client
final supabase = Supabase.instance.client;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController =
      TextEditingController(text: 'user@gmail.com');
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ⭐ LOGIN FUNCTION
  Future<void> loginUser() async {
    setState(() => isLoading = true);

    try {
      // Login with Supabase
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;

      if (user == null) {
        throw Exception("Login failed: No user returned.");
      }

      // Update last login timestamp
      await supabase.from('users').update({
        'last_login': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', user.id);

      // Navigate to Home Screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage(e.toString());
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  // -------------------------------
  // UI BELOW (unchanged)
  // -------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            _buildBackButton(context),
            const SizedBox(height: 30),

            const Text(
              'Explore EcoClan',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Enter your email and password',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 50),

            const Text(
              'Email',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            _buildInputField(
              controller: _emailController,
              hintText: 'user@gmail.com',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 24),

            const Text(
              'Password',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            _buildInputField(
              controller: _passwordController,
              hintText: 'Enter password',
              isPassword: true,
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF0D47A1),
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            isLoading ? _loadingIndicator() : _buildLoginButton(),

            const SizedBox(height: 40),

            _buildRegisterLink(context),
          ],
        ),
      ),
    );
  }

  Widget _loadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0D47A1)),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Welcome2Screen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loginUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Login',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(
            color: Colors.grey.shade700,
            fontFamily: 'Poppins',
            fontSize: 15,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
          child: const Text(
            'Register here',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
