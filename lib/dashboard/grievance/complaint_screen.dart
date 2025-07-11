import 'package:e_mulakat/dashboard/grievance/grievance_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/validators.dart';

class ComplaintScreen extends StatefulWidget {
  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  late WebViewController controller;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _selectedRelation;
  bool _isInternationalVisitor = false;

  final List<String> _relations = ['Father', 'Mother', 'Spouse', 'Brother', 'Sister', 'Son', 'Daughter', 'Friend', 'Other'];

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormSectionTitle(title: 'Complainant Details'),
              SizedBox(height: 20),
              // Visitor Name
              CustomTextField(
                controller: _nameController,
                label: 'Name*',
                hint: 'Enter your Name',
                validator: Validators.validateName,
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
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedRelation,
                decoration: InputDecoration(
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
              if (!_isInternationalVisitor) ...[
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _mobileController,
                        label: 'Mobile No*',
                        hint: 'Enter Your Mobile Number',
                        keyboardType: TextInputType.phone,
                        validator: Validators.validateMobile,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                    ),
                  ]
                )
              ],
              SizedBox(height: 10),
              // Save Button
              CustomButton(
                text: 'Save & Next',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GrievanceDetailsScreen()),
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
    _emailController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}