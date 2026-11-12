// lib/core/network/api_result.dart

/// Sealed result type — avoids try/catch in UI layer.
/// Usage:
///   final result = await repo.getModules();
///   result.when(
///     success: (data) => ...,
///     failure: (err)  => ...,
///   );
sealed class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T data) = ApiSuccess<T>;
  const factory ApiResult.failure(String message, {int? statusCode}) =
  ApiFailure<T>;

  bool get isSuccess => this is ApiSuccess<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    return switch (this) {
      ApiSuccess(:final data) => success(data),
      ApiFailure(:final message) => failure(message),
    };
  }

  T? get dataOrNull => switch (this) {
    ApiSuccess(:final data) => data,
    _ => null,
  };
}

final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

final class ApiFailure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  const ApiFailure(this.message, {this.statusCode});
}