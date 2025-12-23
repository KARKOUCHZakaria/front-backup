// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_application_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditApplicationData _$CreditApplicationDataFromJson(
  Map<String, dynamic> json,
) => CreditApplicationData(
  codeGender: json['CODE_GENDER'] as String?,
  daysBirth: (json['DAYS_BIRTH'] as num?)?.toInt(),
  nameEducationType: json['NAME_EDUCATION_TYPE'] as String?,
  nameFamilyStatus: json['NAME_FAMILY_STATUS'] as String?,
  cntChildren: (json['CNT_CHILDREN'] as num?)?.toInt(),
  amtIncomeTotal: (json['AMT_INCOME_TOTAL'] as num?)?.toDouble(),
  amtCredit: (json['AMT_CREDIT'] as num?)?.toDouble(),
  amtAnnuity: (json['AMT_ANNUITY'] as num?)?.toDouble(),
  amtGoodsPrice: (json['AMT_GOODS_PRICE'] as num?)?.toDouble(),
  daysEmployed: (json['DAYS_EMPLOYED'] as num?)?.toInt(),
  occupationType: json['OCCUPATION_TYPE'] as String?,
  organizationType: json['ORGANIZATION_TYPE'] as String?,
  nameContractType: json['NAME_CONTRACT_TYPE'] as String?,
  nameIncomeType: json['NAME_INCOME_TYPE'] as String?,
  nameHousingType: json['NAME_HOUSING_TYPE'] as String?,
  flagOwnCar: json['FLAG_OWN_CAR'] as String?,
  flagOwnRealty: json['FLAG_OWN_REALTY'] as String?,
  regionRatingClient: (json['REGION_RATING_CLIENT'] as num?)?.toInt(),
  extSource1: (json['EXT_SOURCE_1'] as num?)?.toDouble(),
  extSource2: (json['EXT_SOURCE_2'] as num?)?.toDouble(),
  extSource3: (json['EXT_SOURCE_3'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CreditApplicationDataToJson(
  CreditApplicationData instance,
) => <String, dynamic>{
  'CODE_GENDER': instance.codeGender,
  'DAYS_BIRTH': instance.daysBirth,
  'NAME_EDUCATION_TYPE': instance.nameEducationType,
  'NAME_FAMILY_STATUS': instance.nameFamilyStatus,
  'CNT_CHILDREN': instance.cntChildren,
  'AMT_INCOME_TOTAL': instance.amtIncomeTotal,
  'AMT_CREDIT': instance.amtCredit,
  'AMT_ANNUITY': instance.amtAnnuity,
  'AMT_GOODS_PRICE': instance.amtGoodsPrice,
  'DAYS_EMPLOYED': instance.daysEmployed,
  'OCCUPATION_TYPE': instance.occupationType,
  'ORGANIZATION_TYPE': instance.organizationType,
  'NAME_CONTRACT_TYPE': instance.nameContractType,
  'NAME_INCOME_TYPE': instance.nameIncomeType,
  'NAME_HOUSING_TYPE': instance.nameHousingType,
  'FLAG_OWN_CAR': instance.flagOwnCar,
  'FLAG_OWN_REALTY': instance.flagOwnRealty,
  'REGION_RATING_CLIENT': instance.regionRatingClient,
  'EXT_SOURCE_1': instance.extSource1,
  'EXT_SOURCE_2': instance.extSource2,
  'EXT_SOURCE_3': instance.extSource3,
};
