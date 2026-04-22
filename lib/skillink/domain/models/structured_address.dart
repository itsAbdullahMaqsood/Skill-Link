import 'package:freezed_annotation/freezed_annotation.dart';

part 'structured_address.freezed.dart';
part 'structured_address.g.dart';

@freezed
abstract class StructuredAddress with _$StructuredAddress {
  const factory StructuredAddress({
    required String street,
    required String area,
    required String city,
    required String postalCode,
  }) = _StructuredAddress;

  factory StructuredAddress.fromJson(Map<String, dynamic> json) =>
      _$StructuredAddressFromJson(json);
}
