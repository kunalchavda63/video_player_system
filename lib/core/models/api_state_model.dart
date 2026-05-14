class ApiState<T> {
  const ApiState({
    required this.loading,
    required this.initial,
    this.data,
    this.error,
  });

  factory ApiState.initial() => const ApiState(
    loading: false,
    initial: true,
  );

  factory ApiState.loading() => const ApiState(
    loading: true,
    initial: false,
  );

  factory ApiState.success(T data) => ApiState(
    loading: false,
    initial: false,
    data: data,
  );

  factory ApiState.error(String message) => ApiState(
    loading: false,
    initial: false,
    error: message,
  );

  final bool loading;
  final bool initial;
  final T? data;
  final String? error;
}