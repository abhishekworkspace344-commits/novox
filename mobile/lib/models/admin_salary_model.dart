class AdminSalaryModel {
  final int id;
  final int staffId;
  final double basicSalary;
  final double allowance;
  final double deduction;
  final String effectiveFrom;

  AdminSalaryModel({
    required this.id,
    required this.staffId,
    required this.basicSalary,
    required this.allowance,
    required this.deduction,
    required this.effectiveFrom,
  });

  factory AdminSalaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminSalaryModel(
      id: json['id'],
      staffId: json['staff_id'],
      basicSalary:
          double.parse(json['basic_salary'].toString()),
      allowance:
          double.parse(json['allowance'].toString()),
      deduction:
          double.parse(json['deduction'].toString()),
      effectiveFrom:
          json['effective_from'],
    );
  }

  double get netSalary =>
      basicSalary + allowance - deduction;
}