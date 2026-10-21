/// A local account whose server balance differs from the local one after the move.
class ImportMismatch {
  final String accountName;
  final double localBalance, serverBalance;

  ImportMismatch(this.accountName, this.localBalance, this.serverBalance);
}
