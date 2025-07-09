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
  bool isPhysicalVisit;

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
    required this.isPhysicalVisit,
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
      'isPhysicalVisit': isPhysicalVisit ? 1 : 0,
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
      isPhysicalVisit: map['isPhysicalVisit'] == 1,
    );
  }
}