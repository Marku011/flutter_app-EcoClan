// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:image_picker/image_picker.dart'; // For picking images
// import 'dart:io'; // For File type
// import 'profile.dart'; // Assuming ProfilePage is here
// import 'package:EcoClan/pages/login.dart'; // Adjust path to LoginPage

// // Initialize Supabase client
// final supabase = Supabase.instance.client;

// class EditProfilePage extends StatefulWidget {
//   const EditProfilePage({super.key});

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   final Color primaryColor = const Color(0xFF0D47A1); // Dark Blue
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _contactNoController = TextEditingWrapper(text: '');
//   final TextEditingController _addressController = TextEditingController();
  
//   bool _isLoading = true;
//   String? _profileImageUrl;
//   File? _newProfileImage; // Stores the newly picked image file
  
//   // Custom wrapper to handle non-String/null issues
//   int get _addressLength => _addressController.text.length;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCurrentUserData();
//     _addressController.addListener(() {
//       setState(() {
//         // Force a UI update to refresh the counter
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _contactNoController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   // --- SUPABASE DATA FETCHING ---
//   Future<void> _fetchCurrentUserData() async {
//     final user = supabase.auth.currentUser;
//     if (user == null) {
//       setState(() => _isLoading = false);
//       return;
//     }

//     try {
//       // 1. Fetch user data from the public 'users' table
//       final response = await supabase
//           .from('users')
//           .select('name, contact_no, address, avatar_url')
//           .eq('id', user.id)
//           .single();

//       // 2. Populate controllers and state
//       setState(() {
//         _fullNameController.text = response['name'] ?? '';
//         // Use user.email for the email, as it comes from auth.users
//         _emailController.text = user.email ?? ''; 
//         _contactNoController.text = response['contact_no'] ?? '';
//         _addressController.text = response['address'] ?? '';
//         _profileImageUrl = response['avatar_url'] as String?;
//         _isLoading = false;
//       });
//     } on PostgrestException catch (e) {
//       debugPrint('Supabase Fetch Error: ${e.message}');
//       setState(() {
//         _emailController.text = user.email ?? '';
//         _isLoading = false;
//       });
//       _showSnackBar('Error loading profile data: ${e.message}');
//     } catch (e) {
//       debugPrint('Error: $e');
//       setState(() => _isLoading = false);
//     }
//   }
  
//   // --- SUPABASE IMAGE UPLOAD/UPDATE ---
//   Future<String?> _uploadProfileImage() async {
//     if (_newProfileImage == null) return _profileImageUrl;

//     final user = supabase.auth.currentUser;
//     if (user == null) return null;

//     final fileName = 'profile/${user.id}/${DateTime.now().toIso8601String()}.jpg';
    
//     try {
//       // Upload the image file
//       final fileExtension = _newProfileImage!.path.split('.').last;
//       final bytes = await _newProfileImage!.readAsBytes();

//       await supabase.storage.from('avatars').uploadBinary(
//         fileName, 
//         bytes,
//         fileOptions: FileOptions(
//           upsert: true,
//           contentType: 'image/$fileExtension',
//         ),
//       );

//       // Get the public URL
//       final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
//       return publicUrl;
      
//     } catch (e) {
//       debugPrint('Image upload error: $e');
//       return null;
//     }
//   }

//   // --- SUPABASE PROFILE UPDATE ---
//   Future<void> _updateProfile() async {
//     setState(() => _isLoading = true);
//     final user = supabase.auth.currentUser;

//     if (user == null) {
//       setState(() => _isLoading = false);
//       return;
//     }
    
//     // Check if any change was made
//     final currentEmail = user.email;
//     final newEmail = _emailController.text.trim();
    
//     try {
//       // 1. Handle Image Update
//       final newAvatarUrl = await _uploadProfileImage();

//       // 2. Handle Email Update (Requires Auth API)
//       if (newEmail != currentEmail) {
//         await supabase.auth.updateUser(UserAttributes(
//           email: newEmail,
//         ));
//         // NOTE: Supabase will automatically send a confirmation email for this change.
//       }

//       // 3. Handle Public Profile Update (Requires Postgrest)
//       final updateData = {
//         'name': _fullNameController.text.trim(),
//         'phone': _contactNoController.text.trim(),
//         'address': _addressController.text.trim(),
//         'avatar_url': newAvatarUrl,
//       };

//       await supabase.from('users').update(updateData).eq('id', user.id);

//       setState(() => _isLoading = false);
//       _showUpdateSuccessModal(newEmail != currentEmail);

//     } on AuthException catch (e) {
//       setState(() => _isLoading = false);
//       _showSnackBar('Update failed (Auth): ${e.message}');
//     } on PostgrestException catch (e) {
//       setState(() => _isLoading = false);
//       _showSnackBar('Update failed (DB): ${e.message}');
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showSnackBar('An unexpected error occurred: $e');
//     }
//   }

//   // --- SUPABASE DELETE ACCOUNT ---
//   Future<void> _deleteAccount() async {
//     setState(() => _isLoading = true);
//     final user = supabase.auth.currentUser;

//     if (user == null) {
//       // Should not happen, but a safeguard
//       _showSnackBar('No user logged in to delete.');
//       return;
//     }

//     try {
//       // In a real application, you'd first delete related data (e.g., points, address)
//       // from public tables before deleting the auth record, or use a database function.
      
//       // Delete the user from the auth.users table (This will fail unless you use the Service Role Key, 
//       // which is NOT recommended in a client-side app. We will use the client-side method
//       // which only works if the user has recently logged in.)

//       // NOTE: Supabase only allows users to delete their own account using a stored procedure 
//       // or if they have recently logged in. If you get permission denied, you may need a server function.

//       // For a client-side solution, we must delete the user's data from public tables first.
//       await supabase.from('users').delete().eq('id', user.id);

//       // Now attempt to delete the auth record (requires recent re-authentication in production)
//       await supabase.rpc(
//         'delete_user_data_and_account',
//         params: {'user_id': user.id},
//       );

//       // Navigate to login page
//       if (mounted) {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const LoginPage()),
//           (Route<dynamic> route) => false,
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showSnackBar('Account deletion failed. Please re-login and try again.');
//       debugPrint('Delete Account Error: $e');
//     }
//   }
  
//   // --- UI and Modal Helpers ---
//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
  
//   Widget _buildInputField({
//     required String label,
//     required TextEditingController controller,
//     int maxLines = 1,
//     int maxLength = 200,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     final bool showCounter = maxLines > 1;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: TextField(
//             controller: controller,
//             keyboardType: keyboardType,
//             maxLines: maxLines,
//             maxLength: showCounter ? maxLength : null,
//             readOnly: label == 'Email', // Prevent editing email directly (requires special handling)
//             decoration: InputDecoration(
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.zero,
//               counterText: showCounter ? '$_addressLength/$maxLength' : null,
//               counterStyle: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey,
//               ),
//             ),
//             style: const TextStyle(fontSize: 16),
//           ),
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }

//   // Custom function to show the Success Update Modal
//   void _showUpdateSuccessModal(bool emailChanged) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           child: Padding(
//             padding: const EdgeInsets.all(30.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 const Text(
//                   'Successful Update!',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   emailChanged 
//                       ? 'Your profile information has been changed. A confirmation link has been sent to your new email.' 
//                       : 'Your profile information has been successfully changed.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context).pop(); 
//                       Navigator.of(context).pop(); // Go back to ProfilePage
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(100),
//                       ),
//                     ),
//                     child: const Text(
//                       'Continue to Profile',
//                       style: TextStyle(fontSize: 16, color: Colors.white,),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
  
//   // Custom function to show the Delete Confirmation Modal
//   void _showDeleteConfirmationModal() {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Confirm Deletion', style: TextStyle(color: Colors.red)),
//           content: const Text(
//             'Are you absolutely sure you want to permanently delete your account? This action cannot be undone.',
//             style: TextStyle(color: Colors.black87),
//           ),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: const Text('Cancel', style: TextStyle(color: Color(0xFF0D47A1))),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//                 _deleteAccount(); // Execute deletion
//               },
//               child: const Text('Delete Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Function to handle image picking
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _newProfileImage = File(pickedFile.path);
//       });
//     }
//   }

//   // Widget to display the profile picture with an edit button
//   Widget _buildProfilePicture() {
//     final imageProvider = _newProfileImage != null
//         ? FileImage(_newProfileImage!) as ImageProvider
//         : (_profileImageUrl != null
//             ? NetworkImage(_profileImageUrl!) as ImageProvider
//             : const AssetImage('images/default_avatar.png') as ImageProvider); // Use a default image asset

//     return Center(
//       child: Stack(
//         children: [
//           CircleAvatar(
//             radius: 60,
//             backgroundColor: Colors.grey.shade200,
//             backgroundImage: imageProvider,
//           ),
//           Positioned(
//             bottom: 0,
//             right: 0,
//             child: GestureDetector(
//               onTap: _pickImage,
//               child: Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: primaryColor,
//                   border: Border.all(color: Colors.white, width: 2),
//                 ),
//                 child: const Icon(
//                   Icons.edit,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         elevation: 0,
//         toolbarHeight: 100,
//         title: const Text(
//           'Edit Profile',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//           ),
//         ),
//         centerTitle: true,
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 16.0),
//           child: Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: const Color(0xFFFFFF).withOpacity(0.4),
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(24.0),
//               child: Container(
//                 padding: const EdgeInsets.all(24.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 15,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     // Profile Picture with Edit Icon
//                     _buildProfilePicture(),
//                     const SizedBox(height: 30),

//                     // Fullname Field
//                     _buildInputField(
//                       label: 'Fullname',
//                       controller: _fullNameController,
//                     ),

//                     // Email Field (Read-only as per standard security practice)
//                     _buildInputField(
//                       label: 'Email',
//                       controller: _emailController,
//                       keyboardType: TextInputType.emailAddress,
//                     ),

//                     // Contact No. Field
//                     _buildInputField(
//                       label: 'Contact No.',
//                       controller: _contactNoController,
//                       keyboardType: TextInputType.phone,
//                     ),

//                     // Address Field
//                     _buildInputField(
//                       label: 'Address',
//                       controller: _addressController,
//                       maxLines: 4,
//                       maxLength: 200,
//                       keyboardType: TextInputType.multiline,
//                     ),
                    
//                     const SizedBox(height: 10),

//                     // Update Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _updateProfile, // Call Supabase update function
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: primaryColor,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(100),
//                           ),
//                           elevation: 5,
//                         ),
//                         child: const Text(
//                           'Update Profile',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
                    
//                     // --- Delete Account Button ---
//                     SizedBox(
//                       width: double.infinity,
//                       child: TextButton(
//                         onPressed: _showDeleteConfirmationModal, // Show delete modal
//                         style: TextButton.styleFrom(
//                           foregroundColor: Colors.red.shade700,
//                         ),
//                         child: const Text(
//                           'Delete Account',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

// class ImagePickerWrapper {
//   final ImagePicker _picker = ImagePicker();

//   Future<XFile?> pickImageFromGallery() async {
//     return await _picker.pickImage(source: ImageSource.gallery);
//   }
// }

// class ImagePickerService {
//   final ImagePickerWrapper _imagePickerWrapper = ImagePickerWrapper();

//   Future<File?> pickImage() async {
//     final pickedFile = await _imagePickerWrapper.pickImageFromGallery();
//     if (pickedFile != null) {
//       return File(pickedFile.path);
//     }
//     return null;
//   }
// }

// // Custom wrapper for TextEditingController to handle non-String/null issues gracefully
// // NOTE: Not strictly necessary for this logic but good practice if fetching raw data.
// class TextEditingWrapper extends TextEditingController {
//   TextEditingWrapper({String? text}) : super(text: text);
// }
//
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

// Assume supabase client is configured and available globally or passed via provider
final supabase = Supabase.instance.client; 

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final Color primaryColor = const Color(0xFF0D47A1); // Dark Blue
  
  // State for fetched data
  String? _userId;
  String _currentFullName = '';
  String _currentEmail = '';
  String _currentPhone = '';
  String _currentAddress = '';
  bool _isLoading = true; // Added loading state

  // Controllers
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  int _addressLength = 0;

  @override
  void initState() {
    super.initState();
    // Initialize controllers (will be updated after data fetch)
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    _fetchCurrentData();

    _addressController.addListener(() {
      setState(() {
        _addressLength = _addressController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  // --- Supabase Interaction Methods ---

  // Function to fetch initial data from the database
  Future<void> _fetchCurrentData() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    
    _userId = user.id;
    
    try {
      final response = await supabase
          .from('users')
          .select('name, phone, address') // Adjust column names to match your table
          .eq('id', _userId!)
          .single();

      setState(() {
        _currentFullName = response['name'] as String? ?? '';
        _currentEmail = user.email ?? ''; // Email comes from the auth object
        _currentPhone = response['phone'] as String? ?? '';
        _currentAddress = response['address'] as String? ?? '';
        _isLoading = false;
      });

      // Update controllers with fetched data
      _fullNameController.text = _currentFullName;
      _emailController.text = _currentEmail;
      _phoneController.text = _currentPhone;
      _addressController.text = _currentAddress;
      _addressLength = _addressController.text.length;

    } on PostgrestException catch (e) {
      debugPrint('Error fetching profile: ${e.message}');
      setState(() { _isLoading = false; });
      _showErrorDialog('Fetch Failed', 'Could not load profile data: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      setState(() { _isLoading = false; });
    }
  }


  // Function to update user profile in the public 'users' table
  Future<void> _updateProfile() async {
    if (_userId == null) return; 
    
    // Simple validation
    if (_fullNameController.text.isEmpty) {
      _showErrorDialog('Validation Error', 'Full name cannot be empty.');
      return;
    }

    // You might need a separate call to update the email in auth.users
    // but updating PII is usually handled in the public 'users' table.

    try {
      // 1. Update the 'users' table in the database
      await supabase
          .from('users')
          .update({
            'name': _fullNameController.text,
            'phone': _phoneController.text, // Assuming column name is 'phone'
            'address': _addressController.text,
          })
          .eq('id', _userId!); 

      // 2. Update local state and show success modal
      setState(() {
        _currentFullName = _fullNameController.text;
        _currentPhone = _phoneController.text;
        _currentAddress = _addressController.text;
      });

      _showUpdateSuccessModal();
      
    } on PostgrestException catch (e) {
      debugPrint('Error updating profile: ${e.message}');
      _showErrorDialog('Update Failed', 'Could not update profile: ${e.message}');
    } catch (error) {
      debugPrint('Unexpected error updating profile: $error');
      _showErrorDialog('Update Failed', 'An unexpected error occurred. Please try again.');
    }
  }
  
  // --- Helper Widgets and Modals ---

  // Helper widget to build the custom text input fields
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    int maxLength = 200,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false, // Added readOnly flag
  }) {
    final bool showCounter = maxLines > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: showCounter ? maxLength : null,
            readOnly: readOnly,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              counterText: showCounter ? '$_addressLength/$maxLength' : null,
              counterStyle: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Custom function to show the Success Update Modal
  void _showUpdateSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Successful Update',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your profile information has been successfully changed.', 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Close the modal and navigate back to the previous screen (ProfilePage)
                      Navigator.of(context).pop(); 
                      Navigator.of(context).pop(); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(
                      'Continue to Profile',
                      style: TextStyle(fontSize: 16, color: Colors.white,),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to show a general error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
  
  // Widget to display the CircleAvatar with the first letter
  Widget _buildProfileAvatar() {
    // Get the first letter of the full name
    final String initial = _currentFullName.isNotEmpty 
        ? _currentFullName[0].toUpperCase() 
        : '?';
        
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
        child: CircleAvatar(
          radius: 50,
          backgroundColor: primaryColor, // Blue background
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 40,
              color: Colors.white, // White text
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor, // Dark blue background
        elevation: 0,
        toolbarHeight: 100,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.4),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Profile Avatar with First Letter 
                    _buildProfileAvatar(),
                    
                    // Fullname Field
                    _buildInputField(
                      label: 'Fullname',
                      controller: _fullNameController,
                    ),

                    // Email Field (Read-only as updating email is more complex)
                    _buildInputField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true, // Email usually cannot be edited here
                    ),

                    // Contact No. Field
                    _buildInputField(
                      label: 'Contact No.',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),

                    // Address Field (Multifine with counter)
                    _buildInputField(
                      label: 'Address',
                      controller: _addressController,
                      maxLines: 3,
                      maxLength: 150,
                      keyboardType: TextInputType.multiline,
                    ),
                    
                    const SizedBox(height: 10),

                    // UPDATE Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProfile, // Call Supabase update function
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Update Profile',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10), // Reduced bottom space
                  ],
                ),
              ),
            ),
    );
  }
}