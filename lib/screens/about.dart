import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/date_formatter.dart';
import '../utils/snackbar_helper.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  double _logoOpacity = 0;
  double _textOpacity = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() => _logoOpacity = 1);
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _textOpacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("about".tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _logoOpacity,
              duration: const Duration(seconds: 3),
              curve: Curves.easeInOut,
              child: Image.asset(
                "assets/images/logo-removebg.png",
                height: 120,
              ),
            ),
            const SizedBox(height: 30),
            AnimatedOpacity(
              opacity: _textOpacity,
              duration: const Duration(seconds: 3),
              curve: Curves.easeInOut,
              child: Text(
                "Welcome to K-Hub — the ultimate playground for K-pop stans! "
                "With K-Hub, you can customize your wallpapers, create personalized widgets, "
                "and express your love for your favorite idols in a unique way.\n\n"
                "Our app is built for fans who want to bring their passion for K-pop into their everyday digital space. "
                "Whether you want a stunning home screen wallpaper, a countdown widget for comebacks, "
                "or a personalized widget showing your favorite group, K-Hub has you covered.\n\n"
                "Features include:\n\n"
                "• Wallpaper Customization — Mix images, text, and colors to design your perfect Kpop wallpaper.\n"
                "• Widget Creator — Build custom widgets for your home screen featuring countdowns, images, or quotes.\n"
                "• Fan Packs & Stickers — Add themed packs for your favorite groups to make your designs even more special.\n"
                "• Easy Sharing & Saving — Export your creations to use on your device or share with friends.\n\n"
                "K-Hub is your personal K-pop studio, letting you bring your bias directly to your phone screen. "
                "Express your fandom, personalize your device, and show off your creativity!\n\n"
                "Stay inspired, stay creative, and let K-Hub turn your love for K-pop into art right on your screen.",
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpItem(
            'How to create wallpapers?'.tr(),
            'Use the Wallpaper Creator to add backgrounds, text, and K-pop elements to create custom wallpapers.'.tr(),
          ),
          _buildHelpItem(
            'How to create widgets?'.tr(),
            'Use the Widget Creator to choose from various widget types and customize their appearance.'.tr(),
          ),
          _buildHelpItem(
            'Where are my creations saved?'.tr(),
            'All your creations are saved in the cloud and can be accessed from any device.'.tr(),
          ),
          _buildHelpItem(
            'Can I share my creations?'.tr(),
            'Yes! You can share your wallpapers and widgets with other K_Verse users.'.tr(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'needHelp'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ContactScreen()),
                      );
                    },
                    child: Text('contactOurSupportTeam'.tr()),
                  ),
                ],
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(answer),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("privacyPolicy".tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "K-Hub (\"we,\" \"our,\" or \"us\") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our K-Hub mobile application.\n\n"
                "1. Information We Collect\n\n"
                "• Personal Information: When you create an account, we may collect your name, email address, and profile picture.\n"
                "• Content You Create: We store the wallpapers, widgets, and designs you create within the app.\n"
                "• Device Information: We may collect device type, operating system, and app usage statistics to improve our services.\n"
                "• Images: If you choose to upload personal photos for customization, we store them securely on our servers.\n\n"
                "2. How We Use Your Information\n\n"
                "• To provide and maintain our service\n"
                "• To personalize your experience and show relevant content\n"
                "• To improve our app and develop new features\n"
                "• To communicate with you about updates and new features\n"
                "• To ensure the security and integrity of our service\n\n"
                "3. Data Storage and Security\n\n"
                "• Your data is stored on secure servers with encryption\n"
                "• We implement appropriate technical and organizational measures to protect your personal information\n"
                "• We retain your data only for as long as necessary to provide our services\n\n"
                "4. Third-Party Services\n\n"
                "We may use third-party services that have their own privacy policies:\n"
                "• Firebase Analytics for app usage statistics\n"
                "• Cloud storage providers for your creations\n"
                "• Payment processors for premium features (if applicable)\n\n"
                "5. Your Rights\n\n"
                "You have the right to:\n"
                "• Access and download your personal data\n"
                "• Correct inaccurate information\n"
                "• Delete your account and associated data\n"
                "• Opt-out of marketing communications\n\n"
                "6. Children's Privacy\n\n"
                "Our service is not intended for children under 13. We do not knowingly collect information from children under 13.\n\n\n"
                "We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the \"Last Updated\" date.\n\n".tr(),
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 30),
              Text("${'Last Updated'.tr()}: 15/12/2025", style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
        )
      ),
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("termsOfService".tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Please read these Terms of Service (\"Terms\") carefully before using the K-Hub mobile application (the \"Service\") operated by K-Hub (\"us,\" \"we,\" or \"our\").\n\n"
                "1. Acceptance of Terms\n\n"
                "By accessing or using our Service, you agree to be bound by these Terms. If you disagree with any part of the terms, you may not access the Service.\n\n"
                "2. User Accounts\n\n"
                "• You must be at least 13 years old to use this Service\n"
                "• You are responsible for maintaining the security of your account\n"
                "• You must not share your account credentials with others\n"
                "• You are responsible for all activities that occur under your account\n\n"
                "3. User Content\n\n"
                "• You retain all rights to the content you create within K-Hub\n"
                "• By uploading content, you grant us a license to store and display that content within our Service\n"
                "• You are solely responsible for the content you create and share\n"
                "• You must not upload content that infringes on copyrights or intellectual property rights\n\n"
                "4. Prohibited Uses\n\n"
                "• For any unlawful purpose or to solicit others to perform illegal acts\n"
                "• To infringe upon or violate our intellectual property rights or others'\n"
                "• To harass, abuse, insult, harm, or discriminate against others\n"
                "• To submit false or misleading information\n"
                "• To upload or transmit viruses or any malicious code\n"
                "• To spam, phish, or engage in other unethical activities\n\n"
                "5. Intellectual Property\n\n"
                "• The K-Hub app, its original content, features, and functionality are owned by K-Hub and are protected by international copyright and intellectual property laws\n"
                "• K-pop group names, logos, and official content are property of their respective companies\n"
                "• You may not reproduce, duplicate, copy, or resell any part of our Service without express written permission\n\n"
                "6. Termination\n\n"
                "We may terminate or suspend your account immediately, without prior notice, for conduct that we believe violates these Terms or is harmful to other users, us, or third parties, or for any other reason.\n\n"
                "7. Limitation of Liability\n\n"
                "In no event shall K-Hub, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses.\n\n"
                "8. Changes to Terms\n\n"
                "We reserve the right, at our sole discretion, to modify or replace these Terms at any time. We will provide notice of any changes by posting the new Terms on this page.\n\n".tr(),
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 20),
              Text("${'Last Updated'.tr()}: 15/12/2025", style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    const email = 'kentcwk26@gmail.com';
    const subject = 'K-Hub App Support';
    const body = 'Hello K-Hub Team,\n\nI would like to contact you about:';
    
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    
    try {
      final launched = await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        _copyToClipboard(context, email);
      }
    } catch (e) {
      _copyToClipboard(context, email);
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    SnackBarHelper.showSuccess(context, '${'Email copied to clipboard'.tr()}: $text');
  }

  Future<void> _launchURL(BuildContext context, String url, {String? fallbackMessage}) async {
    final uri = Uri.parse(url);
    
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        if (context.mounted) {
          SnackBarHelper.showError(
            context, 
            fallbackMessage ?? "Could not open the link".tr()
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(
          context, 
          fallbackMessage ?? "Error opening link".tr()
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("contactUs".tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.contact_support,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20),
            Text(
              "We'd Love to Hear From You!".tr(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Have questions, feedback, or need support? Reach out to us through any of the following methods:".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 30),
            
            
            _buildContactCard(
              icon: Icons.email,
              title: "Email Support".tr(),
              subtitle: "Get direct help from our team".tr(),
              onTap: () => _launchEmail(context),
            ),
            
            const SizedBox(height: 16),
            
            _buildContactCard(
              icon: Icons.bug_report,
              title: "Got Feedback?".tr(),
              subtitle: "Help us improve the app".tr(),
              onTap: () => _launchURL(
                context, 
                'https://docs.google.com/forms/d/e/1FAIpQLSeCtyveoWlfjwtXbBwUufZLHqUlSgDCp-9QiPHIXR7lmb7uvQ/viewform?usp=header', 
                fallbackMessage: "Feedback form unavailable".tr(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildContactCard(
              icon: Icons.thumb_up,
              title: "Rate Our App".tr(),
              subtitle: "Leave a review on the app store".tr(),
              onTap: () {}
            ),
            
            const SizedBox(height: 30),
            Text(
              "We typically respond within 24-48 hours. \nThank you for using K-Hub! 💖".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("faq".tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Icon(
                  Icons.help_outline,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Frequently Asked Questions".tr(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Find quick answers to common questions about K-Hub".tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              const SizedBox(height: 30),

              
              Text(
                "Getting Started".tr(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildFAQItem(
                question: "How do I create my first wallpaper?".tr(),
                answer: "Tap the 'Create' button on the home screen, then:\n\n1. Choose a background image from your gallery or our K-pop collections\n2. Add text, stickers, or effects\n3. Customize the layout and colors\n4. Save to your device or set as wallpaper".tr(),
              ),
              _buildFAQItem(
                question: "Is K-Hub free to use?".tr(),
                answer: "Yes! K-Hub is completely free to download and use. We offer basic wallpaper and widget creation features at no cost. Some premium sticker packs and advanced features may be available as in-app purchases in the future.".tr(),
              ),
              _buildFAQItem(
                question: "How do I set a widget on my home screen?".tr(),
                answer: "After creating a widget:\n\n1. Long-press on your home screen\n2. Select 'Widgets' from the menu\n3. Find K-Hub in the widget list\n4. Choose your created widget and place it on your home screen\n\nNote: Widget setup may vary slightly depending on your device and Android version.".tr(),
              ),

              const SizedBox(height: 30),
              Text(
                "Account & Data".tr(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildFAQItem(
                question: "How do I reset my password?".tr(),
                answer: "Go to Settings > Account > Reset Password. You'll receive an email with a password reset link. Make sure to check your spam folder if you don't see it in your inbox.".tr(),
              ),
              _buildFAQItem(
                question: "Can I use K-Hub on multiple devices?".tr(),
                answer: "Yes! Your account syncs across all your devices. Simply log in with the same account on any device, and your creations, preferences, and sticker packs will be available.".tr(),
              ),
              _buildFAQItem(
                question: "How do I delete my account?".tr(),
                answer: "Go to Settings > Danger Zone > Delete Account. This will permanently remove all your data, including creations, preferences, and account information. This action cannot be undone.".tr(),
              ),

              const SizedBox(height: 30),
              Text(
                "Content & Creation".tr(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildFAQItem(
                question: "Can I use my own K-pop images?".tr(),
                answer: "Yes! You can upload your own images from your gallery. We recommend using high-quality images for the best results. Please respect copyright and only use images for personal, non-commercial purposes.".tr(),
              ),
              _buildFAQItem(
                question: "What are fan packs and how do I get them?".tr(),
                answer: "Fan packs are themed collections of stickers, backgrounds, and fonts featuring your favorite K-pop groups. You can access free fan packs in the 'Store' section. New packs are added regularly!".tr(),
              ),
              _buildFAQItem(
                question: "Can I share my creations with friends?".tr(),
                answer: "Absolutely! After creating a wallpaper or widget, tap the share button to export your creation. You can share via social media, messaging apps, or save it to your device to share later.".tr(),
              ),

              const SizedBox(height: 30),
              Text(
                "Technical Issues".tr(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildFAQItem(
                question: "Why are my widgets not updating?".tr(),
                answer: "If widgets aren't updating:\n\n• Check your device's battery optimization settings and exclude K-Hub\n• Ensure you have a stable internet connection\n• Try removing and re-adding the widget\n• Restart the app and your device\n\nIf issues persist, contact our support team.".tr(),
              ),
              _buildFAQItem(
                question: "The app is crashing, what should I do?".tr(),
                answer: "Try these steps:\n\n1. Restart the app\n2. Update to the latest version from the app store\n3. Clear app cache (Settings > Storage > Clear Cache)\n4. Reinstall the app (your data is safe in the cloud)\n\nIf crashes continue, report the issue through the Contact screen with details about when it happens.".tr(),
              ),
              _buildFAQItem(
                question: "Why can't I save my creations?".tr(),
                answer: "Saving issues are usually related to:\n\n• Storage permissions - make sure K-Hub has permission to access your storage\n• Low device storage - check if you have enough space\n• Network issues - cloud saves require internet connection\n\nCheck these settings and try again.".tr(),
              ),

              const SizedBox(height: 30),
              Text(
                "K-Pop & Copyright".tr(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildFAQItem(
                question: "Can I use official group logos in my creations?".tr(),
                answer: "Yes, for personal use! K-Hub is designed for fans to express their love for K-pop. However, you cannot use created content for commercial purposes or claim official logos as your own work.".tr(),
              ),
              _buildFAQItem(
                question: "Are there any restrictions on which groups I can feature?".tr(),
                answer: "No restrictions! K-Hub supports all K-pop groups. We have content for popular groups like BTS, BLACKPINK, TWICE, Stray Kids, and many more. You can request specific groups through our feature request form.".tr(),
              ),
              _buildFAQItem(
                question: "Can I sell creations I make with K-Hub?".tr(),
                answer: "No. All creations made with K-Hub are for personal, non-commercial use only. You cannot sell, distribute, or use K-Hub creations for commercial purposes due to copyright restrictions on K-pop content.".tr(),
              ),

              const SizedBox(height: 20),
              
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.support_agent, size: 40, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text(
                            "Still Need Help?".tr(),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Can't find the answer you're looking for? Our support team is here to help!".tr(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
                        },
                        child: Text("Contact Support".tr()),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        )
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        backgroundColor: Colors.grey[50],
        collapsedBackgroundColor: Colors.grey[50],
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}