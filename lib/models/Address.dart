class Address {
 String docId;
  final String name;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String zip;
  final String country;
  final String locationType;
  final String floor;
  bool isSelected;
  final bool isDeleted;
  final bool saveAddress;
 String uid;
  final double? latitude;
  final double? longitude;

  Address({
    required this.docId,
    required this.name,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    this.country = '',
    this.locationType = 'home',
    this.floor = '',
    this.isSelected = false,
    this.isDeleted = false,
    this.saveAddress = true,
    required this.uid,
    this.latitude,
    this.longitude,
  });

  factory Address.fromMap(Map<String, dynamic> m) => Address(
        docId: m['docId'] ?? '',
        name: m['name'] ?? '',
        phone: m['phone'] ?? '',
        street: m['street'] ?? '',
        city: m['city'] ?? '',
        state: m['state'] ?? '',
        zip: m['zip'] ?? '',
        country: m['country'] ?? '',
        locationType: m['locationType'] ?? 'home',
        floor: m['floor'] ?? '',
        isSelected: m['isSelected'] ?? false,
        isDeleted: m['isDeleted'] ?? false,
        saveAddress: m['saveAddress'] ?? true,
        uid: m['uid'] ?? '',
        latitude: (m['latitude'] is num) ? (m['latitude'] as num).toDouble() : null,
        longitude: (m['longitude'] is num) ? (m['longitude'] as num).toDouble() : null,
      );

  Map<String, dynamic> toMap() => {
        'docId': docId,
        'name': name,
        'phone': phone,
        'street': street,
        'city': city,
        'state': state,
        'zip': zip,
        'country': country,
        'locationType': locationType,
        'floor': floor,
        'isSelected': isSelected,
        'isDeleted': isDeleted,
        'saveAddress': saveAddress,
        'uid': uid,
        'latitude': latitude,
        'longitude': longitude,
      };

  static defaultAddress() {

  }


}