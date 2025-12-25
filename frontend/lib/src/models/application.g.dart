// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Application _$ApplicationFromJson(Map<String, dynamic> json) => Application(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  codeGender: json['codeGender'] as String?,
  daysBirth: (json['daysBirth'] as num?)?.toInt(),
  nameEducationType: json['nameEducationType'] as String?,
  nameFamilyStatus: json['nameFamilyStatus'] as String?,
  cntChildren: (json['cntChildren'] as num?)?.toInt(),
  amtIncomeTotal: (json['amtIncomeTotal'] as num?)?.toDouble(),
  amtCredit: (json['amtCredit'] as num?)?.toDouble(),
  amtAnnuity: (json['amtAnnuity'] as num?)?.toDouble(),
  amtGoodsPrice: (json['amtGoodsPrice'] as num?)?.toDouble(),
  daysEmployed: (json['daysEmployed'] as num?)?.toInt(),
  occupationType: json['occupationType'] as String?,
  organizationType: json['organizationType'] as String?,
  nameContractType: json['nameContractType'] as String?,
  nameIncomeType: json['nameIncomeType'] as String?,
  nameHousingType: json['nameHousingType'] as String?,
  flagOwnCar: json['flagOwnCar'] as String?,
  flagOwnRealty: json['flagOwnRealty'] as String?,
  regionRatingClient: (json['regionRatingClient'] as num?)?.toInt(),
  extSource1: (json['extSource1'] as num?)?.toDouble(),
  extSource2: (json['extSource2'] as num?)?.toDouble(),
  extSource3: (json['extSource3'] as num?)?.toDouble(),
  status: json['status'] as String,
  applicationNumber: json['applicationNumber'] as String?,
  creditScore: (json['creditScore'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  processedAt: json['processedAt'] == null
      ? null
      : DateTime.parse(json['processedAt'] as String),
);

Map<String, dynamic> _$ApplicationToJson(Application instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'codeGender': instance.codeGender,
      'daysBirth': instance.daysBirth,
      'nameEducationType': instance.nameEducationType,
      'nameFamilyStatus': instance.nameFamilyStatus,
      'cntChildren': instance.cntChildren,
      'amtIncomeTotal': instance.amtIncomeTotal,
      'amtCredit': instance.amtCredit,
      'amtAnnuity': instance.amtAnnuity,
      'amtGoodsPrice': instance.amtGoodsPrice,
      'daysEmployed': instance.daysEmployed,
      'occupationType': instance.occupationType,
      'organizationType': instance.organizationType,
      'nameContractType': instance.nameContractType,
      'nameIncomeType': instance.nameIncomeType,
      'nameHousingType': instance.nameHousingType,
      'flagOwnCar': instance.flagOwnCar,
      'flagOwnRealty': instance.flagOwnRealty,
      'regionRatingClient': instance.regionRatingClient,
      'extSource1': instance.extSource1,
      'extSource2': instance.extSource2,
      'extSource3': instance.extSource3,
      'status': instance.status,
      'applicationNumber': instance.applicationNumber,
      'creditScore': instance.creditScore,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'processedAt': instance.processedAt?.toIso8601String(),
    };
