import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/profile/data/models/profile_model.dart';

void main() {
  group('ProfileModel.fromJson', () {
    test('reads the account with the father and mother', () {
      final profile = ProfileModel.fromJson(const {
        'name': 'Hany Adel',
        'phone': '0101****222',
        'language': 'ar',
        'father': {
          'name': 'Hany Adel',
          'name_ar': 'هاني عادل',
          'job': 'Engineer',
          'education': 'Bachelor',
          'phone': '0101****222',
        },
        'mother': {
          'name': 'Mona Samir',
          'name_ar': 'منى سمير',
          'job': null,
          'education': 'Master',
          'phone': '0111****333',
        },
        'children': [],
        'school_contact': {'phone': '0222****000'},
      });

      expect(profile.name, 'Hany Adel');
      expect(profile.phone, '0101****222');
      expect(profile.language, 'ar');

      final father = profile.father!;
      expect(father.name, 'Hany Adel');
      expect(father.nameAr, 'هاني عادل');
      expect(father.job, 'Engineer');
      expect(father.education, 'Bachelor');
      expect(father.phone, '0101****222');

      final mother = profile.mother!;
      expect(mother.name, 'Mona Samir');
      expect(mother.nameAr, 'منى سمير');
      expect(mother.job, isNull);
      expect(mother.education, 'Master');
      expect(mother.phone, '0111****333');
    });

    test('has no father or mother when the school has none', () {
      final profile = ProfileModel.fromJson(const {
        'name': 'Hany Adel',
        'phone': '0101****222',
        'language': 'en',
        'mother': null,
      });

      expect(profile.father, isNull);
      expect(profile.mother, isNull);
    });
  });
}
