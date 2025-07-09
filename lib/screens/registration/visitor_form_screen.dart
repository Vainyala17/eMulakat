import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'meet_form_screen.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/color_scheme.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class VisitorFormScreen extends StatefulWidget {
  @override
  _VisitorFormScreenState createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  late WebViewController controller;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  String? _selectedGender;
  String? _selectedRelation;
  String? _selectedIdProof;
  bool _isInternationalVisitor = false;
  File? _selectedImage;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _relations = ['Father', 'Mother', 'Spouse', 'Brother', 'Sister', 'Son', 'Daughter', 'Friend', 'Other'];
  final List<String> _idProofs = ['Aadhar Card', 'Pan Card', 'Driving License', 'Passport', 'Voter ID', 'Others', 'Not Available'];

  final Map<String, int> _idLimits = {
    'Aadhar Card': 12,
    'Pan Card': 10,
    'Driving License': 16,
    'Passport': 8,
    'Voter ID': 10,
    'Others': 20,
    'Not Available': 0,
  };

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image_search),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visitor Registration'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              controller = WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse('https://eprisons.nic.in/downloads/eMulakat_VCRequestPublic.pdf'));
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormSectionTitle(title: 'Visitor Details'),
              SizedBox(height: 20),

              // Visitor Name
              CustomTextField(
                controller: _nameController,
                label: 'Visitor Name*',
                hint: 'Enter your Name',
                validator: Validators.validateName,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // Convert first letter of each word to uppercase
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
              SizedBox(height: 16),

              // Father/Husband Name
              CustomTextField(
                controller: _fatherNameController,
                label: 'Father/Husband Name*',
                hint: 'Enter Your Father Name',
                validator: Validators.validateName,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // Convert first letter of each word to uppercase
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
              SizedBox(height: 16),

              // Address
              CustomTextField(
                controller: _addressController,
                label: 'Address*',
                hint: 'Enter Your Address',
                validator: Validators.validateAddress,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // Convert first letter of each word to uppercase
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
              SizedBox(height: 16),

              // Gender
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  label: Text('Gender*'),
                  labelText: 'Select Gender',
                  border: OutlineInputBorder(),
                ),
                items: _genders.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) => value == null ? 'Please select gender' : null,
              ),
              SizedBox(height: 16),

              // Age
              CustomTextField(
                controller: _ageController,
                label: 'Age*',
                hint: 'Enter Your Age',
                keyboardType: TextInputType.number,
                validator: Validators.validateAge,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3), // Limit age to 3 digits
                ],
              ),
              SizedBox(height: 16),

              // Relation
              DropdownButtonFormField<String>(
                value: _selectedRelation,
                decoration: InputDecoration(
                  label: Text('Relation*'),
                  labelText: 'Select Relation',
                  border: OutlineInputBorder(),
                ),
                items: _relations.map((relation) {
                  return DropdownMenuItem(
                    value: relation,
                    child: Text(relation),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRelation = value;
                  });
                },
                validator: (value) => value == null ? 'Please select relation' : null,
              ),
              SizedBox(height: 16),

              // ID Proof
              DropdownButtonFormField<String>(
                value: _selectedIdProof,
                decoration: InputDecoration(
                  label: Text('ID Proof*'),
                  labelText: 'Select Identity Proof',
                  border: OutlineInputBorder(),
                ),
                items: _idProofs.map((idProof) {
                  return DropdownMenuItem(
                    value: idProof,
                    child: Text(idProof),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIdProof = value;
                    _idNumberController.clear();
                  });
                },
                validator: (value) => value == null ? 'Please select ID proof' : null,
              ),
              SizedBox(height: 16),

              // ID Number
              if (_selectedIdProof != null && _selectedIdProof != 'Not Available')
                CustomTextField(
                  controller: _idNumberController,
                  label: 'ID Number*',
                  hint: 'Enter ${_selectedIdProof} Number',
                  keyboardType: _selectedIdProof == 'Pan Card' ? TextInputType.text : TextInputType.number,
                  validator: (value) => Validators.validateIdNumber(value, _selectedIdProof!, _idLimits[_selectedIdProof!] ?? 0),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(_idLimits[_selectedIdProof!] ?? 0),
                    if (_selectedIdProof == 'Pan Card')
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]'))
                    else if (_selectedIdProof == 'Passport')
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]'))
                    else
                      FilteringTextInputFormatter.digitsOnly,
                    if (_selectedIdProof == 'Pan Card')
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return TextEditingValue(
                          text: newValue.text.toUpperCase(),
                          selection: newValue.selection,
                        );
                      }),
                  ],
                ),
              SizedBox(height: 16),

              // Image Upload
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImage != null
                    ? Stack(
                  children: [
                    Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload, size: 50, color: Colors.grey),
                    SizedBox(height: 16),
                    CustomButton(
                      text: 'Upload ID Proof Image',
                      onPressed: _pickImage,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // International Visitor Checkbox
              CheckboxListTile(
                title: Text('International Visitor'),
                value: _isInternationalVisitor,
                onChanged: (value) {
                  setState(() {
                    _isInternationalVisitor = value ?? false;
                    if (_isInternationalVisitor) {
                      _mobileController.clear();
                    } else {
                      _emailController.clear();
                    }
                  });
                },
              ),

              // Email (for international visitors or optional for others)
              if (_isInternationalVisitor || !_isInternationalVisitor)
                CustomTextField(
                  controller: _emailController,
                  label: _isInternationalVisitor ? 'Email ID*' : 'Email ID',
                  hint: 'Enter Your Email Id',
                  keyboardType: TextInputType.emailAddress,
                  validator: _isInternationalVisitor ? Validators.validateEmail : null,
                ),
              SizedBox(height: 16),

              // Mobile Number (for non-international visitors)
              if (!_isInternationalVisitor)
                CustomTextField(
                  controller: _mobileController,
                  label: 'Mobile No*',
                  hint: 'Enter Your Mobile Number',
                  keyboardType: TextInputType.phone,
                  validator: Validators.validateMobile,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10), // Limit to 10 digits
                  ],
                ),

              SizedBox(height: 30),

              // Save Button
              CustomButton(
                text: 'Save & Next',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MeetFormScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _idNumberController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }
}