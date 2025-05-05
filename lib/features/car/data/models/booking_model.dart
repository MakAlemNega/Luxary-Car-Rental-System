import 'package:flutter/foundation.dart';

@immutable
class Booking {
  final String id;
  final String carId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status; // pending, confirmed, cancelled, completed
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.carId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  Booking copyWith({
    String? id,
    String? carId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      carId: json['carId'] as String,
      userId: json['userId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalPrice: json['totalPrice'] as double,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking &&
        other.id == id &&
        other.carId == carId &&
        other.userId == userId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.totalPrice == totalPrice &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      carId,
      userId,
      startDate,
      endDate,
      totalPrice,
      status,
      createdAt,
    );
  }
}
