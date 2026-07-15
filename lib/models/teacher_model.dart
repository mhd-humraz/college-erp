class TeacherModel {
  final String name;
  final String email;
  final String employeeId;
  final String designation;
  final String department;

  TeacherModel({
    required this.name,
    required this.email,
    required this.employeeId,
    required this.designation,
    required this.department,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      name: json["user"]["name"],
      email: json["user"]["email"],
      employeeId: json["employeeId"],
      designation: json["designation"],
      department: json["department"]["name"],
    );
  }
}