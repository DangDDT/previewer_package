enum LoadingStatus {
  idle,
  success,
  loading,
  error;

  bool get isIdle => this == idle;
  bool get isSuccess => this == success;
  bool get isLoading => this == loading;
  bool get isError => this == error;
}
