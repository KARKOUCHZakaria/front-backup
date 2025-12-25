import 'package:json_annotation/json_annotation.dart';

part 'application.g.dart';

/// Model representing a credit application from the backend
@JsonSerializable()
class Application {
  final int id;
  final int? userId;

  // Demographic Information
  final String? codeGender;
  final int? daysBirth;
  final String? nameEducationType;
  final String? nameFamilyStatus;
  final int? cntChildren;

  // Financial Information
  final double? amtIncomeTotal;
  final double? amtCredit;
  final double? amtAnnuity;
  final double? amtGoodsPrice;

  // Employment Information
  final int? daysEmployed;
  final String? occupationType;
  final String? organizationType;

  // Contract Information
  final String? nameContractType;
  final String? nameIncomeType;
  final String? nameHousingType;

  // Additional Features
  final String? flagOwnCar;
  final String? flagOwnRealty;
  final int? regionRatingClient;
  final double? extSource1;
  final double? extSource2;
  final double? extSource3;

  // Application Status
  final String status;
  final String? applicationNumber;
  final int? creditScore; // ML-calculated credit score (300-850)
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? submittedAt;
  final DateTime? processedAt;

  Application({
    required this.id,
    this.userId,
    this.codeGender,
    this.daysBirth,
    this.nameEducationType,
    this.nameFamilyStatus,
    this.cntChildren,
    this.amtIncomeTotal,
    this.amtCredit,
    this.amtAnnuity,
    this.amtGoodsPrice,
    this.daysEmployed,
    this.occupationType,
    this.organizationType,
    this.nameContractType,
    this.nameIncomeType,
    this.nameHousingType,
    this.flagOwnCar,
    this.flagOwnRealty,
    this.regionRatingClient,
    this.extSource1,
    this.extSource2,
    this.extSource3,
    required this.status,
    this.applicationNumber,
    this.creditScore,
    required this.createdAt,
    this.updatedAt,
    this.submittedAt,
    this.processedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationToJson(this);

  /// Get a human-readable status display
  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      case 'PENDING':
        return 'Pending';
      case 'PROCESSING':
        return 'Processing';
      case 'UNDER_REVIEW':
        return 'Under Review';
      case 'CANCELLED':
        return 'Cancelled';
      case 'DRAFT':
        return 'Draft';
      default:
        return status;
    }
  }

  /// Get status color based on application status
  String get statusColor {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return '#28A745'; // Green
      case 'REJECTED':
        return '#DC3545'; // Red
      case 'PENDING':
        return '#FFC107'; // Yellow
      case 'PROCESSING':
        return '#17A2B8'; // Blue
      case 'UNDER_REVIEW':
        return '#6C757D'; // Gray
      case 'CANCELLED':
        return '#6C757D'; // Gray
      case 'DRAFT':
        return '#6C757D'; // Gray
      default:
        return '#6C757D';
    }
  }

  /// Get loan amount for display
  String get loanAmountDisplay {
    if (amtCredit != null) {
      return '\$${(amtCredit! / 1000).toStringAsFixed(1)}K';
    }
    return '\$0';
  }
}
