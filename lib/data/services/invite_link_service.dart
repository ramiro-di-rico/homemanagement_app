class InviteLinkService {
  static const String _baseUrl = 'https://www.ramiro-di-rico.dev';
  static const String _invitePath = '/public/invites';
  static const String _customScheme = 'homemanagementapp';

  String buildPublicInviteUrl(String token) {
    return '$_baseUrl$_invitePath/$token';
  }

  String buildNativeInviteUrl(String token) {
    return '$_customScheme://public/invites/$token';
  }
}
