class UserVo {
  final String? id;
  final String? login;

  const UserVo({
    required this.id,
    required this.login,
  });

  // De Json para UserVo
  factory UserVo.fromJson(Map<String, dynamic> json) {
    return UserVo(
      id: json['id'], 
      login: json['sub']
    );
  }

  // De UserVo para Json
  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'sub': this.login
    };
  }
}