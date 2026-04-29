import 'dart:convert'; 
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ManageProfileScreen extends StatefulWidget {
  const ManageProfileScreen({super.key});

  @override
  State<ManageProfileScreen> createState() => _ManageProfileScreenState();
}

class _ManageProfileScreenState extends State<ManageProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _regionController;

  bool _isUpdating = false;
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();

  final List<String> _slDistricts = [
    "Ampara", "Anuradhapura", "Badulla", "Batticaloa", "Colombo", "Galle", "Gampaha",
    "Hambantota", "Jaffna", "Kalutara", "Kandy", "Kegalle", "Kilinochchi", "Kurunegala",
    "Mannar", "Matale", "Matara", "Moneragala", "Mullaitivu", "Nuwara Eliya", "Polonnaruwa",
    "Puttalam", "Ratnapura", "Trincomalee", "Vavuniya"
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _regionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30, 
      maxWidth: 400,    
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes); // 🔥 Image to String
      });
    }
  }

  Future<void> _updateProfile(String docId, String? currentImage) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUpdating = true);
      try {
        await FirebaseFirestore.instance.collection('farmers').doc(docId).update({
          'full_name': _nameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'region': _regionController.text.trim(),
          'profile_pic': _base64Image ?? currentImage, // 🔥 අලුත් එක නැත්නම් පරණ එක තියනවා
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Updated Successfully! ✅")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update Failed: $e ❌")),
        );
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Manage Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('farmers').limit(1).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Farmer Data Found"));
          }

          var userData = snapshot.data!.docs.first;
          var data = userData.data() as Map<String, dynamic>;

          if (_nameController.text.isEmpty) {
            _nameController.text = data['full_name'] ?? "";
            _phoneController.text = data['phone_number'] ?? "";
            _emailController.text = data['email'] ?? "";
            _regionController.text = data['region'] ?? "";
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? theme.colorScheme.surface : Colors.green[700],
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  ),
                  padding: const EdgeInsets.only(bottom: 40, top: 10),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 65,
                            backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                            // 🔥 Base64 String එක පින්තූරයක් විදිහට පෙන්වන හැටි
                            backgroundImage: _base64Image != null
                                ? MemoryImage(base64Decode(_base64Image!))
                                : (data['profile_pic'] != null && data['profile_pic'] != ""
                                ? MemoryImage(base64Decode(data['profile_pic'])) as ImageProvider
                                : null),
                            child: (_base64Image == null && (data['profile_pic'] == null || data['profile_pic'] == ""))
                                ? Icon(Icons.person, size: 80, color: Colors.green[700])
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: const CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 20,
                                child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                          _nameController.text,
                          style: TextStyle(color: isDark ? Colors.green : Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 20),
                        _buildProfileInput(context, "Full Name", _nameController, Icons.person_outline),
                        const SizedBox(height: 20),
                        _buildProfileInput(context, "Email Address", _emailController, Icons.email_outlined),
                        const SizedBox(height: 20),
                        _buildProfileInput(context, "Phone Number", _phoneController, Icons.phone_android_outlined, isNumber: true),
                        const SizedBox(height: 20),
                        _buildProfileInput(context, "District (Region)", _regionController, Icons.location_on_outlined),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isUpdating ? null : () => _updateProfile(userData.id, data['profile_pic']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: _isUpdating
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInput(BuildContext context, String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
            style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.green[700]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }
}