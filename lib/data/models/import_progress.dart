enum ImportStep {
  preflight,
  serverSetup,
  categories,
  accounts,
  transactions,
  restoring,
  verifying,
}

typedef ImportProgress = void Function(ImportStep step, int done, int total);
