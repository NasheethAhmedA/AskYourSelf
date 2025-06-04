import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportUsScreen extends StatelessWidget {
  const SupportUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Us'),
      ),
      body: Center(
        heightFactor: 1.0,
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.all(24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'How You Can Support Us ?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  ' Share the app with your friends and family.\n'
                  ' Leave a Star on the GitHub repository.\n'
                  ' Send us your feedback and suggestions.\n'
                  ' Create an issue on GitHub.\n'
                  ' Keep using the app and enjoy\n the journey of self-discovery!',
                  style: TextStyle(fontSize: 16, letterSpacing: 0.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    const url = 'https://github.com/NasheethAhmedA/AskYourSelf';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text('Github Repo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
