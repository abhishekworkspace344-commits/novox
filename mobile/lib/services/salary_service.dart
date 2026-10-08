import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/salary_model.dart';

class SalaryService {
  final ApiClient apiClient;

  SalaryService(this.apiClient);

  // ============================================================
  // MY SALARY SLIPS
  // ============================================================

  Future<List<SalaryModel>>
      getMySalarySlips() async {
    final response =
        await apiClient.dio.get(
      ApiConstants.staffSalary,
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(
          (item) =>
              SalaryModel.fromJson(item),
        )
        .toList();
  }
}