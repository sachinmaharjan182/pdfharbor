import 'package:flutter_test/flutter_test.dart';
import 'package:pdfharbor/core/error/failure.dart';
import 'package:pdfharbor/core/error/result.dart';

void main() {
  group('Result', () {
    test('Success exposes data and reports isSuccess', () {
      const result = Success<int>(42);
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('ResultFailure exposes the failure and reports not successful', () {
      const failure = IncorrectPasswordFailure();
      const result = ResultFailure<int>(failure);
      expect(result.isSuccess, isFalse);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, same(failure));
    });

    test('fold routes to the matching branch', () {
      const success = Success<int>(7);
      const failure = ResultFailure<int>(CancelledFailure());

      expect(success.fold((d) => 'ok:$d', (f) => 'err:${f.message}'), 'ok:7');
      expect(
        failure.fold((d) => 'ok:$d', (f) => 'err:${f.message}'),
        'err:Operation cancelled',
      );
    });
  });

  group('Failure messages', () {
    test('carry the offending value in the message', () {
      expect(const FileNotFoundFailure('/a/b.pdf').message, contains('/a/b.pdf'));
      expect(const PermissionDeniedFailure('Camera').message, contains('Camera'));
    });

    test('use sensible defaults when no reason is given', () {
      expect(const InvalidPdfFailure().message, 'The file is not a valid PDF');
      expect(const UnexpectedFailure().message, 'Something went wrong');
    });
  });
}
