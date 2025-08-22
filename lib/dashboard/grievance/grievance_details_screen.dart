// lib/screens/grievance/grievance_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/grievance_controller.dart';
import '../../models/visitor_model.dart';
import '../../pdf_viewer_screen.dart';
import '../../screens/home/bottom_nav_bar.dart';
import '../../screens/home/home_screen.dart';
import '../../utils/color_scheme.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/read_only_text_fields.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../parole/parole_screen.dart';
import '../visit/whom_to_meet_screen.dart';

class GrievanceDetailsScreen extends GetView<GrievanceController> {
  final bool fromChatbot;
  final int selectedIndex;
  final VisitorModel? visitorData;
  final bool fromNavbar;
  final bool fromRegisteredInmates;
  final String? prefilledPrisonerName;
  final String? prefilledPrison;
  final bool showVisitCards;

  const GrievanceDetailsScreen({
    Key? key,
    this.fromChatbot = false,
    this.visitorData,
    this.selectedIndex = 0,
    this.fromNavbar = false,
    this.fromRegisteredInmates = false,
    this.prefilledPrisonerName,
    this.prefilledPrison,
    this.showVisitCards = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set screen mode based on parameters
    controller.setScreenMode(
      fromRegisteredInmates: fromRegisteredInmates,
      showVisitCards: showVisitCards || !fromChatbot,
      selectedIdx: selectedIndex,
      prefilledPrisonerName: prefilledPrisonerName,
      prefilledPrison: prefilledPrison,
    );

    return WillPopScope(
      onWillPop: () => DialogUtils.onWillPop(context, showingCards: controller.showingVisitCards.value),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Grievance'),
          centerTitle: true,
          backgroundColor: const Color(0xFF5A8BBA),
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            Obx(() => controller.showingVisitCards.value
                ? IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => Get.to(() => PDFViewerScreen(
                assetPath: 'assets/pdfs/about_us.pdf',
              )),
            )
                : SizedBox.shrink()),
          ],
        ),
        body: Obx(() => controller.showingVisitCards.value
            ? _buildVerticalList()
            : _buildGrievanceForm()
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildVerticalList() {
    return Obx(() => ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: controller.inmates.length,
      itemBuilder: (context, index) {
        final inmate = controller.inmates[index];
        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 1),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Serial No. and Prisoner Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.black, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${inmate['prisonerName']} (#${inmate['serial']})",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.blue),
                      onPressed: () {
                        Get.snackbar(
                          'Info',
                          'Download functionality coming soon',
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                        );
                      },
                    ),
                  ],
                ),
                // Category
                Row(
                  children: [
                    const Icon(Icons.badge, size: 18, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Category: ${inmate['category']}",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.navigateToPrisonerDetails(inmate),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildInfoRow(Icons.location_on, "Prison: ${inmate['prison']}"),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    ));
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrievanceForm() {
    return Form(
      key: controller.formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            FormSectionTitle(title: 'Grievance Details'),
        SizedBox(height: 20),

        // Prisoner Name
        Obx(() => buildReadOnlyTextField(
          context: Get.context!,
          controller: controller.prisonerNameController,
          label: 'Prisoner Name*',
          hint: 'Enter prisoner Name',
          validator: Validators.validateName,
          readOnly: controller.isReadOnlyMode.value,
          fieldName: 'Prisoner Name',
        )),
        SizedBox(height: 20),

        // Prison Address
        Obx(() => buildReadOnlyTextField(
          context: Get.context!,
          controller: controller.prisonController,
          label: 'Prison*',
          hint: 'Prison',
          validator: (value) => value!.isEmpty ? 'Prison is required' : null,
          readOnly: controller.isReadOnlyMode.value,
          maxLines: 2,
          fieldName: 'Prison',
        )),
        SizedBox(height: 20),

        // Category Dropdown
        Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedCategory.value,
          decoration: InputDecoration(
            labelText: 'Select Category*',
            border: OutlineInputBorder(),
          ),
          items: controller.categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) => controller.setSelectedCategory(value),
          validator: (value) => value == null || value == 'SELECT'
              ? 'Please select Category'
              : null,
        )),
        SizedBox(height: 16),

        // Message Field
        CustomTextField(
          controller: controller.messageController,
          label: 'Message*',
          hint: 'Enter issue description',
          maxLines: 5,
          maxLength: 500,
          validator: (value) {
            final pattern = RegExp(r'^[a-zA-Z0-9\s.,;!?()\-]+$');
            if (value == null || value.isEmpty) {
              return 'Message is required';
            } else if (!pattern.hasMatch(value)) {
              return 'Only letters, numbers and . , ; ! ? - ( ) are allowed';
            }
            return null;
          },
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              final allowedPattern = RegExp(r'^[a-zA-Z0-9\s.,;!?()\-]*$');
              if (allowedPattern.hasMatch(newValue.text)) {
                return newValue;
              }
              return oldValue;
            }),
          ],
        ),
        SizedBox(height: 30),

        // Submit Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(() => controller.isLoading.value
                  ? Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Submitting...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )

                  : CustomButton(
                text: 'Save',
                onPressed: controller.submitGrievance,
              )),
            ),
          ],
        ),
            ],
        ),
      ),
    );
  }


  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF5A8BBA),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Obx(() => Row(
            children: [
              buildNavItem(
                selectedIndex: controller.selectedIndex.value,
                index: 0,
                icon: Icons.dashboard,
                label: 'Dashboard',
                onTap: () => Get.offAll(() => HomeScreen(selectedIndex: 0)),
              ),
              buildNavItem(
                selectedIndex: controller.selectedIndex.value,
                index: 1,
                icon: Icons.directions_walk,
                label: 'Meeting',
                onTap: () => Get.offAll(() => MeetFormScreen(
                  selectedIndex: 1,
                  showVisitCards: true,
                )),
              ),
              buildNavItem(
                selectedIndex: controller.selectedIndex.value,
                index: 2,
                icon: Icons.gavel,
                label: 'Parole',
                onTap: () => Get.offAll(() => ParoleScreen(selectedIndex: 2)),
              ),
              buildNavItem(
                selectedIndex: controller.selectedIndex.value,
                index: 3,
                icon: Icons.report_problem,
                label: 'Grievance',
                onTap: () => Get.offAll(() => GrievanceDetailsScreen(
                  selectedIndex: 3,
                  fromNavbar: true,
                )),
              ),
            ],
          )),
        ),
      ),
    );
  }
}