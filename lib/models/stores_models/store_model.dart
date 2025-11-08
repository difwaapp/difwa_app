class UserModel {
  final String userId;
  final String upiId;
  final String mobile;
  final String email;
  final String shopName;
  final String ownerName;
  final String merchantId;
  final double earnings;  // Change earnings to a double
  final String uid;
  final String? imageUrl;
  final String? storeaddress;

  UserModel({
    required this.userId,
    required this.upiId,
    required this.mobile,
    required this.email,
    required this.shopName,
    required this.ownerName,
    required this.merchantId,
    required this.earnings,  // Make sure earnings is passed as double

    required this.uid,
    required this.imageUrl,
    required this.storeaddress,
  });

  // Convert a Map from Firestore to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      upiId: map['upiId'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      shopName: map['shopName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      merchantId: map['merchantId'] ?? '',
      earnings: map['earnings'] != null ? map['earnings'].toDouble() : 0.0, // Ensure it's a double
      uid: map['uid'] ?? '',
      imageUrl: map['imageUrl'], // Optional, can be null
      storeaddress: map['storeaddress'], // Optional, can be null
    );
  }

  // Convert the UserModel to a Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'upiId': upiId,
      'mobile': mobile,
      'email': email,
      'shopName': shopName,
      'ownerName': ownerName,
      'merchantId': merchantId,
      'earnings': earnings,  // Store as double
      'uid': uid,
      'imageUrl': imageUrl,
      'storeaddress': storeaddress,
    };
  }
}
