class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'admin', 'president', 'secretary', 'member', 'pending'
  final String roleTitle;
  final String? memberNumber;
  final String? secretCode;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'pending',
    this.roleTitle = 'অপেক্ষমান',
    this.memberNumber,
    this.secretCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'roleTitle': roleTitle,
      'memberNumber': memberNumber,
      'secretCode': secretCode,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? 'pending',
      roleTitle: data['roleTitle'] ?? 'অপেক্ষমান',
      memberNumber: data['memberNumber'],
      secretCode: data['secretCode'],
    );
  }
}
