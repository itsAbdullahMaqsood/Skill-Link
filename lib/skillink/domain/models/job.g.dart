// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Job _$JobFromJson(Map<String, dynamic> json) => _Job(
  jobId: json['jobId'] as String,
  userId: json['userId'] as String,
  workerId: json['workerId'] as String?,
  serviceType: json['serviceType'] as String,
  status: $enumDecode(_$JobStatusEnumMap, json['status']),
  scheduledDate: DateTime.parse(json['scheduledDate'] as String),
  finalPrice: (json['finalPrice'] as num?)?.toDouble(),
  bidHistory:
      (json['bidHistory'] as List<dynamic>?)
          ?.map((e) => Bid.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  description: json['description'] as String,
  photoUrls:
      (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  address: StructuredAddress.fromJson(json['address'] as Map<String, dynamic>),
  paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
  paid: json['paid'] as bool? ?? false,
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$JobToJson(_Job instance) => <String, dynamic>{
  'jobId': instance.jobId,
  'userId': instance.userId,
  'workerId': instance.workerId,
  'serviceType': instance.serviceType,
  'status': _$JobStatusEnumMap[instance.status]!,
  'scheduledDate': instance.scheduledDate.toIso8601String(),
  'finalPrice': instance.finalPrice,
  'bidHistory': instance.bidHistory,
  'description': instance.description,
  'photoUrls': instance.photoUrls,
  'address': instance.address,
  'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
  'paid': instance.paid,
  'paidAt': instance.paidAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$JobStatusEnumMap = {
  JobStatus.posted: 'posted',
  JobStatus.workerAccepted: 'workerAccepted',
  JobStatus.bidReceived: 'bidReceived',
  JobStatus.bidAccepted: 'bidAccepted',
  JobStatus.onTheWay: 'onTheWay',
  JobStatus.arrived: 'arrived',
  JobStatus.inProgress: 'inProgress',
  JobStatus.completed: 'completed',
  JobStatus.cancelledNoPenalty: 'cancelledNoPenalty',
  JobStatus.cancelledWithPenalty: 'cancelledWithPenalty',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.inApp: 'inApp',
};
