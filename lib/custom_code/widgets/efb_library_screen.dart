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

import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

class EfbLibraryScreen extends StatefulWidget {
  const EfbLibraryScreen({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _EfbLibraryScreenState createState() => _EfbLibraryScreenState();
}

class _EfbLibraryScreenState extends State<EfbLibraryScreen> {
  // التصنيفات الأساسية
  final List<String> _categories = [
    'FLIGHT PLAN',
    'CHARTS',
    'MANUALS',
    'OTHERS'
  ];
  String _selectedCategory = 'FLIGHT PLAN';

  // قائمة لحفظ بيانات الملفات
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  // ==== [ 1. تحميل الملفات المحفوظة من الذاكرة ] ====
  Future<void> _loadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? docsJson = prefs.getString('efb_documents');
    if (docsJson != null) {
      setState(() {
        _documents = List<Map<String, dynamic>>.from(json.decode(docsJson));
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  // ==== [ 2. حفظ الملفات في الذاكرة ] ====
  Future<void> _saveDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('efb_documents', json.encode(_documents));
  }

  // ==== [ 3. رفع ملف جديد ونسخه للذاكرة الداخلية ] ====
  Future<void> _uploadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isLoading = true);

        final File originalFile = File(result.files.single.path!);
        final String fileName = result.files.single.name;
        final String fileExtension =
            result.files.single.extension?.toLowerCase() ?? '';
        final int fileSizeInBytes = originalFile.lengthSync();
        final String fileSizeMB =
            (fileSizeInBytes / (1024 * 1024)).toStringAsFixed(2) + ' MB';

        // نسخ الملف للمسار الآمن الخاص بالتطبيق
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String newPath =
            '${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        await originalFile.copy(newPath);

        // إضافة الملف للقائمة
        final newDoc = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': fileName,
          'path': newPath,
          'size': fileSizeMB,
          'category': _selectedCategory, // بيتحفظ في التاب المفتوح حالياً
          'type': fileExtension == 'pdf' ? 'pdf' : 'image',
        };

        setState(() {
          _documents.add(newDoc);
        });
        await _saveDocuments();
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==== [ 4. مسح ملف مع التأكيد ] ====
  Future<void> _deleteDocument(String id, String path) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101923),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        title: const Text("Delete Document?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("This action cannot be undone. Are you sure?",
            style: TextStyle(color: Color(0xFF8B949E))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(color: Color(0xFF8B949E))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.pop(context);
              final file = File(path);
              if (await file.exists()) {
                await file.delete();
              }
              setState(() {
                _documents.removeWhere((doc) => doc['id'] == id);
              });
              await _saveDocuments();
            },
            child: const Text("DELETE",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==== [ 5. فتح الملف في قارئ مخصص ] ====
  void _openDocument(Map<String, dynamic> doc) {
    if (doc['type'] == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EfbPdfViewer(path: doc['path'], name: doc['name']),
        ),
      );
    } else {
      // لعرض الصور
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: const Color(0xFF101923),
              title: Text(doc['name'], style: const TextStyle(fontSize: 14)),
            ),
            body: Center(
                child: InteractiveViewer(child: Image.file(File(doc['path'])))),
          ),
        ),
      );
    }
  }

  // ==========================================
  // UI Builder
  // ==========================================
  @override
  Widget build(BuildContext context) {
    // تصفية الملفات بناءً على التاب الحالي
    final currentDocs = _documents
        .where((doc) => doc['category'] == _selectedCategory)
        .toList();

    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFF0D1219), // خلفية مظلمة جداً لإعطاء الفايب
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeaderTabs(),
                Container(height: 1.5, color: const Color(0xFF26364D)),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF639DF0)))
                      : currentDocs.isEmpty
                          ? _buildEmptyState()
                          : _buildGrid(currentDocs),
                ),
              ],
            ),

            // زرار الرفع العائم (FAB)
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton.extended(
                onPressed: _uploadDocument,
                backgroundColor: const Color(0xFF639DF0),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text("UPLOAD FILE",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==== [ تصميم التابات العلوية ] ====
  Widget _buildHeaderTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: _categories.map((category) {
          bool isActive = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = category),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF639DF0).withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF639DF0)
                        : const Color(0xFF26364D),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF639DF0)
                          : const Color(0xFF8B949E),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==== [ تصميم حالة عدم وجود ملفات ] ====
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded,
              size: 80, color: const Color(0xFF26364D).withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "NO FILES IN $_selectedCategory",
            style: const TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap the upload button below to add documents.",
            style: TextStyle(color: Color(0xFF475569), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ==== [ تصميم شبكة الملفات (Grid) ] ====
  Widget _buildGrid(List<Map<String, dynamic>> docs) {
    return GridView.builder(
      padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 100), // padding من تحت عشان الـ FAB
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350, // الكارت هياخد مساحة مناسبة في الايباد
        mainAxisExtent: 180, // ارتفاع الكارت
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final isPdf = doc['type'] == 'pdf';

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF101923).withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF26364D), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // أيقونة واسم الفايل
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isPdf
                              ? const Color(0xFFEF4444).withOpacity(0.1)
                              : const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isPdf
                              ? Icons.picture_as_pdf_rounded
                              : Icons.image_rounded,
                          color: isPdf
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF3B82F6),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['name'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doc['size'],
                              style: const TextStyle(
                                  color: Color(0xFF8B949E),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // زراير التحكم
                  Row(
                    children: [
                      Expanded(
                        child: _buildCardButton(
                          title: "OPEN",
                          icon: Icons.visibility_rounded,
                          color: const Color(0xFF10B981), // أخضر
                          onTap: () => _openDocument(doc),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildCardButton(
                        title: "", // أيقونة فقط
                        icon: Icons.delete_outline_rounded,
                        color: const Color(0xFFEF4444), // أحمر
                        onTap: () => _deleteDocument(doc['id'], doc['path']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==== [ تصميم زرار الكارت المخصص ] ====
  Widget _buildCardButton(
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            if (title.isNotEmpty) const SizedBox(width: 6),
            if (title.isNotEmpty)
              Text(
                title,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0),
              ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// شاشة عرض الـ PDF الاحترافية المستقلة (مدمج فيها الـ Night Mode)
// =========================================================================
class EfbPdfViewer extends StatefulWidget {
  final String path;
  final String name;

  const EfbPdfViewer({Key? key, required this.path, required this.name})
      : super(key: key);

  @override
  _EfbPdfViewerState createState() => _EfbPdfViewerState();
}

class _EfbPdfViewerState extends State<EfbPdfViewer> {
  late PdfController _pdfController;
  bool _isNightMode = false;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.path),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // مصفوفة الألوان السحرية اللي بتعكس ألوان الـ PDF بالليل
    const ColorFilter nightModeFilter = ColorFilter.matrix([
      -1, 0, 0, 0, 255, // Red
      0, -1, 0, 0, 255, // Green
      0, 0, -1, 0, 255, // Blue
      0, 0, 0, 1, 0, // Alpha
    ]);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1219),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101923),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.name,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          // زرار الـ Night Mode الخرافي
          IconButton(
            icon: Icon(
              _isNightMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: const Color(0xFF639DF0),
            ),
            tooltip: 'Toggle Night Mode',
            onPressed: () {
              setState(() {
                _isNightMode = !_isNightMode;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ColorFiltered(
        // لو الـ Night Mode شغال، بنطبق المصفوفة، لو مطفي بنخليه شفاف (لا تأثير)
        colorFilter: _isNightMode
            ? nightModeFilter
            : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
        child: Container(
          color:
              _isNightMode ? Colors.white : Colors.black, // خلفية ورا الـ PDF
          child: PdfView(
            controller: _pdfController,
            scrollDirection:
                Axis.vertical, // الطيارين بيفضلوا السكرول بالطول للخرائط
            backgroundDecoration:
                const BoxDecoration(color: Colors.transparent),
          ),
        ),
      ),
    );
  }
}
