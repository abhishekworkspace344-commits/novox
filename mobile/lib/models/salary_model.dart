class SalaryModel {
  final int id;
  final int staffId;
  final int month;
  final int year;
  final double basicSalary;
  final double allowance;
  final double deduction;
  final double netSalary;
  final String status;

  SalaryModel({
    required this.id,
    required this.staffId,
    required this.month,
    required this.year,
    required this.basicSalary,
    required this.allowance,
    required this.deduction,
    required this.netSalary,
    required this.status,
  });

  factory SalaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SalaryModel(
      id: json["id"],
      staffId: json["staff_id"],
      month: json["month"],
      year: json["year"],
      basicSalary:
          double.parse(
        json["basic_salary"].toString(),
      ),
      allowance:
          double.parse(
        json["allowance"].toString(),
      ),
      deduction:
          double.parse(
        json["deduction"].toString(),
      ),
      netSalary:
          double.parse(
        json["net_salary"].toString(),
      ),
      status: json["status"],
    );
  }
}