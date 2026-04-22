// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'structured_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StructuredAddress _$StructuredAddressFromJson(Map<String, dynamic> json) =>
    _StructuredAddress(
      street: json['street'] as String,
      area: json['area'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
    );

Map<String, dynamic> _$StructuredAddressToJson(_StructuredAddress instance) =>
    <String, dynamic>{
      'street': instance.street,
      'area': instance.area,
      'city': instance.city,
      'postalCode': instance.postalCode,
    };
