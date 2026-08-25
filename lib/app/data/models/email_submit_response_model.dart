/// EmailSubmitResponseModel representing the server response after submitting an operator email.
class EmailSubmitResponseModel {
  final String email;
  final bool isNewUser;
  final bool isVerified;
  final String message;
  final int? expiresInMinutes;

  const EmailSubmitResponseModel({
    required this.email,
    required this.isNewUser,
    required this.isVerified,
    required this.message,
    this.expiresInMinutes,
  });

  factory EmailSubmitResponseModel.fromJson(Map<String, dynamic> json) {
    return EmailSubmitResponseModel(
      email: json['email'] as String? ?? '',
      isNewUser: json['is_new_user'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      expiresInMinutes: json['expires_in_minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'is_new_user': isNewUser,
      'is_verified': isVerified,
      'message': message,
      'expires_in_minutes': expiresInMinutes,
    };
  }
}
