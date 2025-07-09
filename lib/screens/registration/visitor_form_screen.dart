import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _additionalVisitorsController = TextEditingController();

  String? _selectedGender;
  String? _selectedRelation;
  String? _selectedIdProof;
  bool _isInternationalVisitor = false;
  int _additionalVisitors = 0;
  List<TextEditingController> _additionalVisitorControllers = [];
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
    _additionalVisitorsController.addListener(() {
      final count = int.tryParse(_additionalVisitorsController.text) ?? 0;
      setState(() {
        _additionalVisitors = count;
        _updateAdditionalVisitorControllers();
      });
    });
  }

  void _updateAdditionalVisitorControllers() {
    if (_additionalVisitors > _additionalVisitorControllers.length) {
      for (int i = _additionalVisitorControllers.length; i < _additionalVisitors; i++) {
        _additionalVisitorControllers.add(TextEditingController());
      }
    } else if (_additionalVisitors < _additionalVisitorControllers.length) {
      for (int i = _additionalVisitorControllers.length - 1; i >= _additionalVisitors; i--) {
        _additionalVisitorControllers[i].dispose();
        _additionalVisitorControllers.removeAt(i);
      }
    }
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
                leading: Icon(Icons.camera),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
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
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              // Navigate to help URL
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
              ),
              SizedBox(height: 16),

              // Father/Husband Name
              CustomTextField(
                controller: _fatherNameController,
                label: 'Father/Husband Name*',
                hint: 'Enter Your Father Name',
                validator: Validators.validateName,
              ),
              SizedBox(height: 16),

              // Address
              CustomTextField(
                controller: _addressController,
                label: 'Address*',
                hint: 'Enter Your Address',
                maxLength: 3,
                validator: Validators.validateAddress,
              ),
              SizedBox(height: 16),

              // Gender
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender*',
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
                validator:Validators.validateAge,
              ),
              SizedBox(height: 16),

              // Relation
              DropdownButtonFormField<String>(
                value: _selectedRelation,
                decoration: InputDecoration(
                  labelText: 'Relation*',
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
                  labelText: 'Identity Proof*',
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
                  keyboardType: TextInputType.text,
                  validator: (value) => Validators.validateIdNumber(value, _selectedIdProof!, _idLimits[_selectedIdProof!] ?? 0),
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
                    Icon(Icons.cloud_upload, size: 50, color: Colors.grey),
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
                ),
              SizedBox(height: 16),

              // Additional Visitors Count
              CustomTextField(
                controller: _additionalVisitorsController,
                label: 'Additional Visitors',
                hint: 'Enter number of additional visitors',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // Additional Visitor Names (Dynamic)
              if (_additionalVisitors > 0) ...[
                FormSectionTitle(title: 'Additional Visitor Names'),
                SizedBox(height: 16),
                for (int i = 0; i < _additionalVisitors; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: CustomTextField(
                      controller: _additionalVisitorControllers[i],
                      label: 'Additional Visitor ${i + 1} Name*',
                      hint: 'Enter visitor name',
                      validator:Validators.validateName,
                    ),
                  ),
              ],

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
    _additionalVisitorsController.dispose();
    for (var controller in _additionalVisitorControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}