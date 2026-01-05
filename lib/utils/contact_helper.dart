import 'package:url_launcher/url_launcher.dart';
import 'contact_info.dart';

class ContactHelper {
  static Future<void> launchWhatsApp({String? number, String? text}) async {
    final phone = number ?? defaultSupplierWhatsApp;
    final encoded = Uri.encodeComponent(text ?? 'Hello, I would like to inquire about a product.');
    final url = Uri.parse('https://wa.me/$phone?text=$encoded');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  static Future<void> makeCall({String? phoneNumber}) async {
    final phone = phoneNumber ?? defaultSupplierPhone;
    final url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  static Future<void> sendEmail({String? toEmail, String? subject, String? body}) async {
    final email = toEmail ?? defaultSupplierEmail;
    final query = Uri(queryParameters: {'subject': subject ?? '', 'body': body ?? ''}).query;
    final url = Uri(scheme: 'mailto', path: email, query: query);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
