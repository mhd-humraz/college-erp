// lib/models/fee_model.dart
class FeeModel {
  final int totalDues;
  final int amountPaidAccumulated;
  final String status;
  final List<dynamic> receipts;

  FeeModel({
    required this.totalDues,
    required this.amountPaidAccumulated,
    required this.status,
    required this.receipts,
  });

  factory FeeModel.fromJson(Map<String, dynamic> json) {
    return FeeModel(
      totalDues: json['totalDues'] ?? 0,
      amountPaidAccumulated: json['amountPaidAccumulated'] ?? 0,
      status: json['status'] ?? 'Unpaid',
      receipts: json['receipts'] ?? [],
    );
  }
}