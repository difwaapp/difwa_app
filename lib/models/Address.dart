import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  String docId;
  String uid;

  // Basic info
  final String name;
  final String phone;
  final String? alternatePhone;

  // Address details
  final String street;
  final String city;
  final String state;
  final String zip;
  final String country;
  final String? landmark;
  final String locationType; // home / work / other
  final String floor;

  // Geo location
  final double? latitude;
  final double? longitude;

  // Status flags
  bool isSelected;
  final bool isDeleted;
  final bool saveAddress;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Address({
    required this.docId,
    required this.uid,
    required this.name,
    required this.phone,
    this.alternatePhone,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    this.country = '',
    this.landmark,
    this.locationType = 'home',
    this.floor = '',
    this.latitude,
    this.longitude,
    this.isSelected = false,
    this.isDeleted = false,
    this.saveAddress = true,
    this.createdAt,
    this.updatedAt,
  });

  /// ---------- From Firestore ----------
  factory Address.fromMap(Map<String, dynamic> m) {
    return Address(
      docId: m['docId'] ?? '',
      uid: m['uid'] ?? '',
      name: m['name'] ?? '',
      phone: m['phone'] ?? '',
      alternatePhone: m['alternatePhone'],
      street: m['street'] ?? '',
      city: m['city'] ?? '',
      state: m['state'] ?? '',
      zip: m['zip'] ?? '',
      country: m['country'] ?? '',
      landmark: m['landmark'],
      locationType: m['locationType'] ?? 'home',
      floor: m['floor'] ?? '',
      latitude: (m['latitude'] is num)
          ? (m['latitude'] as num).toDouble()
          : null,
      longitude: (m['longitude'] is num)
          ? (m['longitude'] as num).toDouble()
          : null,
      isSelected: m['isSelected'] ?? false,
      isDeleted: m['isDeleted'] ?? false,
      saveAddress: m['saveAddress'] ?? true,

      createdAt: _parseDateTime(m['createdAt']),
      updatedAt: _parseDateTime(m['updatedAt']),
    );
  }

  /// Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// ---------- To Firestore ----------
  Map<String, dynamic> toMap() => {
    'docId': docId,
    'uid': uid,
    'name': name,
    'phone': phone,
    'alternatePhone': alternatePhone,
    'street': street,
    'city': city,
    'state': state,
    'zip': zip,
    'country': country,
    'landmark': landmark,
    'locationType': locationType,
    'floor': floor,
    'latitude': latitude,
    'longitude': longitude,
    'isSelected': isSelected,
    'isDeleted': isDeleted,
    'saveAddress': saveAddress,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// ---------- Default Address Template ----------
  static Address defaultAddress(String uid) {
    return Address(
      docId: "",
      uid: uid,
      name: "",
      phone: "",
      street: "",
      city: "",
      state: "",
      zip: "",
      country: "India",
      locationType: "home",
      floor: "",
      isSelected: false,
      saveAddress: true,
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// ---------- CopyWith (useful for updates) ----------
  Address copyWith({
    String? docId,
    String? uid,
    String? name,
    String? phone,
    String? alternatePhone,
    String? street,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? landmark,
    String? locationType,
    String? floor,
    double? latitude,
    double? longitude,
    bool? isSelected,
    bool? isDeleted,
    bool? saveAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      docId: docId ?? this.docId,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      country: country ?? this.country,
      landmark: landmark ?? this.landmark,
      locationType: locationType ?? this.locationType,
      floor: floor ?? this.floor,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSelected: isSelected ?? this.isSelected,
      isDeleted: isDeleted ?? this.isDeleted,
      saveAddress: saveAddress ?? this.saveAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
