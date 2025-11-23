import 'package:cloud_firestore/cloud_firestore.dart';

class WaterBottleModel {
  final String docId;
  final String name;
  final String description;
  final int size;
  final double price;
  final double emptyBottlePrice;
  final String? imageUrl;
  final List<String>? images;
  final String merchantId;
  final String uid;
  final bool inStock;
  final int quantity;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  WaterBottleModel({
    required this.docId,
    required this.name,
    required this.description,
    required this.size,
    required this.price,
    required this.emptyBottlePrice,
    this.imageUrl,
    this.images,
    required this.merchantId,
    required this.uid,
    this.inStock = true,
    this.quantity = 0,
    this.category = "Water Bottle",
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore -> Model (defensive parsing)
  factory WaterBottleModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    final size = (map['size'] is num) ? (map['size'] as num).toInt() : int.tryParse('${map['size'] ?? 0}') ?? 0;
    final price = (map['price'] is num) ? (map['price'] as num).toDouble() : double.tryParse('${map['price'] ?? 0}') ?? 0.0;
    final emptyPrice = (map['emptyBottlePrice'] ?? map['emptyBottlePrice']) is num
        ? ((map['emptyBottlePrice'] ?? map['emptyBottlePrice']) as num).toDouble()
        : double.tryParse('${map['emptyBottlePrice'] ?? map['emptyBottlePrice'] ?? 0}') ?? 0.0;

    return WaterBottleModel(
      docId: id,
      name: (map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      size: size,
      price: price,
      emptyBottlePrice: emptyPrice,
      imageUrl: map['imageUrl'] != null && map['imageUrl'] is String ? map['imageUrl'] as String : null,
      images: map['images'] != null ? List<String>.from((map['images'] as List).map((e) => e.toString())) : null,
      merchantId: (map['merchantId'] ?? '').toString(),
      uid: (map['uid'] ?? '').toString(),
      inStock: map['inStock'] is bool ? map['inStock'] as bool : ((map['inStock'] == null) ? true : map['inStock'].toString() == 'true'),
      quantity: (map['quantity'] is num) ? (map['quantity'] as num).toInt() : int.tryParse('${map['quantity'] ?? 0}') ?? 0,
      category: (map['category'] ?? 'Water Bottle').toString(),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  /// Model -> Firestore map (used only if you want to write model fields directly)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'size': size,
      'price': price,
      'emptyBottlePrice': emptyBottlePrice,
      'imageUrl': imageUrl ?? '',
      'images': images ?? [],
      'merchantId': merchantId,
      'uid': uid,
      'inStock': inStock,
      'quantity': quantity,
      'category': category,
      // createdAt/updatedAt are usually set server-side using FieldValue.serverTimestamp()
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
