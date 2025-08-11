import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/visitor_model.dart';
import '../../screens/home/home_screen.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/validators.dart';

class MeetFormScreen extends StatefulWidget {
  final bool fromChatbot;
  final VisitorModel? visitorData; // Add this parameter

  const MeetFormScreen({
    Key? key,
    this.fromChatbot = false,
    this.visitorData, // Add this parameter
  }) : super(key: key);

  @override
  _MeetFormScreenState createState() => _MeetFormScreenState();
}

class _MeetFormScreenState extends State<MeetFormScreen> {
  late WebViewController controller;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _prisonerNameController = TextEditingController();
  final TextEditingController _prisonerFatherNameController = TextEditingController();
  final TextEditingController _prisonerAgeController = TextEditingController();
  final TextEditingController _visitDateController = TextEditingController();
  final TextEditingController _additionalVisitorsController = TextEditingController();

  String? _selectedPrisonerType;
  int _additionalVisitors = 0;
  List<TextEditingController> _additionalVisitorControllers = [];
  bool _isEditing = false; // Track if we're editing existing data

  final List<String> _visitType = ['Physical ', 'Video Conferencing '];

  @override
  void initState() {
    super.initState();

    // Check if we have visitor data to populate
    if (widget.visitorData != null) {
      _isEditing = true;
      _populateFormWithVisitorData();
    }

    _additionalVisitorsController.addListener(() {
      final count = int.tryParse(_additionalVisitorsController.text) ?? 0;
      setState(() {
        _additionalVisitors = count;
        _updateAdditionalVisitorControllers();
      });
    });
    //AuthService.checkAndHandleSession(context);
  }

  void _populateFormWithVisitorData() {
    final visitor = widget.visitorData!;

    // Populate prisoner details (these will be read-only for editing)
    _prisonerNameController.text = visitor.prisonerName;
    _prisonerFatherNameController.text = visitor.prisonerFatherName;
    _prisonerAgeController.text = visitor.prisonerAge.toString();

    // Populate visit details (these will be editable)
    _visitDateController.text = DateFormat('dd/MM/yyyy').format(visitor.visitDate);
    _selectedPrisonerType = visitor.mode ? 'Video Conferencing ' : 'Physical ';

    // Populate additional visitors
    _additionalVisitors = visitor.additionalVisitors;
    _additionalVisitorsController.text = visitor.additionalVisitors.toString();

    // Populate additional visitor names
    for (int i = 0; i < visitor.additionalVisitors; i++) {
      _additionalVisitorControllers.add(TextEditingController());
      if (i < visitor.additionalVisitorNames.length) {
        _additionalVisitorControllers[i].text = visitor.additionalVisitorNames[i];
      }
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Please use Logout and close the App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // stay
            child: const Text('OK'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 16),
              Text(
                "Success",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _isEditing
                    ? "Your visit has been successfully updated!"
                    : "Your visit has been successfully scheduled!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,

        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormSectionTitle(title: 'Whom to Meet'),
                SizedBox(height: 20),

                // Prisoner Name - Read only when editing
                CustomTextField(
                  controller: _prisonerNameController,
                  label: 'Prisoner Name*',
                  hint: 'Enter prisoner Name',
                  validator: Validators.validateName,
                  //readOnly: _isEditing, // Make read-only when editing
                  inputFormatters: _isEditing ? [] : [
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
                SizedBox(height: 20),

                // Show additional prisoner info when editing
                if (_isEditing) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _prisonerFatherNameController,
                          label: 'Prisoner Father Name',
                          hint: 'Father Name',
                          //readOnly: true,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _prisonerAgeController,
                          label: 'Prisoner Age',
                          hint: 'Age',
                          //readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],

                // Visit Date - Always editable
                TextFormField(
                  controller: _visitDateController,
                  decoration: InputDecoration(
                    labelText: 'Visit Date*',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _isEditing
                          ? widget.visitorData!.visitDate
                          : DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 30)),
                    );
                    if (pickedDate != null) {
                      _visitDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                    }
                  },
                  validator: (value) => value!.isEmpty ? 'Please select visit date' : null,
                ),
                SizedBox(height: 20),

                // Visit Type Selection - Always editable
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Mode of Visit*',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _visitType.map((visitMode) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: visitMode,
                              groupValue: _selectedPrisonerType,
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPrisonerType = value;
                                });
                              },
                            ),
                            Text(
                              visitMode,
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(width: 25),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Additional Visitors - Always editable
                CustomTextField(
                  controller: _additionalVisitorsController,
                  label: 'Additional Visitors',
                  hint: 'Enter number of additional visitors',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                SizedBox(height: 16),

                // Additional Visitor Names (Dynamic) - Always editable
                if (_additionalVisitors > 0) ...[
                  FormSectionTitle(title: 'Additional Visitor Names'),
                  SizedBox(height: 16),
                  for (int i = 0; i < _additionalVisitors; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: CustomTextField(
                        controller: _additionalVisitorControllers[i],
                        label: _additionalVisitors == 1
                            ? 'Additional Visitor Name*'
                            : 'Additional Visitor Name-${i + 1}*',
                        hint: 'Enter visitor name',
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
                    ),
                ],

                SizedBox(height: 30),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: _isEditing ? 'Update Visit' : 'Schedule Visit',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedPrisonerType == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please select visit mode'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            showSuccessDialog(context);
                          }
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _prisonerNameController.dispose();
    _prisonerFatherNameController.dispose();
    _prisonerAgeController.dispose();
    _visitDateController.dispose();
    _additionalVisitorsController.dispose();
    for (var controller in _additionalVisitorControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}