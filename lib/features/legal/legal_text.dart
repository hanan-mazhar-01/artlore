/// The words of ArtLore's Privacy Policy and Terms of Use, kept in the app so
/// they can always be read, with or without a connection.
///
/// Each section is a heading and its paragraphs. Bullet lines start with "• ".
class LegalSection {
  const LegalSection(this.heading, this.body);

  final String heading;
  final List<String> body;
}

abstract final class LegalInfo {
  /// Where visitors can write to. Fill this in before release: the policy
  /// shows a contact line only when it is set.
  static const supportEmail = 'support@veradostudio.com';

  static const effective = 'October 2026';
}

abstract final class LegalText {
  static const privacyIntro =
      'ArtLore, from Verado Studio, helps you find out about paintings. This '
      'policy explains what the app collects, who it is shared with, and the '
      'choices you have.';

  static const privacy = [
    LegalSection('What we collect', [
      '• Your account — your name and email, or the Apple or Google account '
          'ID you sign in with. Guests get an anonymous ID instead.',
      '• Photos you scan — pictures taken with the camera or chosen from your '
          'library, only when you scan them.',
      '• Your activity in the app — scan history, saved works, galleries and '
          'which paintings you opened.',
      '• A device identifier — on iPhone, the identifier for vendor, used '
          'only to give each device one set of free scans.',
      '• Subscription status — whether Premium is active, handled by Apple '
          'and RevenueCat. We never see your card or Apple ID details.',
    ]),
    LegalSection('Your photos and AI', [
      'To tell you which painting you are looking at, ArtLore sends the '
          'photo you scan to Google\'s Gemini AI service. It is sent over an '
          'encrypted connection, only when you scan, and only for that '
          'purpose. Nothing else from your phone is sent with it.',
      'We ask for your permission before your first scan, and you can '
          'withdraw it any time in Settings. Without it, scanning from the '
          'camera or from your own photos is switched off; the museum pieces '
          'built into the app still work.',
      'The AI can make mistakes. Titles, dates and stories it produces are '
          'for interest, not authority, and should not be relied on.',
      'How Google handles data sent to Gemini is described in Google\'s own '
          'terms and privacy policy.',
    ]),
    LegalSection('Who else receives data', [
      '• Google Firebase — sign-in, the database that holds your account '
          'data, and app settings.',
      '• Google Gemini — the photo you scan, as described above.',
      '• Google Sign-In and Sign in with Apple — only if you choose them.',
      '• RevenueCat and Apple — to run subscriptions and restore purchases.',
      'We do not sell your data, and we do not use it to track you across '
          'other apps or websites. ArtLore shows no ads.',
    ]),
    LegalSection('Where it is kept, and for how long', [
      'Your account data and the photos that belong to your saved works and '
          'history are kept in your account until you delete them or delete '
          'your account.',
      'Photos are not kept on a separate server of ours. Pictures of '
          'artworks the AI could not name are stored with your history so '
          'they can be shown again.',
    ]),
    LegalSection('Deleting your data', [
      'Open Profile, then Delete Account. This removes your profile, scan '
          'history, saved works, galleries, stored pictures and free-scan '
          'record, and deletes your sign-in.',
      'One thing stays: a small record, made of the device identifier and '
          'the ID of the first account on it, that stops free scans being '
          'claimed again by deleting and recreating accounts. It holds no '
          'name, email or photos.',
    ]),
    LegalSection('Your choices', [
      '• Camera and photos — ArtLore asks only when you use them, and works '
          'with the museum pieces if you say no.',
      '• AI photo analysis — withdraw consent in Settings at any time.',
      '• Guest or account — you can try ArtLore as a guest.',
    ]),
    LegalSection('Changes', [
      'If this policy changes in a way that matters, the app will tell you '
          'before it takes effect.',
    ]),
  ];

  static const termsIntro =
      'These terms govern your use of ArtLore. By using the app you agree to '
      'them. Apple\'s Standard End User License Agreement also applies.';

  static const terms = [
    LegalSection('Using ArtLore', [
      'ArtLore is for personal, non-commercial use. Scan only artworks and '
          'photos you are free to photograph, and do not misuse or try to '
          'disrupt the service.',
    ]),
    LegalSection('Information and AI', [
      'Artwork information and stories, including anything produced by AI, '
          'are provided for interest only and may be incomplete or wrong. '
          'ArtLore does not guarantee that a painting has been identified '
          'correctly, and is not a valuation, authentication or expert opinion.',
    ]),
    LegalSection('ArtLore Premium', [
      'Premium is an auto-renewing subscription, offered monthly or yearly. '
          'The price and any free trial are shown on the subscription screen '
          'before you buy, in your local currency.',
      '• Payment is charged to your Apple ID when you confirm the purchase.',
      '• The subscription renews automatically unless it is cancelled at '
          'least 24 hours before the end of the current period.',
      '• Your account is charged for renewal within 24 hours before the end '
          'of the current period, at the price shown for that plan.',
      '• Any unused part of a free trial is forfeited when you subscribe.',
      '• You can manage or cancel in your App Store account settings, and '
          'restore purchases from the subscription screen.',
    ]),
    LegalSection('Free scans', [
      'Each device receives a small number of free scans, and signing up '
          'adds a few more. Free scans are not transferable and may be '
          'changed.',
    ]),
    LegalSection('Your content', [
      'Photos and collections you add stay yours. You allow ArtLore to '
          'process them to provide the service, as the Privacy Policy '
          'describes.',
    ]),
    LegalSection('Changes and ending', [
      'You can stop using ArtLore and delete your account at any time. We '
          'may update these terms and will tell you about important changes.',
    ]),
  ];
}
