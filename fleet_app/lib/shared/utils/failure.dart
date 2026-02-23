abstract class Failure {
  final String message;
  final Map<String, List<String>>? validationErrors;

  const Failure(this.message, {this.validationErrors});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.validationErrors});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('Sesi anda telah berakhir. Silakan login kembali.');
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {required Map<String, List<String>> errors})
      : super(validationErrors: errors);
}
