enum DocStatus {
  draft,
  submitted,
  cancelled;

  static DocStatus fromInt(int? value) {
    switch (value) {
      case 1:
        return DocStatus.submitted;
      case 2:
        return DocStatus.cancelled;
      default:
        return DocStatus.draft;
    }
  }

  int get asInt {
    switch (this) {
      case DocStatus.submitted:
        return 1;
      case DocStatus.cancelled:
        return 2;
      case DocStatus.draft:
        return 0;
    }
  }
}
