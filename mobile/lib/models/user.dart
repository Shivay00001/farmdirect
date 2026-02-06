class User {
  final String id;
  final String name;
  final String mobile;
  final String role;
  final String? profilePhoto;

  User({
    required this.id,
    required this.name,
    required this.mobile,
    required this.role,
    this.profilePhoto,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      role: json['role'],
      profilePhoto: json['profile_photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'role': role,
      'profile_photo': profilePhoto,
    };
  }
}
