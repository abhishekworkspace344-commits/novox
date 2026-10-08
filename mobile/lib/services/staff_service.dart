import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/staff_model.dart';

class StaffService {
  final ApiClient apiClient;

  StaffService(this.apiClient);

  Future<StaffModel> getProfile() async {
    final response = await apiClient.dio.get(
      ApiConstants.staffProfile,
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final staffData = data['staff'];

      if (staffData is Map<String, dynamic>) {
        return StaffModel.fromJson(staffData);
      }

      return StaffModel.fromJson(data);
    }

    throw Exception('Invalid staff profile response');
  }
}