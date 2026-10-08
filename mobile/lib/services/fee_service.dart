import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/fee_model.dart';
import '../models/student_payment_model.dart';

class FeeService {
  final ApiClient apiClient;

  FeeService(this.apiClient);

  // ============================================================
  // MY FEES
  // ============================================================

  Future<List<FeeModel>> getMyFees() async {
    final response = await apiClient.dio.get(
      ApiConstants.myFees,
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => FeeModel.fromJson(item),
        )
        .toList();
  }

  // ============================================================
  // MY PAYMENT HISTORY
  // ============================================================

  Future<List<StudentPaymentModel>>
      getMyPaymentHistory() async {
    final response = await apiClient.dio.get(
      ApiConstants.myPaymentHistory,
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(
          (item) =>
              StudentPaymentModel.fromJson(item),
        )
        .toList();
  }

  // ============================================================
  // DOWNLOAD MY RECEIPT
  // ============================================================

  Future<List<int>> downloadMyReceipt(
    String receiptNumber,
  ) async {
    final response =
        await apiClient.dio.get<List<int>>(
      ApiConstants.feeReceiptPdf(
        receiptNumber,
      ),
      options: Options(
        responseType:
            ResponseType.bytes,
      ),
    );

    return response.data ?? [];
  }
}