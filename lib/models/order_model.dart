// order_model.dart
import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  onTheWay,
  delivered,
  cancelled
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DeliveryInfo? deliveryInfo;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.deliveryInfo,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      items: List<OrderItem>.from(
        (map['items'] ?? []).map((item) => OrderItem.fromMap(item)),
      ),
      total: (map['total'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      status: _statusFromString(map['status'] ?? 'pending'),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      deliveryInfo: map['deliveryInfo'] != null ? DeliveryInfo.fromMap(map['deliveryInfo']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deliveryInfo': deliveryInfo?.toMap(),
    };
  }

  static OrderStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ontheway':
      case 'on_the_way':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? total,
    double? subtotal,
    double? deliveryFee,
    double? tax,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DeliveryInfo? deliveryInfo,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      total: total ?? this.total,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'],
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
    };
  }
}

class DeliveryInfo {
  final String address;
  final String? phone;
  final String? instructions;

  DeliveryInfo({
    required this.address,
    this.phone,
    this.instructions,
  });

  factory DeliveryInfo.fromMap(Map<String, dynamic> map) {
    return DeliveryInfo(
      address: map['address'] ?? '',
      phone: map['phone'],
      instructions: map['instructions'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'phone': phone,
      'instructions': instructions,
    };
  }
}