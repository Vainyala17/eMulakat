class AppConstants {
  static const String appName = 'eMulakat';
  static const String baseUrl = 'https://eprisons.nic.in/npip/public/';
  static const String helpUrl = 'https://eprisons.nic.in/npip/public/DashBoard';

  // ID Proof Types
  static const List<String> idProofTypes = [
    'Aadhar Card',
    'Pan Card',
    'Driving License',
    'Passport',
    'Voter ID',
    'Others',
    'Not Available'
  ];

  // ID Proof Limits
  static const Map<String, int> idProofLimits = {
    'Aadhar Card': 12,
    'Pan Card': 10,
    'Driving License': 16,
    'Passport': 8,
    'Voter ID': 10,
    'Others': 20,
    'Not Available': 0,
  };

  // Languages
  final Map<String, String> _languages = {
    'English': 'en',
    'Hindi': 'hi',
    'Marathi': 'mr',
  };

  // Font Sizes
  static const List<String> fontSizes = ['A-', 'A', 'A+'];
}