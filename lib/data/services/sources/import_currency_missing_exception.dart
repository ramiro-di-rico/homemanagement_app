/// A currency used by a local account is not offered by the server (FR-020).
class ImportCurrencyMissingException implements Exception {
  final List<String> codes;

  ImportCurrencyMissingException(this.codes);

  @override
  String toString() => 'ImportCurrencyMissingException: ${codes.join(', ')}';
}
