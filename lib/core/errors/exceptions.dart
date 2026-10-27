/// Thrown by data sources when local storage cannot be read or written.
class StorageException implements Exception {
  const StorageException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'StorageException: $message${cause == null ? '' : ' ($cause)'}';
}
