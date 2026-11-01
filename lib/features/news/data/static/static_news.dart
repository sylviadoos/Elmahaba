import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/features/news/data/models/news_details_model.dart';

// Copied from the school API (GET mobile/news/{slug}) on Oct 28, 2026.
// Shown while AppConfig.useStaticData is on. Latest first, like the API.
// The website links are left empty: the server isn't public yet.
final List<NewsDetailsModel> staticNews = [
  NewsDetailsModel(
    id: '2c0b3b67-799e-440c-aab3-1d2814122369',
    slug:
        'al-mahabbah-school-celebrated-the-birthdays-of-children-born-in-september-and-october',
    title:
        'Al Mahabbah School celebrated the birthdays of children born in September and October',
    date: DateTime(2025, 11, 17),
    thumbnailUrl: AppImages.newsBirthdays,
    excerpt:
        "\"As part of Al Mahabbah School's efforts to share happy occasions with the children and instill the value of community participation in their heart...",
    webUrl: '',
    contentHtml: r'''
<p>&quot;As part of Al Mahabbah School's efforts to share happy occasions with the children and instill the value of community participation in their hearts, the school celebrated today, Thursday, November 6, 2025, the birthdays of children born in September and October, in a joyful and happy atmosphere. The celebration of the remaining children's birthdays will follow according to the following schedule:</p>
<ul>
<li>August and November birthdays: end of November.</li>
<li>July and December birthdays: end of December.</li>
<li>June and January birthdays: January.</li>
<li>February birthdays: end of February.</li>
<li>March birthdays: end of March.</li>
<li>April birthdays: end of April.</li>
<li>May birthdays: during May.<br />
Wishing all our children a happy year.<br />
School Principal, Mrs. Ahlam Louis Riad<br />
#Al_mahabbah_schools<br />
#Almahabbahschools&quot;</li>
</ul>
''',
    contentText: r'''
"As part of Al Mahabbah School's efforts to share happy occasions with the children and instill the value of community participation in their hearts, the school celebrated today, Thursday, November 6, 2025, the birthdays of children born in September and October, in a joyful and happy atmosphere. The celebration of the remaining children's birthdays will follow according to the following schedule:

August and November birthdays: end of November.
July and December birthdays: end of December.
June and January birthdays: January.
February birthdays: end of February.
March birthdays: end of March.
April birthdays: end of April.
May birthdays: during May.
Wishing all our children a happy year.
School Principal, Mrs. Ahlam Louis Riad
#Al_mahabbah_schools
#Almahabbahschools"''',
  ),
  NewsDetailsModel(
    id: '8dafe083-075c-46a3-b1a5-48afbefa8691',
    slug:
        'al-mahabbah-schools-officially-started-using-the-bee-degree-application-from-learning-rockets',
    title:
        'Al Mahabbah Schools officially started using the "Bee Degree" application 🐝 from Learning Rockets 🚀 🎉',
    date: DateTime(2025, 11, 17),
    thumbnailUrl: AppImages.newsBeeDegree,
    excerpt:
        'Based on the vision of Al Mahabbah Schools to develop education and raise the efficiency of teachers and enhance practical learning, the school has...',
    webUrl: '',
    contentHtml: r'''
<p>Based on the vision of Al Mahabbah Schools to develop education and raise the efficiency of teachers and enhance practical learning, the school has officially started using the &quot;Bee Degree&quot; application 🐝 from Learning Rockets 🚀 🎉, which aims to teach children English in an easy way through games. It contains more than 20 games, each designed to deliver information in a thoughtful way to the child. In addition, there is a whole part for the teacher to conduct exams and know the level of each child, making learning English a fun and easy journey through cartoons, games, and interactive activities 🎮💛.<br />
Mr. George Jamil, the educational consultant of Learning Rockets, trained the teachers on using the application in teaching to raise their efficiency and enhance their ability to use modern and innovative teaching methods.<br />
It is worth noting that the &quot;Bee Degree&quot; application had won the best educational application from the Ministry of Communications in 2023.<br />
#Al_mahabbah_schools<br />
#Almahabbahschools<br />
School Principal:<br />
Mrs. Ahlam Louis Riad</p>
''',
    contentText: r'''
Based on the vision of Al Mahabbah Schools to develop education and raise the efficiency of teachers and enhance practical learning, the school has officially started using the "Bee Degree" application 🐝 from Learning Rockets 🚀 🎉, which aims to teach children English in an easy way through games. It contains more than 20 games, each designed to deliver information in a thoughtful way to the child. In addition, there is a whole part for the teacher to conduct exams and know the level of each child, making learning English a fun and easy journey through cartoons, games, and interactive activities 🎮💛.
Mr. George Jamil, the educational consultant of Learning Rockets, trained the teachers on using the application in teaching to raise their efficiency and enhance their ability to use modern and innovative teaching methods.
It is worth noting that the "Bee Degree" application had won the best educational application from the Ministry of Communications in 2023.
#Al_mahabbah_schools
#Almahabbahschools
School Principal:
Mrs. Ahlam Louis Riad''',
  ),
  NewsDetailsModel(
    id: 'fd371740-be98-4316-af52-9efadd415302',
    slug: 'important-notice-for-online-applicants',
    title: 'Important Notice for Online Applicants',
    date: DateTime(2025, 10, 14),
    excerpt:
        "The Student Affairs Department at Al-Mahabba School announces that all students who have submitted their applications through the school's official...",
    webUrl: '',
    contentHtml: r'''
<p>The Student Affairs Department at Al-Mahabba School announces that all students who have submitted their applications through the school's official website must receive a confirmation email after completing the registration process.</p>
<p>If you do not receive the confirmation email within 24 hours, please:</p>
<p>Check your Spam or Junk email folder.</p>
<p>Or contact us via private messages on the school’s official page.</p>
<p>Please note that the confirmation email is a primary proof of successful registration and review by the administration.</p>
<p>Thank you for your cooperation.</p>
<p>Sincerely,<br />
Student Affairs Department – Al-Mahabba School</p>
''',
    contentText: r'''
The Student Affairs Department at Al-Mahabba School announces that all students who have submitted their applications through the school's official website must receive a confirmation email after completing the registration process.
If you do not receive the confirmation email within 24 hours, please:
Check your Spam or Junk email folder.
Or contact us via private messages on the school’s official page.
Please note that the confirmation email is a primary proof of successful registration and review by the administration.
Thank you for your cooperation.
Sincerely,
Student Affairs Department – Al-Mahabba School''',
  ),
];
