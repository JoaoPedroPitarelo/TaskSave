class UserVo {
  final String? id;
  final String? login;

  const UserVo({
    required this.id,
    required this.login,
  });

  factory UserVo.fromJson(Map<String, dynamic> json) {
    return UserVo(
      id: json['id'], 
      login: json['sub']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sub': login
    };
  }
}