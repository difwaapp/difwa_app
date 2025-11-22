import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String number;
  final String role;
  final int orderpin;
  final double walletBalance;
  final Timestamp? createdAt;
  final Timestamp? lastLogin;
  final String? profileImage;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.number,
    required this.role,
    required this.orderpin,
    required this.walletBalance,
    this.createdAt,
    this.lastLogin,
    this.profileImage,
  });

  factory AppUser.fromMap(Map<String, dynamic> m, String uid) => AppUser(
    uid: uid,
    name: m['name'] ?? '',
    email: m['email'] ?? '',
    number: m['number'] ?? '',
    role: m['role'] ?? 'isUser',
    orderpin: (m['orderpin'] ?? 0) as int,

    walletBalance: (m['walletBalance'] is int)
        ? (m['walletBalance'] as int).toDouble()
        : (m['walletBalance'] ?? 0.0),

    profileImage: (m['profileImage'] ?? ''),

    createdAt: m['createdAt'] as Timestamp?,
    lastLogin: m['lastLogin'] as Timestamp?,
  );

  Map<String, dynamic> toMapForCreate() => {
    'name': name,
    'email': email,
    'number': number,
    'role': role,
    'orderpin': orderpin,
    'walletBalance': walletBalance,
    'profileImage': profileImage,
    'createdAt': FieldValue.serverTimestamp(),
    'lastLogin': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> toMapForUpdate() => {
    'lastLogin': FieldValue.serverTimestamp(),
  };
}
