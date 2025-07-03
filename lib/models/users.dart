class Users {
  final String uid;
  final String username;
  final String email;
  final int score;
  final String avatar;

  Users({
    required this.uid,
    required this.username,
    required this.email,
    required this.score,
    required this.avatar,
  });

  factory Users.fromJson(String uid, Map<String, dynamic> json) {
    return Users(
      uid: uid,
      username: json['username'] ?? 'Bilinmeyen',
      email: json['email'] ?? 'Bilinmeyen',
      score: json['score'] ?? 0,
      avatar: json['avatar'] ?? 'assets/avatars/default.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'score': score,
      'avatar': avatar,
    };
  }

  int get level {
    return (score / 100).floor() + 1;
  }
}
