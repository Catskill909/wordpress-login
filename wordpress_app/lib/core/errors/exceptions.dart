class ApiException implements Exception {
  final String message;

  ApiException({required this.message});

  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException({required super.message});
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({required super.message});
}

class ForbiddenException extends ApiException {
  ForbiddenException({required super.message});
}

class NotFoundException extends ApiException {
  NotFoundException({required super.message});
}

class ServerException extends ApiException {
  ServerException({required super.message});
}

class TimeoutException extends ApiException {
  TimeoutException({required super.message});
}

class NetworkException extends ApiException {
  NetworkException({required super.message});
}

class RequestCancelledException extends ApiException {
  RequestCancelledException({required super.message});
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => message;
}
