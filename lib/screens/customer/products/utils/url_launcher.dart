import 'package:url_launcher/url_launcher.dart';

void launchCaller(String phone) async {
  final Uri url = Uri(scheme: 'tel', path: phone);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  }
}

void launchEmail(String email) async {
  final Uri emailUri = Uri(scheme: 'mailto', path: email);
  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  }
}
