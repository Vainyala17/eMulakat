enum VisitStatus {
  pending,
  upcoming,
  completed,
  expired,
}

class VisitorModel {
  final String id;
  final String visitorName;
  final String prisonerName;
  final String prisonerFatherName;
  final String relation;
  final DateTime visitDate;
  final String startTime;
  final String endTime;
  final String jail;
  final String address;
  final bool mode; // true for physical, false for video
  final VisitStatus status;
  final String fatherName;
  final String gender;
  final int age;
  final String idProof;
  final String idNumber;
  final String? imagePath;
  final bool isInternational;
  final String? email;
  final String? mobile;
  final String state;
  final int additionalVisitors;
  final List<String> additionalVisitorNames;
  final int prisonerAge;
  final String prisonerGender;
  final String dayOfWeek;
  final String? videoLink;
  final String prison;
  final String? officer;
  final String? leaveFromDate;
  final String? leaveToDate;
  final String? reason;
  final String? grievanceCategory;
  final String? grievance;
  final String? meetingMode;
  final String? reqVisitDate;
  final String? apprVisitDate;
  final String? remarks;

  VisitorModel({
    required this.id,
    required this.visitorName,
    required this.prisonerName,
    required this.prisonerFatherName,
    required this.relation,
    required this.visitDate,
    required this.startTime,
    required this.endTime,
    required this.jail,
    required this.address,
    required this.mode,
    required this.status,
    required this.fatherName,
    required this.gender,
    required this.age,
    required this.idProof,
    required this.idNumber,
    this.imagePath,
    required this.isInternational,
    this.email,
    this.mobile,
    required this.state,
    required this.additionalVisitors,
    required this.additionalVisitorNames,
    required this.prisonerAge,
    required this.prisonerGender,
    required this.dayOfWeek,
    required this.prison,
    this.videoLink,
    this.officer,
    this.leaveFromDate,
    this.leaveToDate,
    this.reason,
    this.grievanceCategory,
    this.grievance,
    this.meetingMode,
    this.reqVisitDate,
    this.apprVisitDate,
    this.remarks,
  });

  // Factory constructor for creating VisitorModel from API JSON
  factory VisitorModel.fromApiJson(Map<String, dynamic> json, String visitType) {
    VisitStatus status = _parseVisitStatus(json['request_status']?.toString() ?? 'pending');
    DateTime visitDate = _parseDate(json['req_visit_date'] ?? json['leave_from_date'] ?? '');

    return VisitorModel(
      id: json['regn_no']?.toString() ?? '',
      visitorName: json['visitor_name']?.toString() ?? 'Visitor',
      prisonerName: json['prisoner_name']?.toString() ?? '',
      prisonerFatherName: json['father_name']?.toString() ?? '',
      relation: json['relation']?.toString() ?? 'Family',
      visitDate: visitDate,
      startTime: json['start_time']?.toString() ?? '10:00',
      endTime: json['end_time']?.toString() ?? '12:00',
      jail: json['jail']?.toString() ?? 'Central Jail',
      address: json['spent_address']?.toString() ?? '',
      mode: (json['meeting_mode']?.toString().toLowerCase() == 'physical'),
      status: status,
      fatherName: json['visitor_father_name']?.toString() ?? '',
      gender: json['visitor_gender']?.toString() ?? '',
      age: int.tryParse(json['visitor_age']?.toString() ?? '0') ?? 0,
      idProof: json['id_proof']?.toString() ?? '',
      idNumber: json['id_number']?.toString() ?? '',
      imagePath: json['image_path']?.toString(),
      isInternational: json['is_international']?.toString().toLowerCase() == 'true',
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
      state: json['state']?.toString() ?? '',
      additionalVisitors: int.tryParse(json['additional_visitors']?.toString() ?? '0') ?? 0,
      additionalVisitorNames: (json['additional_visitor_names']?.toString() ?? '')
          .split(',')
          .where((name) => name.trim().isNotEmpty)
          .toList(),
      prisonerAge: int.tryParse(json['prisoner_age']?.toString() ?? '0') ?? 0,
      prisonerGender: json['prisoner_gender']?.toString() ?? '',
      dayOfWeek: json['day_of_week']?.toString() ?? '',
      prison: json['prison']?.toString() ?? '',
      videoLink: json['video_link']?.toString(),
      officer: json['officer']?.toString(),
      leaveFromDate: json['leave_from_date']?.toString(),
      leaveToDate: json['leave_to_date']?.toString(),
      reason: json['reason']?.toString(),
      grievanceCategory: json['grievance_category']?.toString(),
      grievance: json['grievance']?.toString(),
      meetingMode: json['meeting_mode']?.toString(),
      reqVisitDate: json['req_visit_date']?.toString(),
      apprVisitDate: json['appr_visit_date']?.toString(),
      remarks: json['remarks']?.toString(),
    );
  }

  // Helper method to parse visit status
  static VisitStatus _parseVisitStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return VisitStatus.pending;
      case 'completed':
        return VisitStatus.completed;
      case 'upcoming':
        return VisitStatus.upcoming;
      case 'expired':
        return VisitStatus.expired;
      default:
        return VisitStatus.pending;
    }
  }

  // Helper method to parse date string
  static DateTime _parseDate(String dateString) {
    if (dateString.isEmpty) return DateTime.now();

    try {
      // Assuming format is DD/MM/YYYY
      List<String> parts = dateString.split('/');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing date: $dateString');
    }

    return DateTime.now();
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'regn_no': id,
      'visitor_name': visitorName,
      'prisoner_name': prisonerName,
      'father_name': prisonerFatherName,
      'relation': relation,
      'visit_date': '${visitDate.day}/${visitDate.month}/${visitDate.year}',
      'start_time': startTime,
      'end_time': endTime,
      'jail': jail,
      'address': address,
      'mode': mode ? 'Physical' : 'Video',
      'status': status.toString().split('.').last,
      'visitor_father_name': fatherName,
      'visitor_gender': gender,
      'visitor_age': age,
      'id_proof': idProof,
      'id_number': idNumber,
      'image_path': imagePath,
      'is_international': isInternational,
      'email': email,
      'mobile': mobile,
      'state': state,
      'additional_visitors': additionalVisitors,
      'additional_visitor_names': additionalVisitorNames.join(','),
      'prisoner_age': prisonerAge,
      'prisoner_gender': prisonerGender,
      'day_of_week': dayOfWeek,
      'prison': prison,
      'video_link': videoLink,
      'officer': officer,
      if (leaveFromDate != null) 'leave_from_date': leaveFromDate,
      if (leaveToDate != null) 'leave_to_date': leaveToDate,
      if (reason != null) 'reason': reason,
      if (grievanceCategory != null) 'grievance_category': grievanceCategory,
      if (grievance != null) 'grievance': grievance,
      if (meetingMode != null) 'meeting_mode': meetingMode,
      if (reqVisitDate != null) 'req_visit_date': reqVisitDate,
      if (apprVisitDate != null) 'appr_visit_date': apprVisitDate,
      if (remarks != null) 'remarks': remarks,
    };
  }

  // Convert to local database JSON
  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'visitorName': visitorName,
      'fatherName': fatherName,
      'address': address,
      'gender': gender,
      'age': age,
      'idProof': idProof,
      'idNumber': idNumber,
      'imagePath': imagePath,
      'isInternational': isInternational ? 1 : 0,
      'email': email,
      'mobile': mobile,
      'state': state,
      'visitDate': visitDate.toIso8601String(),
      'additionalVisitors': additionalVisitors,
      'additionalVisitorNames': additionalVisitorNames.join(','),
      'prisonerName': prisonerName,
      'prisonerFatherName': prisonerFatherName,
      'prisonerAge': prisonerAge,
      'prisonerGender': prisonerGender,
      'mode': mode ? 1 : 0,
      'status': status.index,
      'startTime': startTime,
      'endTime': endTime,
      'jail': jail,
      'relation': relation,
      'dayOfWeek': dayOfWeek,
      'prison': prison,
      'videoLink': videoLink,
      'officer': officer,
    };
  }

  // Create a copy with updated fields
  VisitorModel copyWith({
    String? id,
    String? visitorName,
    String? prisonerName,
    String? prisonerFatherName,
    String? relation,
    DateTime? visitDate,
    String? startTime,
    String? endTime,
    String? jail,
    String? address,
    bool? mode,
    VisitStatus? status,
    String? fatherName,
    String? gender,
    int? age,
    String? idProof,
    String? idNumber,
    String? imagePath,
    bool? isInternational,
    String? email,
    String? mobile,
    String? state,
    int? additionalVisitors,
    List<String>? additionalVisitorNames,
    int? prisonerAge,
    String? prisonerGender,
    String? dayOfWeek,
    String? prison,
    String? videoLink,
    String? officer,
    String? leaveFromDate,
    String? leaveToDate,
    String? reason,
    String? grievanceCategory,
    String? grievance,
    String? meetingMode,
    String? reqVisitDate,
    String? apprVisitDate,
    String? remarks,
  }) {
    return VisitorModel(
      id: id ?? this.id,
      visitorName: visitorName ?? this.visitorName,
      prisonerName: prisonerName ?? this.prisonerName,
      prisonerFatherName: prisonerFatherName ?? this.prisonerFatherName,
      relation: relation ?? this.relation,
      visitDate: visitDate ?? this.visitDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      jail: jail ?? this.jail,
      address: address ?? this.address,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      fatherName: fatherName ?? this.fatherName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      idProof: idProof ?? this.idProof,
      idNumber: idNumber ?? this.idNumber,
      imagePath: imagePath ?? this.imagePath,
      isInternational: isInternational ?? this.isInternational,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      state: state ?? this.state,
      additionalVisitors: additionalVisitors ?? this.additionalVisitors,
      additionalVisitorNames: additionalVisitorNames ?? this.additionalVisitorNames,
      prisonerAge: prisonerAge ?? this.prisonerAge,
      prisonerGender: prisonerGender ?? this.prisonerGender,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      prison: prison ?? this.prison,
      videoLink: videoLink ?? this.videoLink,
      officer: officer ?? this.officer,
      leaveFromDate: leaveFromDate ?? this.leaveFromDate,
      leaveToDate: leaveToDate ?? this.leaveToDate,
      reason: reason ?? this.reason,
      grievanceCategory: grievanceCategory ?? this.grievanceCategory,
      grievance: grievance ?? this.grievance,
      meetingMode: meetingMode ?? this.meetingMode,
      reqVisitDate: reqVisitDate ?? this.reqVisitDate,
      apprVisitDate: apprVisitDate ?? this.apprVisitDate,
      remarks: remarks ?? this.remarks,
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type;
  final bool isRead;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isRead,
    this.actionUrl,
  });

  // Factory constructor from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      type: json['type']?.toString() ?? '',
      isRead: json['is_read']?.toString().toLowerCase() == 'true',
      actionUrl: json['action_url']?.toString(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'is_read': isRead,
      'action_url': actionUrl,
    };
  }

  // Copy with method
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    String? type,
    bool? isRead,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}