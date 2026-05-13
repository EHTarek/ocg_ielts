/// Static long-form text shown by [LegalDocumentScreen] for the
/// *Privacy Policy* and *Terms of Service* rows in Settings.
///
/// These are intentionally kept as Dart constants rather than ARB entries —
/// the bodies are long-form prose, and putting them in `app_en.arb` would
/// make the ARB file unreadable. Translate by adding sibling files keyed
/// by locale when the app needs additional languages.
class LegalTexts {
  LegalTexts._();

  static const String privacyPolicy = '''
Last updated: 2026-05-13

This Privacy Policy describes how the OCG IELTS app handles information when you use the app.

Information We Collect

OCG IELTS does not require an account, does not ask for personal information, and does not collect or transmit any personally identifying data. There is no analytics SDK, no advertising SDK, and no remote server that we operate.

Local Storage

The app stores a small set of preferences on your device only:
• Your selected appearance settings (brightness mode and accent colour).
• The downloaded copy of the Cambridge guide PDF, kept under the app's private documents directory.

These files never leave your device. They are removed when you clear the app's data through your system settings.

Third-Party Services

When you stream an audio track or video lesson, your device fetches the file from a third-party content delivery network (Cloudinary). When you tap "Download book" for the first time, your device fetches the PDF from a public GitHub URL. These requests are standard HTTPS file downloads; the destinations may log standard request metadata (IP address, user agent, timestamps) according to their own privacy policies. We do not control or share access to those logs.

Children's Privacy

OCG IELTS is intended for general study use and does not knowingly collect information from any user.

Content & Attribution

All material accessible through this app — the Cambridge guide PDF and the audio/video catalog — is open source and publicly available online. The app is merely a convenient interface for viewing this material; it does not host, modify, or claim ownership of any of it. Full credit for the content remains with the respective authors, publishers, and rights holders.

Limitation of Liability

The author of this app is not responsible for any unlawful activity that may arise from use of the app or the content it surfaces, nor for any direct or indirect damages resulting from such use. If you believe any item made accessible through the app infringes a copyright or other right, please contact us at support@ocgielts.app and the entry will be removed.

Changes

If we update this policy in a future release of the app, the "Last updated" date above will change. Continued use of the app after an update constitutes acceptance.

Contact

If you have a question about this policy, you can reach us at support@ocgielts.app.
''';

  static const String termsOfService = '''
Last updated: 2026-05-13

By installing or using OCG IELTS you agree to these Terms. If you do not agree, please uninstall the app.

License

You are granted a personal, non-exclusive, non-transferable licence to install and use OCG IELTS on devices you own for the purpose of personal IELTS study. You may not redistribute, resell, or commercially exploit the app or its content.

Content

The Cambridge guide PDF and the audio/video catalog made available within the app are the intellectual property of their respective rights holders. OCG IELTS provides a means to access this material for study; it does not transfer ownership of any content.

No Warranty

The app is provided "as is" and "as available". We do not warrant that the app will be uninterrupted, error-free, or that any defect will be corrected. Streamed media and the downloaded PDF require an active internet connection at the time of first access.

Data Usage

Downloading the study book and streaming media will consume cellular or Wi-Fi data. You are responsible for any data charges from your network provider.

Limitation of Liability

To the maximum extent permitted by applicable law, we shall not be liable for any indirect, incidental, special, or consequential damages arising out of your use of the app.

Modifications

We may revise these Terms from time to time. The current version will always be available in the Settings screen.

Contact

Questions about these Terms can be sent to support@ocgielts.app.
''';
}
