class UserDetailsModel {
  String docId;
  final String uid;
  final String name;
  final String number;
  final String email;
  final String floor;
  final String role;
  final String orderpin;
  final double walletBalance;
  final String? profileImage;

  // Constructor with required fields
  UserDetailsModel({
    required this.docId,
    required this.uid,
    required String name,
    required this.number,
    required this.email,
    required this.floor,
    required this.role,
    required this.walletBalance,
    this.profileImage,
    required this.orderpin,
  }) : name = _capitalize(name);

  // Capitalize the first letter of the name
  static String _capitalize(String name) {
    if (name.isEmpty) return "";
    return name[0].toUpperCase() + name.substring(1);
  }

  // Convert UserModel object to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'number': number,
      'email': email,
      'floor': floor,
      'role': role,
      'walletBalance': walletBalance,
      'orderpin': orderpin, // Ensure it's stored as a String
      'docId': docId,
    };
  }

  // Create a UserModel object from Firestore document
  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      docId: json['docId'] ?? '',
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      orderpin: json['orderpin']?.toString() ?? '', // ✅ Convert int to String
      email: json['email'] ?? '',
      floor: json['floor'] ?? '',
      role: json['role'] ?? 'isUser',
      walletBalance: (json['walletBalance'] is int)
          ? (json['walletBalance'] as int).toDouble() // ✅ Convert int to double
          : (json['walletBalance'] ?? 0.0),
    );
  }
}
