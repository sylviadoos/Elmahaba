import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/auth/domain/entities/parent_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/parent_context.dart';

ParentEntity _parent({String name = 'Mina Nagy', String? fullPhone}) =>
    ParentEntity(
      id: 7,
      name: name,
      phone: '0101****678',
      language: 'en',
      fullPhone: fullPhone,
    );

void main() {
  group('firstName / lastName', () {
    test('the first name, then the rest', () {
      final parent = _parent(name: '  هاني  عادل محمد ');

      expect(parent.firstName, 'هاني');
      expect(parent.lastName, 'عادل محمد');
    });

    test('one name: no last name', () {
      expect(_parent(name: 'Mina').lastName, '');
    });

    test('no name: both empty', () {
      final parent = _parent(name: '');

      expect(parent.firstName, '');
      expect(parent.lastName, '');
    });
  });

  group('phoneAfterCountryCode', () {
    test('the full number without its 0', () {
      expect(
        _parent(fullPhone: '01012345678').phoneAfterCountryCode,
        '1012345678',
      );
    });

    test('only the masked one known: empty', () {
      expect(_parent().phoneAfterCountryCode, '');
    });
  });
}
