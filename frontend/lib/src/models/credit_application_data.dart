import 'package:json_annotation/json_annotation.dart';

part 'credit_application_data.g.dart';

/// Model representing the credit application data sent to the ML backend
/// This maps to the features expected by the Home Credit model
@JsonSerializable()
class CreditApplicationData {
  // Demographic Information
  @JsonKey(name: 'CODE_GENDER')
  final String? codeGender; // 'M', 'F', 'XNA'
  
  @JsonKey(name: 'DAYS_BIRTH')
  final int? daysBirth; // Negative age in days
  
  @JsonKey(name: 'NAME_EDUCATION_TYPE')
  final String? nameEducationType;
  
  @JsonKey(name: 'NAME_FAMILY_STATUS')
  final String? nameFamilyStatus;
  
  @JsonKey(name: 'CNT_CHILDREN')
  final int? cntChildren;
  
  // Financial Information
  @JsonKey(name: 'AMT_INCOME_TOTAL')
  final double? amtIncomeTotal;
  
  @JsonKey(name: 'AMT_CREDIT')
  final double? amtCredit;
  
  @JsonKey(name: 'AMT_ANNUITY')
  final double? amtAnnuity;
  
  @JsonKey(name: 'AMT_GOODS_PRICE')
  final double? amtGoodsPrice;
  
  // Employment Information
  @JsonKey(name: 'DAYS_EMPLOYED')
  final int? daysEmployed; // Negative days employed
  
  @JsonKey(name: 'OCCUPATION_TYPE')
  final String? occupationType;
  
  @JsonKey(name: 'ORGANIZATION_TYPE')
  final String? organizationType;
  
  // Contract Information
  @JsonKey(name: 'NAME_CONTRACT_TYPE')
  final String? nameContractType; // 'Cash loans' or 'Revolving loans'
  
  @JsonKey(name: 'NAME_INCOME_TYPE')
  final String? nameIncomeType;
  
  @JsonKey(name: 'NAME_HOUSING_TYPE')
  final String? nameHousingType;
  
  // Additional Features
  @JsonKey(name: 'FLAG_OWN_CAR')
  final String? flagOwnCar; // 'Y' or 'N'
  
  @JsonKey(name: 'FLAG_OWN_REALTY')
  final String? flagOwnRealty; // 'Y' or 'N'
  
  @JsonKey(name: 'REGION_RATING_CLIENT')
  final int? regionRatingClient;
  
  @JsonKey(name: 'EXT_SOURCE_1')
  final double? extSource1;
  
  @JsonKey(name: 'EXT_SOURCE_2')
  final double? extSource2;
  
  @JsonKey(name: 'EXT_SOURCE_3')
  final double? extSource3;

  CreditApplicationData({
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
  });

  factory CreditApplicationData.fromJson(Map<String, dynamic> json) =>
      _$CreditApplicationDataFromJson(json);

  Map<String, dynamic> toJson() => _$CreditApplicationDataToJson(this);

  /// Create a simplified model from basic form inputs
  factory CreditApplicationData.fromForm({
    required String gender,
    required int age,
    required double income,
    required double loanAmount,
    required double annuity,
    String education = 'Secondary / secondary special',
    String familyStatus = 'Married',
    int children = 0,
    int employmentYears = 5,
    String occupation = 'Laborers',
    String contractType = 'Cash loans',
    String incomeType = 'Working',
    String housingType = 'House / apartment',
    bool ownCar = false,
    bool ownRealty = false,
  }) {
    return CreditApplicationData(
      codeGender: gender == 'Male' ? 'M' : 'F',
      daysBirth: -(age * 365), // Convert age to negative days
      nameEducationType: education,
      nameFamilyStatus: familyStatus,
      cntChildren: children,
      amtIncomeTotal: income,
      amtCredit: loanAmount,
      amtAnnuity: annuity,
      amtGoodsPrice: loanAmount * 0.9, // Estimated goods price
      daysEmployed: -(employmentYears * 365), // Convert to negative days
      occupationType: occupation,
      organizationType: 'Business Entity Type 3',
      nameContractType: contractType,
      nameIncomeType: incomeType,
      nameHousingType: housingType,
      flagOwnCar: ownCar ? 'Y' : 'N',
      flagOwnRealty: ownRealty ? 'Y' : 'N',
      regionRatingClient: 2,
      extSource1: null,
      extSource2: null,
      extSource3: null,
    );
  }
}
