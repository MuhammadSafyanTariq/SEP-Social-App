// import 'package:flutter/material.dart';
// import 'package:sep/components/styles/textStyles.dart';
// import 'package:sep/components/coreComponents/TextView.dart';
// import 'package:sep/components/styles/appColors.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:sep/feature/data/repository/iTempRepository.dart';
// import 'package:sep/feature/domain/respository/templateRepository.dart';
// import 'package:sep/utils/extensions/extensions.dart';
//
// import '../../../../data/models/dataModels/responseDataModel.dart';
// import '../../../../data/models/dataModels/termsConditionModel.dart';
// import '../../../../data/repository/iAuthRepository.dart';
//
// class Termandconditions extends StatefulWidget {
//   const Termandconditions({super.key});
//
//   @override
//   _TermandconditionsState createState() => _TermandconditionsState();
// }
//
// class _TermandconditionsState extends State<Termandconditions> {
//   late Future<ResponseData<TermsConditionModel>> _termsFuture;
//   final TempRepository tempRepository = ITempRepository();
//   String? description;
//
//   Future<ResponseData<TermsConditionModel>> _fetchTerms() async {
//     return await tempRepository.getTermsAndCondations();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _termsFuture = _fetchTerms();
//     _termsFuture.applyLoader.then((value) {
//       setState(() {
//         description = value.data!.data!.description;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryColor,
//         centerTitle: true,
//         title: TextView(
//           text: 'Terms of Use',
//           style: 20.txtBoldWhite,
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new,
//               color: AppColors.white, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 22.0),
//         child: TextView(
//           text: description.toString() != "null" ? description.toString() : " ",
//           style: 14.txtRegularWhite,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/AppBar2.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';

class Termandconditions extends StatefulWidget {
  const Termandconditions({super.key});

  @override
  _TermandconditionsState createState() => _TermandconditionsState();
}

class _TermandconditionsState extends State<Termandconditions>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  final List<String> _categories = ['General', 'Sales & Transactions', 'Jobs'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar2(
            title: "Terms & Conditions",
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            hasTopSafe: true,
          ),

          // Category Chips
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.sdp, vertical: 12.sdp),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _categories.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(right: 8.sdp),
                    child: ChoiceChip(
                      label: Text(_categories[index]),
                      selected: _selectedIndex == index,
                      onSelected: (selected) {
                        if (selected) {
                          _tabController.animateTo(index);
                        }
                      },
                      selectedColor: AppColors.btnColor,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: _selectedIndex == index
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: _selectedIndex == index
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.sdp,
                        vertical: 10.sdp,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.sdp),
                        side: BorderSide(
                          color: _selectedIndex == index
                              ? AppColors.btnColor
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTerms(),
                _buildSalesTerms(),
                _buildJobsTerms(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTerms() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sdp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Terms of Use & End User License Agreement (EULA)',
          ),
          _buildSubtitle('Last Updated: March 2025'),
          SizedBox(height: 16.sdp),

          _buildSection(
            '1. Acceptance of Terms',
            'By downloading, installing, or using SEP, you agree to be bound by these Terms of Use and our End User License Agreement (EULA). If you do not agree, please do not use the app.',
          ),

          _buildSection(
            '2. License Grant',
            'SEP grants you a limited, non-transferable, non-exclusive license to use the app for personal and non-commercial purposes.',
          ),

          _buildSection('3. User Conduct', ''),

          _buildSubSection(
            '🌐 Community Standards & Safety Guidelines',
            'At SEP Media, we\'re committed to maintaining a safe, respectful, and inclusive space for all users. To ensure that our platform stays welcoming and free from harm, we ask everyone to follow these essential guidelines:',
          ),

          _buildBulletPoint(
            '🚫 No Discrimination or Hate Speech',
            'Content that is defamatory, discriminatory, or mean-spirited is strictly prohibited. This includes negative references to religion, race, gender, sexual orientation, nationality, ethnicity, or other protected groups—especially if the content is intended to humiliate, intimidate, or harm. We celebrate diversity and do not tolerate hate in any form. Note: Satirical or humorous content from professional creators may be exempt if it\'s respectful and within legal bounds.',
          ),

          _buildBulletPoint(
            '⚠️ No Violence or Graphic Content',
            'We do not allow content that depicts or encourages violence, including:\n• Realistic portrayals of people or animals being harmed or abused\n• Violent scenarios targeting specific real-world entities\n• Content that glorifies or promotes the illegal or unsafe use of weapons',
          ),

          _buildBulletPoint(
            '❌ No Explicit or Pornographic Content',
            'Content that is overtly sexual, pornographic, or intended to arouse rather than inform or express emotion is not permitted. This includes any use of the app for hookups, adult services, or any form of sexual exploitation or human trafficking.',
          ),

          _buildBulletPoint(
            '✝️ No Inflammatory Religious Content',
            'Content that includes offensive or misleading religious commentary, or inaccurately quotes religious texts to incite tension or conflict, is not allowed.',
          ),

          _buildBulletPoint(
            '🚫 No False or Harmful Functionality',
            'Apps or content that spread false information, simulate fake services (e.g., prank features, fake trackers), or mislead users—even under the label of "entertainment"—are prohibited. Anonymous or prank calls, messages, or deceptive functionalities will be rejected.',
          ),

          _buildBulletPoint(
            '🛑 No Exploitation of Tragedies or Current Events',
            'Content that seeks to profit from tragic, violent, or sensitive current events (e.g., terrorism, pandemics, wars) is not acceptable.',
          ),

          _buildSubSection(
            '🧑‍💻 User-Generated Content Policy',
            'To ensure a respectful experience across our platform, we have features that allow users to:\n• Filter and remove offensive content\n• Report inappropriate behavior or material\n• Block users to prevent abusive interactions\n• Access contact info for user support',
          ),

          _buildSection(
            '4. Privacy Policy',
            'Your privacy is important to us. Please review our Privacy Policy to understand how we collect and use your data.',
          ),

          _buildSection(
            '5. Termination',
            'We reserve the right to suspend or terminate your access to SEP if you violate these terms.',
          ),

          _buildSection(
            '6. Disclaimer of Warranties',
            'SEP is provided "as is" without any warranties, express or implied. We do not guarantee uninterrupted or error-free service.',
          ),

          _buildSection(
            '7. Limitation of Liability',
            'We shall not be liable for any damages arising from your use of SEP, including loss of data or personal injury.',
          ),

          _buildSection(
            '8. Changes to Terms',
            'We may update these Terms of Use from time to time. Continued use of SEP after changes constitute your acceptance of the new terms.',
          ),

          _buildSection(
            '9. Contact Us',
            'If you have any questions about these terms, please contact us at onesepmedia@gmail.com.',
          ),

          SizedBox(height: 20.sdp),
        ],
      ),
    );
  }

  Widget _buildSalesTerms() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sdp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Community Sales & Transaction Disclaimer'),
          _buildSubtitle('Legal Version'),
          SizedBox(height: 16.sdp),

          _buildSection(
            '1. Independent Transactions',
            'SEP-Media ("the Platform") provides a digital environment that allows users to communicate, post content, buy, sell, and exchange goods or services. The Platform does not act as a broker, agent, guarantor, or intermediary for any transaction between users.\n\nAll transactions conducted through or as a result of interactions on SEP-Media are undertaken solely at the discretion and risk of the participating users.',
          ),

          _buildSection(
            '2. No Liability for User Conduct',
            'SEP-Media does not verify, screen, or authenticate users, listings, products, services, or any claims made by users. The Platform does not guarantee the legitimacy, quality, safety, compliance, or accuracy of any goods, services, or representations offered by users.\n\nAccordingly, SEP-Media shall not be held liable for any loss, damage, injury, fraud, deception, theft, or dispute arising from or connected to user-to-user transactions or interactions, whether online or offline.',
          ),

          _buildSection(
            '3. User Due Diligence Requirement',
            'All users acknowledge and agree that they are solely responsible for conducting reasonable due diligence before entering any transaction. This includes, but is not limited to:',
          ),

          _buildBulletList([
            'Verifying the identity and background of the other party',
            'Confirming the authenticity and condition of goods or services',
            'Assessing the credibility and intentions of individuals they choose to meet or transact with',
          ]),

          _buildSection(
            '4. Safety Measures for In-Person Transactions',
            'Users are strongly advised to conduct in-person transactions in safe, public locations, or in the presence of a licensed law enforcement officer, authorized security personnel, or other credible third-party witness.\n\nUsers must take all necessary precautions to protect themselves, their property, their funds, and their family when participating in any transaction arising from activity on the Platform.',
          ),

          _buildSection(
            '5. Assumption of Risk',
            'By accessing or using SEP-Media, users expressly agree that they assume full responsibility and all risks associated with any transaction, communication, meeting, or exchange facilitated through the Platform.\n\nUsers further agree that SEP-Media, its owners, employees, affiliates, and partners shall not be responsible or liable for any direct, indirect, incidental, consequential, or punitive damages arising out of user interactions or transactions.',
          ),

          _buildSection(
            '6. Acceptance of Terms',
            'By continuing to use SEP-Media, users acknowledge that they have read, understood, and agreed to be bound by this Community Sales & Transaction Disclaimer, and that they release SEP-Media from any and all claims related to user-to-user dealings.',
          ),

          SizedBox(height: 20.sdp),
        ],
      ),
    );
  }

  Widget _buildJobsTerms() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sdp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('SEP Media – Job Search Terms & Conditions'),
          _buildSubtitle('Extended Legal Version'),
          SizedBox(height: 16.sdp),

          _buildSection(
            '1. Platform Purpose and Limited Role',
            '1.1 SEP Media provides an online environment where users may post, search, and apply for full-time, part-time, contract, freelance, temporary, and internship opportunities.\n\n1.2 SEP Media is not:\n• An employer of any user\n• A staffing agency, recruiter, labor broker, or employment representative\n• A party to any employment, service, or contractual agreement formed between users\n\n1.3 SEP Media does not screen, verify, or endorse:\n• The identity or background of any user\n• The accuracy or legitimacy of job postings\n• The qualifications, skills, or suitability of job seekers\n• The reliability, professionalism, or business practices of employers\n\nUsers understand and accept that SEP Media functions solely as a communication and listing platform.',
          ),

          _buildSection('2. User Responsibilities', ''),

          _buildSubSection(
            '2.1 Employer & Job Poster Obligations',
            'Employers or job posters agree to:',
          ),

          _buildBulletList([
            'Provide truthful, accurate, and up-to-date job information',
            'Clearly communicate job duties, compensation, work location, schedule, and expectations',
            'Comply with all applicable employment, labor, wage, tax, and business laws',
            'Conduct their own background checks, work authorization checks, identity verification, and reference checks',
            'Ensure the safety and legitimacy of the job opportunity',
          ]),

          _buildSubSection(
            '2.2 Job Seeker Obligations',
            'Job seekers agree to:',
          ),

          _buildBulletList([
            'Provide accurate information regarding their skills, experience, and qualifications',
            'Independently evaluate job postings, employers, and offers',
            'Take all necessary safety measures before meeting or working with an employer',
            'Understand that compensation, job conditions, and offers are solely the responsibility of the employer',
          ]),

          _buildSection(
            '3. No Guarantee or Endorsement',
            '3.1 SEP Media makes no guarantee, representation, or warranty regarding:\n• The quality, honesty, ability, or behavior of any employer or job seeker\n• The accuracy of information posted by users\n• The availability or legitimacy of job opportunities listed on the Platform\n• The safety or outcome of any job-related interaction\n\n3.2 All hiring decisions, work arrangements, payments, job performance, and agreements occur entirely between users. SEP Media is not responsible for supervising, managing, or enforcing any agreement.',
          ),

          _buildSection(
            '4. Work Quality, Performance & Conduct',
            '4.1 SEP Media is not responsible for:\n• Inadequate, incomplete, or poor work performance by job seekers\n• Damages, losses, or injuries caused during a work arrangement\n• Misconduct, harassment, discrimination, unsafe conditions, or illegal behavior by any user\n• Late payment, non-payment, fraud, or breach of agreement by employers\n\n4.2 Employers and job seekers both acknowledge they engage with each other at their own risk.',
          ),

          _buildSection(
            '5. Safety, Verification & Due Diligence',
            '5.1 SEP Media strongly advises all users to:\n• Conduct full background checks or request references where appropriate\n• Verify identification, licenses, and qualifications of users before entering an agreement\n• Meet in safe, public places or with appropriate law-enforcement officers when necessary\n• Protect personal information, finances, property, and family safety\n\n5.2 While SEP Media may offer optional safety tools or reporting features, these tools:\n• Are optional\n• Do not replace user due diligence\n• Do not make SEP Media liable for user behavior',
          ),

          _buildSection(
            '6. Disputes Between Users',
            '6.1 SEP Media has no obligation to resolve disputes between users.\n\n6.2 SEP Media is not liable for any claim, loss, damage, or harm resulting from:\n• Job performance disputes\n• Payment disputes\n• Misunderstandings or miscommunications\n• Contractual or verbal agreements\n• Misconduct or illegal behavior by any user\n\nUsers must resolve disputes independently or through appropriate legal channels.',
          ),

          _buildSection(
            '7. Reporting & Enforcement',
            '7.1 Users may report fraudulent, misleading, or abusive activity. SEP Media may, at its sole discretion:\n• Remove job listings or content\n• Suspend or terminate accounts\n• Restrict access to the Platform\n\n7.2 SEP Media is not required to take action on any report and assumes no responsibility to mediate or intervene.',
          ),

          _buildSection(
            '8. Limitation of Liability',
            'To the fullest extent permitted by law, SEP Media, its owners, affiliates, partners, employees, and agents shall not be liable for any:\n• Direct, indirect, incidental, consequential, or punitive damages\n• Financial losses, property damage, or personal injuries\n• Fraud, misconduct, or illegal acts committed by users\n• Errors, omissions, or inaccuracies in job postings\n• Loss of employment opportunity or failure to obtain work\n\nUse of the Job Services is entirely at the user\'s own risk.',
          ),

          _buildSection(
            '9. Indemnification',
            'Users agree to indemnify, defend, and hold harmless SEP Media from any claims, demands, liabilities, damages, losses, or expenses arising from:\n• Job postings or applications\n• Work agreements or service contracts\n• Disputes or conflicts between users\n• User behavior, actions, or omissions\n• Violations of these Terms',
          ),

          _buildSection(
            '10. Modification of Terms',
            'SEP Media reserves the right to update or modify these Terms at any time. Continued use of the Platform after changes are posted constitutes acceptance of the updated Terms.',
          ),

          _buildSection(
            '11. Acceptance',
            'By accessing or using the Job Services, users acknowledge they have read, understood, and agreed to these Terms & Conditions.',
          ),

          SizedBox(height: 20.sdp),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return TextView(
      text: title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.4,
      ),
    );
  }

  Widget _buildSubtitle(String subtitle) {
    return Padding(
      padding: EdgeInsets.only(top: 4.sdp),
      child: TextView(
        text: subtitle,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.sdp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
            text: title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          if (content.isNotEmpty) ...[
            SizedBox(height: 8.sdp),
            TextView(
              text: content,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sdp, left: 8.sdp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
            text: title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          SizedBox(height: 6.sdp),
          TextView(
            text: content,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sdp, left: 8.sdp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
            text: title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.btnColor,
              height: 1.5,
            ),
          ),
          SizedBox(height: 4.sdp),
          TextView(
            text: content,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sdp, left: 16.sdp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 6.sdp),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: '• ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.btnColor,
                      ),
                    ),
                    Expanded(
                      child: TextView(
                        text: item,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
