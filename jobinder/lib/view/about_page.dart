import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const List<_Developer> developers = [
    _Developer(
      name: 'Gabriel Schönmann',
      username: 'Yuno-011',
      avatarUrl: 'https://avatars.githubusercontent.com/u/171320905?v=4',
    ),
    _Developer(
      name: 'Julien Roduit',
      username: 'rdtjulien',
      avatarUrl: 'https://avatars.githubusercontent.com/u/192200173?v=4',
    ),
    _Developer(
      name: 'David Braz Jorge',
      username: 'Dav0105',
      avatarUrl: 'https://avatars.githubusercontent.com/u/120047730?v=4',
    ),
    _Developer(
      name: 'Gaëtan Veuillet',
      username: 'Dyumes',
      avatarUrl: 'https://avatars.githubusercontent.com/u/76482455?v=4',
    ),
  ];

  static const String teamRole = 'Developer';
  static const String teamDescription =
      '3rd-year Computer Engineering and Communication Systems | '
      'Data engineer students at HES-SO Valais-Wallis';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        children: [
          // --- Team section ---
          const Text(
            'Made By',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            teamDescription,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1000
                  ? 4
                  : constraints.maxWidth >= 500
                      ? 2
                      : 1;

              final rows = <Widget>[];

              for (var i = 0; i < developers.length; i += columns) {
                final row = developers
                    .skip(i)
                    .take(columns)
                    .map(
                      (dev) => _DeveloperAvatar(
                        developer: dev,
                        onTap: () => _openUrl(
                          'https://github.com/${dev.username}',
                        ),
                      ),
                    )
                    .toList();

                rows.add(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var j = 0; j < row.length; j++) ...[
                        if (j > 0) const SizedBox(width: 24),
                        row[j],
                      ],
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    rows[i],
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Developer {
  final String name;
  final String username;
  final String avatarUrl;

  const _Developer({
    required this.name,
    required this.username,
    required this.avatarUrl,
  });
}

class _DeveloperAvatar extends StatelessWidget {
  final _Developer developer;
  final VoidCallback onTap;

  const _DeveloperAvatar({required this.developer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const double size = 192;

    return SizedBox(
      width: 224,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.deepPurple, width: 2.5),
            ),
            child: ClipOval(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: Image.network(
                    developer.avatarUrl,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        width: size,
                        height: size,
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: size,
                      height: size,
                      color: Colors.deepPurple.shade100,
                      alignment: Alignment.center,
                      child: Text(
                        developer.name.isNotEmpty
                            ? developer.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            developer.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            AboutPage.teamRole,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}