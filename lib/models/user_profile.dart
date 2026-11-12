class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'admin' or 'member'
  final String? linkedMemberId;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'admin',
    this.linkedMemberId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'linkedMemberId': linkedMemberId,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? 'admin',
      linkedMemberId: data['linkedMemberId'],
    );
  }
}
