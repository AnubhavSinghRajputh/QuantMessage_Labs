import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WindcrestAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WindcrestAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;

  Future<void> _launchUrl() async {
    final Uri url = Uri(scheme: 'https', host: 'windcrest-gilt.vercel.app');
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      title: title,
      leading: leading,
      actions: [
        TextButton.icon(
          onPressed: _launchUrl,
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text(
            'WindCrest',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class WindcrestPage extends StatelessWidget {
  const WindcrestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WindcrestAppBar(
        title: const Text('WindCrest Demo'),
      ),
      body: const Center(
        child: Text(
          'Press the “WindCrest” button in the AppBar to open the site.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
