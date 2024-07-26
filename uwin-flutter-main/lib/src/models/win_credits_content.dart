class WinCreditsContent {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String text;
  final String registerButtonLabel;

  WinCreditsContent.fromMap(Map<String, dynamic> data)
      : title = data['title']?.replaceAll('\\n', '\n'),
        subtitle = data['subtitle']?.replaceAll('\\n', '\n'),
        imageUrl = data['imageUrl']?.replaceAll('\\n', '\n'),
        registerButtonLabel = data['registerButtonLabel']?.replaceAll('\\n', '\n'),
        text = data['text']?.replaceAll('\\n', '\n');
}
