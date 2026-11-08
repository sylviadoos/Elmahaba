import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/children/domain/entities/child_parent_entity.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/profile_entity.dart';

const _father = ChildParentEntity(
  name: 'Hany Adel',
  nameAr: 'هاني عادل',
  phone: '0101****222',
);
const _mother = ChildParentEntity(
  name: 'Mona Samir',
  nameAr: 'منى سمير',
  phone: '0111****333',
);

ProfileEntity _signedInWith(String phone) => ProfileEntity(
  name: 'Parent',
  phone: phone,
  language: 'en',
  father: _father,
  mother: _mother,
);

void main() {
  group('ProfileEntity.you', () {
    test('is the father or mother with the account phone', () {
      expect(_signedInWith('0101****222').you, same(_father));
      expect(_signedInWith('0111****333').you, same(_mother));
    });

    test('is nobody for another phone (a guardian) or none', () {
      expect(_signedInWith('0100****999').you, isNull);
      expect(_signedInWith('').you, isNull);
      expect(
        const ProfileEntity(
          name: 'Parent',
          phone: '',
          language: 'en',
          father: ChildParentEntity(name: 'A', nameAr: ''),
        ).you,
        isNull,
      );
    });
  });
}
