/// Opens the platform app store to the URL the backend supplies for the
/// current app-version config.
library;

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreRedirectService {
  static Future<bool> openStoreFromUrl(String storeUrl) async {
    try {
      final url = Uri.parse(storeUrl);
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      debugPrint('Error opening store URL: $e');
      return false;
    }
  }
}
