import 'package:cloud_firestore/cloud_firestore.dart';

/// Vendor model (clean, null-safe, Firestore-friendly)
class VendorModel {
  // Identifiers
  final String id; // document id
  final String uid; // auth user id
  final String merchantId; // store / merchant id (if any)

  // Basic business info
  final String vendorName;
  final String businessName;
  final String contactPerson;
  final String phoneNumber;
  final String email;

  // Business details & operations
  final String vendorType; // e.g. "RO", "Mineral", "Tanker"
  final String businessAddress;
  final String areaCity;
  final String postalCode;
  final String state;
  final double? latitude;
  final double? longitude;

  // Water / capacity information
  final String waterType; // e.g. "Drinking"
  final String capacityOptions; // e.g. "10L,20L" or JSON string
  final String dailySupply; // textual or numeric-as-string
  final String deliveryArea;
  final String deliveryTimings;

  // Banking / financial
  final String bankName;
  final String accountNumber;
  final String upiId;
  final String ifscCode;
  final String gstNumber;

  // App metadata
  final double earnings;
  final String status; // pending / approved / rejected
  final bool isVerified;
  final bool isActive;

  // Media & KYC
  final Map<String, String> images; // key -> url (aadhar, pan, license, etc.)
  final String videoUrl;

  // Operational constraints and rating
  final int maxOrdersPerDay; // default 100
  final double serviceRadiusKm; // default 5.0 (km)
  final int minOrderQty; // default 1
  final double deliveryCharges; // default 0.0
  final double rating; // average rating
  final int ratingCount; // number of ratings

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Free-form
  final String remarks;

  const VendorModel({
    this.id = '',
    this.uid = '',
    this.merchantId = '',
    this.vendorName = '',
    this.businessName = '',
    this.contactPerson = '',
    this.phoneNumber = '',
    this.email = '',
    this.vendorType = '',
    this.businessAddress = '',
    this.areaCity = '',
    this.postalCode = '',
    this.state = '',
    this.latitude,
    this.longitude,
    this.waterType = '',
    this.capacityOptions = '',
    this.dailySupply = '',
    this.deliveryArea = '',
    this.deliveryTimings = '',
    this.bankName = '',
    this.accountNumber = '',
    this.upiId = '',
    this.ifscCode = '',
    this.gstNumber = '',
    this.earnings = 0.0,
    this.status = 'pending',
    this.isVerified = false,
    this.isActive = false,
    Map<String, String>? images,
    this.videoUrl = '',
    this.maxOrdersPerDay = 100,
    this.serviceRadiusKm = 5.0,
    this.minOrderQty = 1,
    this.deliveryCharges = 0.0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.createdAt,
    this.updatedAt,
    this.remarks = '',
  }) : images = images ?? const {};

  // -----------------------
  // Factories / parsing
  // -----------------------

  /// Parse Firestore `DocumentSnapshot` (handles Timestamp fields).
  factory VendorModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? <String, dynamic>{};
    // Ensure id is set from doc.id if not present in map
    map['id'] = map['id'] ?? doc.id;
    return VendorModel.fromMap(map);
  }

  /// Parse generic Map (handles Timestamp / numeric conversions)
  factory VendorModel.fromMap(Map<String, dynamic> m) {
    DateTime? parseTimestamp(Object? v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    double toDouble(Object? v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    int toInt(Object? v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final imagesMap = <String, String>{};
    if (m['images'] is Map) {
      try {
        (m['images'] as Map).forEach((k, v) {
          imagesMap[k.toString()] = v?.toString() ?? '';
        });
      } catch (_) {}
    }

    return VendorModel(
      id: (m['id'] ?? m['vendorId'] ?? '')?.toString() ?? '',
      uid: (m['uid'] ?? '')?.toString() ?? '',
      merchantId: (m['merchantId'] ?? '')?.toString() ?? '',
      vendorName: (m['vendorName'] ?? '')?.toString() ?? '',
      businessName: (m['bussinessName'] ?? m['businessName'] ?? '')?.toString() ?? '',
      contactPerson: (m['contactPerson'] ?? '')?.toString() ?? '',
      phoneNumber: (m['phoneNumber'] ?? m['number'] ?? '')?.toString() ?? '',
      email: (m['email'] ?? '')?.toString() ?? '',
      vendorType: (m['vendorType'] ?? '')?.toString() ?? '',
      businessAddress: (m['businessAddress'] ?? '')?.toString() ?? '',
      areaCity: (m['areaCity'] ?? '')?.toString() ?? '',
      postalCode: (m['postalCode'] ?? m['zip'] ?? '')?.toString() ?? '',
      state: (m['state'] ?? '')?.toString() ?? '',
      latitude: (m['latitude'] is num) ? (m['latitude'] as num).toDouble() : null,
      longitude: (m['longitude'] is num) ? (m['longitude'] as num).toDouble() : null,
      waterType: (m['waterType'] ?? '')?.toString() ?? '',
      capacityOptions: (m['capacityOptions'] ?? '')?.toString() ?? '',
      dailySupply: (m['dailySupply'] ?? '')?.toString() ?? '',
      deliveryArea: (m['deliveryArea'] ?? '')?.toString() ?? '',
      deliveryTimings: (m['deliveryTimings'] ?? '')?.toString() ?? '',
      bankName: (m['bankName'] ?? '')?.toString() ?? '',
      accountNumber: (m['accountNumber'] ?? '')?.toString() ?? '',
      upiId: (m['upiId'] ?? '')?.toString() ?? '',
      ifscCode: (m['ifscCode'] ?? '')?.toString() ?? '',
      gstNumber: (m['gstNumber'] ?? '')?.toString() ?? '',
      earnings: toDouble(m['earnings']),
      status: (m['status'] ?? 'pending')?.toString() ?? 'pending',
      isVerified: (m['isVerified'] ?? false) as bool,
      isActive: (m['isActive'] ?? false) as bool,
      images: imagesMap,
      videoUrl: (m['videoUrl'] ?? '')?.toString() ?? '',
      maxOrdersPerDay: toInt(m['maxOrdersPerDay']) == 0 ? 100 : toInt(m['maxOrdersPerDay']),
      serviceRadiusKm: toDouble(m['serviceRadiusKm']) == 0.0 ? 5.0 : toDouble(m['serviceRadiusKm']),
      minOrderQty: toInt(m['minOrderQty']) == 0 ? 1 : toInt(m['minOrderQty']),
      deliveryCharges: toDouble(m['deliveryCharges']),
      rating: toDouble(m['rating']),
      ratingCount: toInt(m['ratingCount']),
      createdAt: parseTimestamp(m['createdAt']),
      updatedAt: parseTimestamp(m['updatedAt']),
      remarks: (m['remarks'] ?? '')?.toString() ?? '',
    );
  }

  factory VendorModel.fromJson(Map<String, dynamic> json) => VendorModel.fromMap(json);

  // -----------------------
  // Serialization
  // -----------------------

  /// Convert to a Firestore-friendly map.
  /// If [useServerTimestamps] is true, createdAt and updatedAt will be set to FieldValue.serverTimestamp()
  Map<String, dynamic> toMap({bool useServerTimestamps = false}) {
    final map = <String, dynamic>{
      'uid': uid,
      'merchantId': merchantId,
      'vendorName': vendorName,
      'bussinessName': businessName,
      'contactPerson': contactPerson,
      'phoneNumber': phoneNumber,
      'email': email,
      'vendorType': vendorType,
      'businessAddress': businessAddress,
      'areaCity': areaCity,
      'postalCode': postalCode,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'waterType': waterType,
      'capacityOptions': capacityOptions,
      'dailySupply': dailySupply,
      'deliveryArea': deliveryArea,
      'deliveryTimings': deliveryTimings,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'upiId': upiId,
      'ifscCode': ifscCode,
      'gstNumber': gstNumber,
      'earnings': earnings,
      'status': status,
      'isVerified': isVerified,
      'isActive': isActive,
      'images': images,
      'videoUrl': videoUrl,
      'maxOrdersPerDay': maxOrdersPerDay,
      'serviceRadiusKm': serviceRadiusKm,
      'minOrderQty': minOrderQty,
      'deliveryCharges': deliveryCharges,
      'rating': rating,
      'ratingCount': ratingCount,
      'remarks': remarks,
    };

    if (useServerTimestamps) {
      map['createdAt'] = FieldValue.serverTimestamp();
      map['updatedAt'] = FieldValue.serverTimestamp();
    } else {
      if (createdAt != null) map['createdAt'] = createdAt;
      if (updatedAt != null) map['updatedAt'] = updatedAt;
    }

    return map;
  }

  Map<String, dynamic> toJson() => toMap();

  // -----------------------
  // CopyWith / Equality
  // -----------------------

  VendorModel copyWith({
    String? id,
    String? uid,
    String? merchantId,
    String? vendorName,
    String? businessName,
    String? contactPerson,
    String? phoneNumber,
    String? email,
    String? vendorType,
    String? businessAddress,
    String? areaCity,
    String? postalCode,
    String? state,
    double? latitude,
    double? longitude,
    String? waterType,
    String? capacityOptions,
    String? dailySupply,
    String? deliveryArea,
    String? deliveryTimings,
    String? bankName,
    String? accountNumber,
    String? upiId,
    String? ifscCode,
    String? gstNumber,
    double? earnings,
    String? status,
    bool? isVerified,
    bool? isActive,
    Map<String, String>? images,
    String? videoUrl,
    int? maxOrdersPerDay,
    double? serviceRadiusKm,
    int? minOrderQty,
    double? deliveryCharges,
    double? rating,
    int? ratingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? remarks,
  }) {
    return VendorModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      merchantId: merchantId ?? this.merchantId,
      vendorName: vendorName ?? this.vendorName,
      businessName: businessName ?? this.businessName,
      contactPerson: contactPerson ?? this.contactPerson,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      vendorType: vendorType ?? this.vendorType,
      businessAddress: businessAddress ?? this.businessAddress,
      areaCity: areaCity ?? this.areaCity,
      postalCode: postalCode ?? this.postalCode,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      waterType: waterType ?? this.waterType,
      capacityOptions: capacityOptions ?? this.capacityOptions,
      dailySupply: dailySupply ?? this.dailySupply,
      deliveryArea: deliveryArea ?? this.deliveryArea,
      deliveryTimings: deliveryTimings ?? this.deliveryTimings,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      upiId: upiId ?? this.upiId,
      ifscCode: ifscCode ?? this.ifscCode,
      gstNumber: gstNumber ?? this.gstNumber,
      earnings: earnings ?? this.earnings,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      maxOrdersPerDay: maxOrdersPerDay ?? this.maxOrdersPerDay,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      minOrderQty: minOrderQty ?? this.minOrderQty,
      deliveryCharges: deliveryCharges ?? this.deliveryCharges,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VendorModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          uid == other.uid;

  @override
  int get hashCode => id.hashCode ^ uid.hashCode ^ merchantId.hashCode;

  // -----------------------
  // Validation helpers
  // -----------------------

  bool isValidPhone() {
    final p = phoneNumber.trim();
    return p.isNotEmpty && RegExp(r'^\+?[0-9]{7,15}$').hasMatch(p);
  }

  bool isValidEmail() {
    final e = email.trim();
    if (e.isEmpty) return false;
    return RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
            r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
            r"[a-zA-Z0-9])?(?:\.[a-zA-Z0-9]"
            r"(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
        .hasMatch(e);
  }

  /// Minimal required fields to "publish" a vendor/store
  bool isReadyForPublishing() {
    return vendorName.trim().isNotEmpty &&
        businessName.trim().isNotEmpty &&
        isValidPhone();
  }

  // -----------------------
  // Utility
  // -----------------------

  String shortAddress({int maxLen = 60}) {
    final address = [businessAddress, areaCity, state, postalCode]
        .where((s) => s.isNotEmpty)
        .join(', ');
    if (address.length <= maxLen) return address;
    return '${address.substring(0, maxLen - 3)}...';
  }

  /// Map to use for Firestore update with updatedAt server timestamp
  Map<String, dynamic> toFirestoreUpdateMap() {
    final map = toMap(useServerTimestamps: false);
    map['updatedAt'] = FieldValue.serverTimestamp();
    return map;
  }
}
