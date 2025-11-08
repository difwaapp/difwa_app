class Address {
  String docId;
  final String name;
  final String street;
  final String city;
  final String state;
  final String zip;
  final bool isDeleted;
  final String country;
  final String phone;
  final bool saveAddress;
  bool isSelected;
  String userId;
  final String floor;
  String locationType;

  Address({
    required this.docId,
    required String name,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.isDeleted,
    required this.country,
    required this.phone,
    required this.saveAddress,
    required this.isSelected,
    required this.userId,
    required this.floor,
    required this.locationType,
  }) : name = _capitalize(name);

  static String _capitalize(String name) {
    if (name.isEmpty) return "";
    return name[0].toUpperCase() + name.substring(1);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'phone': phone,
      'saveAddress': saveAddress,
      'isDeleted': isDeleted,
      'userId': userId,
      'isSelected': isSelected,
      'docId': docId,
      'floor': floor,
      'locationType': locationType,
    };
  }

  static Address defaultAddress() {
    return Address(
      docId: 'default',
      userId: 'default_user',
      name: 'Default User',
      street: '123 Default St.',
      city: 'Default City',
      state: 'Default State',
      zip: '00000',
      country: 'Default Country',
      phone: '000-000-0000',
      saveAddress: false,
      isSelected: false,
      isDeleted: false,
      floor: '1st',
      locationType: 'home',
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json['name'] ?? '',
      docId: json['docId'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zip: json['zip'] ?? '',
      country: json['country'] ?? '',
      phone: json['phone'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      saveAddress: json['saveAddress'] ?? false,
      isSelected: json['isSelected'] ?? false,
      userId: json['userId'] ?? '',
      floor: json['floor'] ?? '',
      locationType: json['locationType'] ?? '',
    );
  }
}
