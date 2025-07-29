import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers with sample data from registration
  TextEditingController nameController = TextEditingController(text: "John Doe");
  TextEditingController fatherNameController = TextEditingController(text: "Robert Doe");
  TextEditingController addressController = TextEditingController(text: "123 Main Street, City");
  TextEditingController ageController = TextEditingController(text: "25");
  TextEditingController emailController = TextEditingController(text: "abc123@gmail.com");
  TextEditingController mobileController = TextEditingController(text: "9876543210");
  TextEditingController idNumberController = TextEditingController(text: "ABCDE1234F");

  // Non-editable fields
  String selectedGender = "Male";
  String selectedIdProof = "Pan Card";
  bool isInternationalVisitor = false;

  // Images (sample paths - in real app these would be actual files)
  File? profileImage;
  File? idProofImage;

  void _showEditImageConfirmation(String imageType) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit Confirmation"),
        content: Text(
          "Your profile will be disabled and will be enabled after Profile Image/ID Proof Verification.\nAre you sure to edit? (Y/N)",
        ),
        actions: [
          TextButton(
            child: Text("No"),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            child: Text("Yes"),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Handle image pick for profile or ID proof
      _pickImage(imageType);
    }
  }

  void _pickImage(String imageType) {
    // Placeholder for image picking logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Image picker would open here for $imageType"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Color(0xFF5A8BBA),
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showEditImageConfirmation("Profile Image"),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: profileImage != null
                                ? FileImage(profileImage!) as ImageProvider
                                : AssetImage('assets/images/user.png'),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap to change profile photo",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Personal Details Section
              Text(
                "Personal Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A8BBA),
                ),
              ),
              SizedBox(height: 15),

              // Name Field (Editable)
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Visitor Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String text = newValue.text;
                    if (text.isNotEmpty) {
                      text = text.split(' ').map((word) {
                        if (word.isNotEmpty) {
                          return word[0].toUpperCase() + word.substring(1).toLowerCase();
                        }
                        return word;
                      }).join(' ');
                    }
                    return TextEditingValue(
                      text: text,
                      selection: TextSelection.collapsed(offset: text.length),
                    );
                  }),
                ],
              ),
              SizedBox(height: 15),

              // Father/Husband Name Field (Editable)
              TextField(
                controller: fatherNameController,
                decoration: InputDecoration(
                  labelText: "Father/Husband Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String text = newValue.text;
                    if (text.isNotEmpty) {
                      text = text.split(' ').map((word) {
                        if (word.isNotEmpty) {
                          return word[0].toUpperCase() + word.substring(1).toLowerCase();
                        }
                        return word;
                      }).join(' ');
                    }
                    return TextEditingValue(
                      text: text,
                      selection: TextSelection.collapsed(offset: text.length),
                    );
                  }),
                ],
              ),
              SizedBox(height: 15),

              // Address Field (Editable)
              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String text = newValue.text;
                    if (text.isNotEmpty) {
                      text = text.split(' ').map((word) {
                        if (word.isNotEmpty) {
                          return word[0].toUpperCase() + word.substring(1).toLowerCase();
                        }
                        return word;
                      }).join(' ');
                    }
                    return TextEditingValue(
                      text: text,
                      selection: TextSelection.collapsed(offset: text.length),
                    );
                  }),
                ],
              ),
              SizedBox(height: 15),

              // Gender Field (Read-only)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[100],
                ),
                child: Row(
                  children: [
                    Icon(Icons.male, color: Colors.black),
                    SizedBox(width: 12),
                    Text(
                      "Gender: $selectedGender",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              // Age Field (Editable)
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
              SizedBox(height: 15),
              // Email Field (Read-only)
              TextField(
                controller: emailController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Email ID",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  suffixIcon: Icon(Icons.lock, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              SizedBox(height: 15),

              // Mobile Field (Read-only)
              TextField(
                controller: mobileController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  suffixIcon: Icon(Icons.lock, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              SizedBox(height: 20),

              // ID Proof Section
              Text(
                "ID Proof Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A8BBA),
                ),
              ),
              SizedBox(height: 15),

              // ID Proof Type (Read-only)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[100],
                ),
                child: Row(
                  children: [
                    Icon(Icons.credit_card, color: Colors.grey[600]),
                    SizedBox(width: 12),
                    Text(
                      "ID Proof: $selectedIdProof",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),

              // ID Number Field (Editable)
              TextField(
                controller: idNumberController,
                decoration: InputDecoration(
                  labelText: "ID Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              SizedBox(height: 15),

              // ID Proof Image Section
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: idProofImage != null
                    ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        idProofImage!,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _showEditImageConfirmation("ID Proof"),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : InkWell(
                  onTap: () => _showEditImageConfirmation("ID Proof"),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        "Tap to upload/change ID Proof",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Visitor Type (Read-only)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[100],
                ),
                child: Row(
                  children: [
                    Icon(Icons.public, color: Colors.grey[600]),
                    SizedBox(width: 12),
                    Text(
                      "Visitor Type: ${isInternationalVisitor ? 'International' : 'National'}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Save Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Profile updated successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5A8BBA),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    fatherNameController.dispose();
    addressController.dispose();
    ageController.dispose();
    emailController.dispose();
    mobileController.dispose();
    idNumberController.dispose();
    super.dispose();
  }
}