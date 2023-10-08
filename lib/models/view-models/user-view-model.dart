class UserViewModel{
  String email = '';
  String password = '';

  bool get isValid => this.isEmailValid && this.isPasswordValid;

  bool get isEmailValid => this.email.length > 3;
  bool get isPasswordValid => this.password.length > 0;
}