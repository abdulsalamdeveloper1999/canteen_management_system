class ErrorHandler {
  /// Executes a function and catches errors, returning a default value if an error occurs.
  static Future<T> handle<T>({
    required Future<T> Function() action,
    required String errorMessage,
    T? defaultValue,
  }) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      print('Error: $e\nStackTrace: $stackTrace');
      throw Exception(errorMessage);
    }
  }
}
