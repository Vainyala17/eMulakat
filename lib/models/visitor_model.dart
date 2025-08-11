import 'package:flutter/material.dart';

enum VisitStatus { pending, completed, expired, upcoming }

class VisitorModel {
  int? id;
  String visitorName;
  String fatherName;
  String address;
  String gender;
  int age;
  String relation;
  String idProof;
  String idNumber;
  String? imagePath;
  bool isInternational;
  String? email;
  String? mobile;
  String state;
  String jail;
  DateTime visitDate;
  int additionalVisitors;
  List<String> additionalVisitorNames;
  String prisonerName;
  String prisonerFatherName;
  int prisonerAge;
  String prisonerGender;
  //bool isPhysicalVisit;
  final VisitStatus status;
  final String startTime;
  final String endTime;
  final String dayOfWeek;
  final String? videoLink;
  final String? officer;
  bool mode;

  VisitorModel({
    this.id,
    required this.visitorName,
    required this.fatherName,
    required this.address,
    required this.gender,
    required this.age,
    required this.relation,
    required this.idProof,
    required this.idNumber,
    this.imagePath,
    required this.isInternational,
    this.email,
    this.mobile,
    required this.state,
    required this.jail,
    required this.visitDate,
    required this.additionalVisitors,
    required this.additionalVisitorNames,
    required this.prisonerName,
    required this.prisonerFatherName,
    required this.prisonerAge,
    required this.prisonerGender,
   // required this.isPhysicalVisit,
    required this.status,
    required this.startTime,
    required this.endTime ,
    required this.dayOfWeek,
    this.videoLink,
    this.officer,
    required this.mode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'visitorName': visitorName,
      'fatherName': fatherName,
      'address': address,
      'gender': gender,
      'age': age,
      'relation': relation,
      'idProof': idProof,
      'idNumber': idNumber,
      'imagePath': imagePath,
      'isInternational': isInternational ? 1 : 0,
      'email': email,
      'mobile': mobile,
      'state': state,
      'jail': jail,
      'visitDate': visitDate.toIso8601String(),
      'additionalVisitors': additionalVisitors,
      'additionalVisitorNames': additionalVisitorNames.join(','),
      'prisonerName': prisonerName,
      'prisonerFatherName': prisonerFatherName,
      'prisonerAge': prisonerAge,
      'prisonerGender': prisonerGender,
      'mode': mode ? 1 : 0,
      'status': status.index,
    };
  }

  factory VisitorModel.fromMap(Map<String, dynamic> map) {
    return VisitorModel(
      id: map['id'],
      visitorName: map['visitorName'],
      fatherName: map['fatherName'],
      address: map['address'],
      gender: map['gender'],
      age: map['age'],
      relation: map['relation'],
      idProof: map['idProof'],
      idNumber: map['idNumber'],
      imagePath: map['imagePath'],
      isInternational: map['isInternational'] == 1,
      email: map['email'],
      mobile: map['mobile'],
      state: map['state'],
      jail: map['jail'],
      visitDate: DateTime.parse(map['visitDate']),
      additionalVisitors: map['additionalVisitors'],
      additionalVisitorNames: map['additionalVisitorNames'].split(','),
      prisonerName: map['prisonerName'],
      prisonerFatherName: map['prisonerFatherName'],
      prisonerAge: map['prisonerAge'],
      prisonerGender: map['prisonerGender'],
      mode: map['mode'] == 1,
      status: map['status'] != null
          ? VisitStatus.values[map['status']]
          : VisitStatus.pending, startTime: '', endTime: '', dayOfWeek: '',
    );
  }
  Color statusColor(VisitStatus status) {
    switch (status) {
      case VisitStatus.completed:
        return Colors.green;
      case VisitStatus.expired:
        return Colors.red;
      case VisitStatus.pending:
        return Colors.orange;
      case VisitStatus.upcoming:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(VisitStatus status) {
    switch (status) {
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.expired:
        return 'Expired';
      case VisitStatus.pending:
        return 'Pending';
      case VisitStatus.upcoming:
        return 'Upcoming';
      default:
        return 'unknown';
    }
  }

}
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type; // 'visit', 'grievance', 'system'
  final bool isRead;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actionUrl,
  });
}