class PasswordResetService{
  String _email = '';
  String _token = '';

  bool isResettingPassword() => _email.isNotEmpty && _token.isNotEmpty;

  String resetPasswordQueryParams() {
    return '?email=${_email}&token=${_token}';
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