// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:cached_network_image/cached_network_image.dart';

class SimulatorStationHome extends StatefulWidget {
  const SimulatorStationHome({
    Key? key,
    this.width,
    this.height,
    required this.image1,
    this.action1,
    required this.image2,
    this.action2,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String image1;
  final Future Function()? action1;
  final String image2;
  final Future Function()? action2;

  @override
  _SimulatorStationHomeState createState() => _SimulatorStationHomeState();
}

class _SimulatorStationHomeState extends State<SimulatorStationHome> {
  // دالة تحويل روابط GitHub لروابط Raw رسمية ومباشرة
  String _formattedImageUrl(String url) {
    String formattedUrl = url.trim();
    if (formattedUrl.contains('github.com') &&
        formattedUrl.contains('/blob/')) {
      formattedUrl = formattedUrl
          .replaceAll('github.com', 'raw.githubusercontent.com')
          .replaceAll('/blob/', '/');
    }
    return formattedUrl;
  }

  // ============================================================
  // الألوان الموحدة (EFB Dark Theme)
  // ============================================================
  final Color bgColor = const Color(0xFF0B111A); // تم توحيد لون الخلفية
  final Color borderColor = const Color(0xFF26364D); // لون الحواف الموحد
  final Color blueAccent =
      const Color(0xFF639DF0); // الأزرق الشيك الموحد للخطوط المضيئة

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: bgColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // التحقق مما إذا كانت الشاشة بالعرض (مثل الآيباد)
          final bool isLandscape = constraints.maxWidth > constraints.maxHeight;

          // تغيير نسب التمدد (flex) بناءً على اتجاه الشاشة
          final int imageFlex = isLandscape ? 15 : 8;
          final int spaceFlex = isLandscape ? 1 : 2;
          final double middleGap = isLandscape ? 15.0 : 20.0;

          // نسبة أبعاد الكونتينر (عرض إلى طول) لمنع التشوه والمسافات الفارغة
          // 2.4 للآيباد ليكون بانر عريض شيك، 1.8 للموبايل
          final double bannerRatio = isLandscape ? 2.4 : 1.8;

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // العنوان العلوي (SIMULATOR)
                const SizedBox(height: 10),
                Text(
                  'S I M U L A T O R',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    letterSpacing: 10.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // العنوان الرئيسي (STATION) بتأثير معدني
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFF8C95A0), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Text(
                    'STATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),

                Spacer(flex: spaceFlex), // مسافة مرنة

                // الخط الأزرق المضيء
                _buildGlowingLine(),

                Spacer(flex: spaceFlex), // مسافة مرنة

                // النص الوصفي
                Text(
                  'CONNECT YOUR FAVORITE FLIGHT SIMULATOR\nAND TAKE FULL CONTROL.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    letterSpacing: 2.0,
                    height: 1.8,
                  ),
                ),

                Spacer(flex: spaceFlex), // مسافة مرنة

                // الكونتينر الأول مع نسبة أبعاد ثابتة لمنع الحواف الفارغة
                Expanded(
                  flex: imageFlex,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: bannerRatio,
                      child:
                          _buildImageContainer(widget.image1, widget.action1),
                    ),
                  ),
                ),

                SizedBox(height: middleGap),

                // الكونتينر الثاني مع نسبة أبعاد ثابتة لمنع الحواف الفارغة
                Expanded(
                  flex: imageFlex,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: bannerRatio,
                      child:
                          _buildImageContainer(widget.image2, widget.action2),
                    ),
                  ),
                ),

                Spacer(flex: spaceFlex), // مسافة مرنة

                // النص السفلي (محمي من النزول لسطر تاني)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'C O N T R O L .  C O N N E C T .  F L Y .',
                    maxLines: 1, // إجباره على سطر واحد
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      letterSpacing: 6.0,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // الخط الأزرق المضيء السفلي
                _buildGlowingLine(),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  // ويدجت رسم الخط الأزرق المضيء الموحد
  Widget _buildGlowingLine() {
    return SizedBox(
      width: 280,
      height: 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 1.5,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  blueAccent.withOpacity(0.6), // توحيد اللون
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            height: 5,
            width: 5,
            decoration: BoxDecoration(
              color: blueAccent, // توحيد اللون
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: blueAccent.withOpacity(0.9), // توحيد اللون
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت عرض الصور
  Widget _buildImageContainer(String imageUrl, Future Function()? onTapAction) {
    final cleanUrl = _formattedImageUrl(imageUrl);

    return InkWell(
      onTap: onTapAction,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0B111A), // لون يندمج مع الخلفية
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor, // توحيد الحواف
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: cleanUrl,
            // استخدام fill لضمان تغطية الكونتينر بالكامل بدون فراغات وبدون قص الأطراف
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Container(
              color: const Color(0xFF101923), // خلفية موحدة أثناء التحميل
              child: Center(
                child: CircularProgressIndicator(
                  color: blueAccent, // توحيد اللون
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFF101923), // خلفية موحدة عند الخطأ
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
