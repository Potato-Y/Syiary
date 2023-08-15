class GroupException implements Exception {
  final String message;

  GroupException(this.message);

  @override
  String toString() => 'GroupException: $message';
}
