import 'package:al_mahhaba_school/features/children/data/models/child_profile.dart';

// TODO: replace with the parent's account data from the API.
// Mock content from the designs.
const String mockParentName = 'Samar Ahmed';
const String mockParentInitials = 'SA';
const String mockParentEmail = 'samar.ahmed@email.com';
// Non-breaking spaces keep the number on one line.
const String mockParentPhone = '+20 10 •••• 5678';

const List<ChildProfile> mockChildren = [
  ChildProfile(fullName: 'Omar Ahmed', grade: 'Grade 4 · 4B', idTail: '2341'),
  ChildProfile(fullName: 'Lina Ahmed', grade: 'KG 2 · Blue', idTail: '5097'),
];

/// Children "found" when the Add button is pressed on Add children.
const List<ChildProfile> mockChildrenToLink = [
  ChildProfile(fullName: 'Lina Ahmed', grade: 'KG 2 · Blue', idTail: ''),
  ChildProfile(fullName: 'Youssef Ahmed', grade: 'Grade 6 · 6A', idTail: ''),
  ChildProfile(fullName: 'Mariam Ahmed', grade: 'Grade 2 · 2C', idTail: ''),
];
