class UserProfile {
  const UserProfile({
    required this.id,
    required this.phone,
    required this.role,
    required this.status,
    this.email,
  });

  final String id;
  final String phone;
  final String role;
  final String status;
  final String? email;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        phone: json['phone'] as String,
        role: json['role'] as String,
        status: json['status'] as String,
        email: json['email'] as String?,
      );
}
