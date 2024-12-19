class UserModel {
  final String UserModelId; // Unique identifier for the UserModel
  final String name; // Full name of the UserModel
  final String email; // Email address of the UserModel
  final String phone; // Phone number of the UserModel
  final DateTime? birthday; // Optional birthday of the UserModel

  // Constructor for the UserModel class
  UserModel({
    required this.UserModelId,
    required this.name,
    required this.email,
    required this.phone,
    this.birthday, // Optional parameter for birthday
  });

  // Factory method to create a UserModel instance from Firestore data
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      UserModelId: data['UserModelId'], // Get UserModelId from data
      name: data['name'], // Get name from data
      email: data['email'], // Get email from data
      phone: data['phone'], // Get phone from data
      birthday: data['birthday'] != null ? DateTime.parse(data['birthday']) : null, // Parse birthday if it exists
    );
  }

  // Method to convert UserModel instance to a format suitable for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'UserModelId': UserModelId, // Convert UserModelId to Firestore format
      'name': name, // Convert name to Firestore format
      'email': email, // Convert email to Firestore format
      'phone': phone, // Convert phone to Firestore format
      'birthday': birthday?.toIso8601String(), // Convert birthday to ISO 8601 string format if it exists
    };
  }
}