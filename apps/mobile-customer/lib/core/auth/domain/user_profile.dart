class UserProfile {
  const UserProfile({
    required this.id,
    required this.phone,
    required this.role,
    required this.status,
    this.email,
    this.name,
  });

  final String id;
  final String phone;
  final String role;
  final String status;
  final String? email;
  /// Display name from clientProfile or driverProfile. Null if no profile exists yet.
  final String? name;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final clientProfile = json['clientProfile'] as Map<String, dynamic>?;
    final driverProfile = json['driverProfile'] as Map<String, dynamic>?;
    return UserProfile(
      id: json['id'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      email: json['email'] as String?,
      name: (clientProfile?['name'] ?? driverProfile?['name']) as String?,
    );
  }
}
