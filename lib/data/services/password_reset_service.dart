class PasswordResetService{
  String _email = '';
  String _token = '';

  bool isResettingPassword() => _email.isNotEmpty && _token.isNotEmpty;

  String get email => _email;
  String get token => _token;

  String resetPasswordQueryParams() {
    return '?view=reset_password&email=${_email}&token=${_token}';
  }

  void setResetPasswordQueryParams(String email, String token) {
    _email = email;
    _token = token;
  }

  void clearResetPasswordQueryParams() {
    _email = '';
    _token = '';
  }
}