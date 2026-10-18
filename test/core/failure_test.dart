import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_cafeteria/core/failure.dart';

void main() {
  group('Failures', () {
    group('NetworkFailure', () {
      test('mensaje por defecto', () {
        const failure = NetworkFailure();

        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.message, 'No se pudo conectar al servidor');
      });
    });

    group('ServerFailure', () {
      test('guarda el codigo', () {
        const failure = ServerFailure(500);

        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.statusCode, 500);
        expect(failure.message, 'Error del Servidor');
      });
    });

    group('NotFoundFailure', () {
      test('guarda el mensaje', () {
        const failure = NotFoundFailure('Recurso no encontrado');

        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.message, 'Recurso no encontrado');
      });
    });

    group('ConflictFailure', () {
      test('guarda el mensaje', () {
        const failure = ConflictFailure('Conflicto con recurso existente');

        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.message, 'Conflicto con recurso existente');
      });
    });

    group('ValidationFailure', () {
      test('guarda los campos', () {
        const fields = {'email': 'Email inválido', 'password': 'Muy corta'};
        const failure = ValidationFailure(fields);

        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.message, 'Error de Validación');
        expect(failure.fields, fields);
        expect(failure.fields['email'], 'Email inválido');
        expect(failure.fields['password'], 'Muy corta');
      });
    });

    group('UnexpectedFailure', () {
      test('guarda codigo y mensaje', () {
        const failure = UnexpectedFailure(418, 'Soy una tetera');

        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.statusCode, 418);
        expect(failure.message, 'Soy una tetera');
      });
    });

    group('Switch', () {
      test('reconoce cada tipo', () {
        String describeFailure(Failure failure) {
          return switch (failure) {
            NetworkFailure() => 'network',
            ServerFailure(statusCode: final code) => 'server: $code',
            NotFoundFailure(message: final msg) => 'not_found: $msg',
            ConflictFailure(message: final msg) => 'conflict: $msg',
            ValidationFailure(fields: final f) => 'validation: ${f.length}',
            UnexpectedFailure(statusCode: final code, message: final msg) =>
              'unexpected: $code - $msg',
          };
        }

        expect(describeFailure(const NetworkFailure()), 'network');
        expect(describeFailure(const ServerFailure(503)), 'server: 503');
        expect(
          describeFailure(const NotFoundFailure('No existe')),
          'not_found: No existe',
        );
        expect(
          describeFailure(const ConflictFailure('Duplicado')),
          'conflict: Duplicado',
        );
        expect(
          describeFailure(const ValidationFailure({'campo': 'error'})),
          'validation: 1',
        );
        expect(
          describeFailure(const UnexpectedFailure(520, 'Desconocido')),
          'unexpected: 520 - Desconocido',
        );
      });
    });
  });
}
