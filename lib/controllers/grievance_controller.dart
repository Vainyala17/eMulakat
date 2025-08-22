// lib/controllers/grievance_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/visitor_model.dart';

class GrievanceController extends GetxController {
  // Form controllers
  final prisonerNameController = TextEditingController();
  final prisonController = TextEditingController();
  final messageController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Observable variables
  var isLoading = false.obs;
  var selectedCategory = Rx<String?>(null);
  var showingVisitCards = false.obs;
  var selectedIndex = 0.obs;
  var isReadOnlyMode = false.obs;

  // Data
  var inmates = <Map<String, dynamic>>[].obs;
  var visitData = <String, List<VisitorModel>>{}.obs;

  final List<String> categories = [
    'SELECT',
    'III Treated by the prison authorities',
    'Basic Facilities not provided inside prison',
    'Manhandling by co prisoners',
    'Others'
  ];

  @override
  void onInit() {
    super.onInit();
    loadInmates();
    initializeVisitData();
  }

  @override
  void onClose() {
    prisonerNameController.dispose();
    prisonController.dispose();
    messageController.dispose();
    super.onClose();
  }

  // Initialize with dummy data
  void loadInmates() {
    inmates.value = [
      {
        "serial": 1,
        "prisonerName": "Sid Kumar",
        "category": "III Treated by the prison authorities",
        "prison": "CENTRAL JAIL NO.2, TIHAR",
      },
      {
        "serial": 2,
        "prisonerName": "Dilip Mhatre",
        "category": "Manhandling by co prisoners",
        "prison": "CENTRAL JAIL NO.2, TIHAR",
      },
      {
        "serial": 3,
        "prisonerName": "Nirav Rao",
        "category": "other",
        "prison": "PHQ",
      },
      {
        "serial": 4,
        "prisonerName": "Mahesh Patil",
        "category": "Basic Facilities not provided inside prison",
        "prison": "CENTRAL JAIL NO.2, TIHAR",
      },
      {
        "serial": 5,
        "prisonerName": "Ramesh Dodhia",
        "category": "Manhandling by co prisoners",
        "prison": "PHQ",
      }
    ];
  }

  // Initialize visit data
  void initializeVisitData() {
    visitData.value = {
      'Grievance': [],
    };
  }

  // Set screen mode and prefill data
  void setScreenMode({
    required bool fromRegisteredInmates,
    required bool showVisitCards,
    required int selectedIdx,
    String? prefilledPrisonerName,
    String? prefilledPrison,
  }) {
    selectedIndex.value = selectedIdx;

    if (fromRegisteredInmates) {
      showingVisitCards.value = false;
      isReadOnlyMode.value = true;

      // Populate prefilled values
      if (prefilledPrisonerName != null) {
        prisonerNameController.text = prefilledPrisonerName;
      }
      if (prefilledPrison != null) {
        prisonController.text = prefilledPrison;
      }
    } else {
      showingVisitCards.value = showVisitCards;
      isReadOnlyMode.value = false;
    }
  }

  // Toggle between visit cards and form
  void toggleView() {
    showingVisitCards.value = !showingVisitCards.value;
  }

  // Set selected category
  void setSelectedCategory(String? category) {
    selectedCategory.value = category;
  }

  // Handle form submission
  Future<void> submitGrievance() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // Prepare request body
      Map<String, String> requestBody = {
        'prisonerName': prisonerNameController.text,
        'prison': prisonController.text,
        'category': selectedCategory.value ?? '',
        'message': messageController.text,
      };

      // Call API service
      final response = await ApiService.raiseGrievanceRequest(requestBody);

      // Show success message
      Get.snackbar(
        'Success',
        response['message'] ?? 'Grievance request submitted successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
        icon: Icon(Icons.check_circle, color: Colors.white),
      );

      // Navigate back after delay
      await Future.delayed(Duration(seconds: 1));
      Get.back();

    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form
  void clearForm() {
    prisonerNameController.clear();
    prisonController.clear();
    messageController.clear();
    selectedCategory.value = null;
  }

  // Navigate to prisoner details
  void navigateToPrisonerDetails(Map<String, dynamic> inmate) {
    Get.toNamed('/grievance', arguments: {
      'selectedIndex': 3,
      'fromRegisteredInmates': true,
      'prefilledPrisonerName': inmate['prisonerName'],
      'prefilledPrison': inmate['prison'],
    });
  }

  // Load dashboard data
  Future<void> loadDashboard() async {
    try {
      final api = ApiService();
      final dashboard = await api.getDashboardSummary("7702000725");
      print('Dashboard data: $dashboard');
    } catch (e) {
      print('Error loading dashboard: $e');
    }
  }
}