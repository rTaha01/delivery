import 'package:url_launcher/url_launcher.dart';


void launchPhoneDialer(String phoneNumber) async {
  final url = 'tel:$phoneNumber';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void launchWhatsApp(String phoneNumber) async {
  final url = 'https://wa.me/$phoneNumber';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
