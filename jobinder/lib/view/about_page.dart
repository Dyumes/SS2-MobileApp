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
      // avatarUrl: 'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/6cd0e71a-b00b-4729-b98c-7ad3551e823e/dj9yhf8-403d6490-25e0-4f83-9e3b-4feacee2ed5a.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiIvZi82Y2QwZTcxYS1iMDBiLTQ3MjktYjk4Yy03YWQzNTUxZTgyM2UvZGo5eWhmOC00MDNkNjQ5MC0yNWUwLTRmODMtOWUzYi00ZmVhY2VlMmVkNWEuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.HK54xApb0XVDHP0v2zgKFgUls9YeDbQxNR9iBFTTl08'
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
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 24,
            children: developers
                .map((dev) => _DeveloperAvatar(
                      developer: dev,
                      onTap: () => _openUrl('https://github.com/${dev.username}'),
                    ))
                .toList(),
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