class User {
  String displayName;
  String email;
  String password;
  String uuid;
  String role;
  double balance;
  String phone;

  // Default constructor
  User({
    this.displayName = '',
    this.email = '',
    this.password = '',
    this.uuid = '',
    this.role = '',
    this.balance = 0.0, // default balance as 0.0
    this.phone = '',
  });

  // Named constructor to create a User from a Map (like from Firebase)
  User.fromMap(Map<String, dynamic> data)
      : displayName = data['displayName'] ?? '',
        email = data['email'] ?? '',
        password = data['password'] ?? '',
        uuid = data['uuid'] ?? '',
        role = data['role'] ?? '',
        balance = (data['balance'] ?? 0.0).toDouble(), // Ensure balance is a double
        phone = data['phone'] ?? '';

  // Convert User to Map (for saving in Firestore)
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'password': password,
      'uuid': uuid,
      'role': role,
      'balance': balance,
      'phone': phone,
    };
  }
}
