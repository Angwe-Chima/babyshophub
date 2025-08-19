// models/order_model.dart - Updated and consistent version
class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final List<OrderItem> items;
  final double total;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final String shippingAddress;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DeliveryInfo? deliveryInfo;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.items,
    required this.total,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.shippingAddress,
    required this.status,
    required this.paymentStatus,
    this.trackingNumber,
    required this.createdAt,
    this.updatedAt,
    this.deliveryInfo,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromMap(item))
          .toList() ??
          [],
      total: (map['total'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      shippingAddress: map['shippingAddress'] ?? '',
      status: OrderStatus.values.firstWhere(
            (status) => status.name == (map['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
            (status) => status.name == (map['paymentStatus'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      trackingNumber: map['trackingNumber'],
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt'] is String
          ? DateTime.parse(map['updatedAt'])
          : map['updatedAt']?.toDate(),
      deliveryInfo: map['deliveryInfo'] != null
          ? DeliveryInfo.fromMap(map['deliveryInfo'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'shippingAddress': shippingAddress,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'trackingNumber': trackingNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deliveryInfo': deliveryInfo?.toMap(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? userName,
    List<OrderItem>? items,
    double? total,
    double? subtotal,
    double? deliveryFee,
    double? tax,
    String? shippingAddress,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    DeliveryInfo? deliveryInfo,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      items: items ?? this.items,
      total: total ?? this.total,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      trackingNumber: trackingNumber ?? this.trackingNumber,
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

  double get totalPrice => price * quantity;
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

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  onTheWay,
  delivered,
  cancelled,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}