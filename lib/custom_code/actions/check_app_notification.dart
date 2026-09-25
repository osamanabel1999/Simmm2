// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future checkAppNotification(BuildContext context) async {
  // لينك جيت هاب بتاعك
  const url =
      'https://raw.githubusercontent.com/osamanabel1999/Simulator-Station-Notficition/refs/heads/main/message.json';
  // لينك تطبيقك على متجر أبل
  const appStoreLink =
      'https://apps.apple.com/eg/app/simulator-station/id6775759816';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return;

    final data = json.decode(response.body);

    final updateInfo = data['update'];
    final announcementInfo = data['announcement'];
    final promoBannerInfo = data['promo_banner']; // القسم الجديد للبانر

    // 1. نظام فحص التحديثات (الأسبق دائماً)
    if (updateInfo != null && updateInfo['latest_version'] != null) {
      final String latestVersion = updateInfo['latest_version'];
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      if (_isNewerVersion(latestVersion, currentVersion)) {
        if (!context.mounted) return;
        _showUpdateSheet(context, updateInfo, appStoreLink);
        return;
      }
    }

    // 2. نظام الإشعارات العادية (الظهور لمرة واحدة)
    if (announcementInfo != null && announcementInfo['message_id'] != null) {
      final int messageId = announcementInfo['message_id'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int lastSeenId = prefs.getInt('last_seen_message_id') ?? 0;

      if (messageId > lastSeenId) {
        if (!context.mounted) return;
        _showAnnouncementSheet(context, announcementInfo, messageId, prefs);
        return; // توقف لعرض رسالة واحدة في المرة
      }
    }

    // 3. نظام البانر الإعلاني الجديد (بالصورة والزرار المخصص)
    if (promoBannerInfo != null && promoBannerInfo['show'] == true) {
      final int bannerId = promoBannerInfo['banner_id'] ?? 1;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int lastSeenBannerId = prefs.getInt('last_seen_banner_id') ?? 0;

      if (bannerId > lastSeenBannerId) {
        if (!context.mounted) return;
        _showPromoBannerSheet(context, promoBannerInfo, bannerId, prefs);
      }
    }
  } catch (e) {
    debugPrint('Error: $e');
  }
}

// دالة لمقارنة الإصدارات
bool _isNewerVersion(String latest, String current) {
  List<String> lParts = latest.split('.');
  List<String> cParts = current.split('.');
  for (int i = 0; i < lParts.length; i++) {
    int l = int.tryParse(lParts[i]) ?? 0;
    int c = i < cParts.length ? (int.tryParse(cParts[i]) ?? 0) : 0;
    if (l > c) return true;
    if (l < c) return false;
  }
  return false;
}

// 1. تصميم نافذة التحديث (قديم كما هو)
void _showUpdateSheet(
    BuildContext context, Map<dynamic, dynamic> info, String storeLink) {
  final String title = info['title'] ?? 'New Update Available';
  final List features = info['features'] ?? [];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF101923),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: Color(0xFF26364D), width: 1.5),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF26364D),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.system_update_rounded,
                    color: Color(0xFF639DF0), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...features
                .map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("• ",
                              style: TextStyle(
                                  color: Color(0xFF639DF0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              feature.toString(),
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF8B949E),
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF639DF0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final Uri url = Uri.parse(storeLink);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text('Update Now',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Later',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B949E))),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

// 2. تصميم نافذة الإشعار العادي (قديم كما هو)
void _showAnnouncementSheet(BuildContext context, Map<dynamic, dynamic> info,
    int messageId, SharedPreferences prefs) {
  final String title = info['title'] ?? 'Notice';
  final String body = info['body'] ?? '';

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF101923),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: Color(0xFF26364D), width: 1.5),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF26364D),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF8B949E), height: 1.5),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF639DF0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  prefs.setInt('last_seen_message_id', messageId);
                  Navigator.pop(context);
                },
                child: const Text('Got it',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// 3. تصميم البانر الإعلاني الجديد الاحترافي (بالصورة والزرار المخصص)
void _showPromoBannerSheet(BuildContext context, Map<dynamic, dynamic> info,
    int bannerId, SharedPreferences prefs) {
  final String imageUrl = info['image_url'] ?? '';
  final String title = info['title'] ?? 'Special Announcement';
  final String body = info['body'] ?? '';
  final String buttonText = info['button_text'] ?? 'Explore Now';
  final String buttonLink = info['button_link'] ?? '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF101923),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: Color(0xFF26364D), width: 1.5),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF26364D),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // عرض الصورة بشكل احترافي بحواف دائرية
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            if (imageUrl.isNotEmpty) const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF8B949E), height: 1.4),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF639DF0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  prefs.setInt('last_seen_banner_id', bannerId);
                  Navigator.pop(context);
                  if (buttonLink.isNotEmpty) {
                    final Uri url = Uri.parse(buttonLink);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  }
                },
                child: Text(buttonText,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                prefs.setInt('last_seen_banner_id', bannerId);
                Navigator.pop(context);
              },
              child: const Text('Dismiss',
                  style: TextStyle(color: Color(0xFF8B949E), fontSize: 14)),
            ),
          ],
        ),
      );
    },
  );
}
