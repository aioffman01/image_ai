import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:platform_ocr/platform_ocr.dart';
import 'package:exif/exif.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Image AI App',
      themeMode: ThemeMode.light, // Default light mode
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF007BFF),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007BFF),
          primary: const Color(0xFF007BFF),
          secondary: const Color(0xFF28A745),
          background: const Color(0xFFFFFFFF),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.4,
            color: Color(0xFF212121),
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.4,
            color: Color(0xFF212121),
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            height: 1.6,
            color: Color(0xFF212121),
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            height: 1.6,
            color: Color(0xFF757575),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007BFF),
            foregroundColor: const Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF007BFF),
            side: const BorderSide(color: Color(0xFF007BFF), width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      home: const MainResponsiveLayout(),
    );
  }
}

class MainResponsiveLayout extends StatefulWidget {
  const MainResponsiveLayout({super.key});

  @override
  State<MainResponsiveLayout> createState() => _MainResponsiveLayoutState();
}

class _MainResponsiveLayoutState extends State<MainResponsiveLayout> {
  int _selectedIndex = 0;

  // Screens list definition
  final List<Widget> _screens = [
    const ImageListScreen(),
    const ImageUploadScreen(),
    const Menu1Screen(),
    const Menu2Screen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Desktop layout (Width >= 940px)
          if (constraints.maxWidth >= 940) {
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(color: Color(0xFF007BFF)),
                  selectedLabelTextStyle: const TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.bold),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.image),
                      selectedIcon: Icon(Icons.image_outlined),
                      label: Text('메인 화면'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.add_photo_alternate),
                      selectedIcon: Icon(Icons.add_photo_alternate_outlined),
                      label: Text('이미지 등록'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard),
                      selectedIcon: Icon(Icons.dashboard_outlined),
                      label: Text('메뉴 1'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      selectedIcon: Icon(Icons.settings_outlined),
                      label: Text('메뉴 2'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            );
          }
          
          // Mobile layout (Width < 940px)
          return _screens[_selectedIndex];
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 940) {
            return BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF007BFF),
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.image),
                  label: '메인',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_photo_alternate),
                  label: '등록',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: '메뉴 1',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: '메뉴 2',
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// 1. Image List Screen
class ImageListScreen extends StatelessWidget {
  const ImageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('등록된 이미지 리스트', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Spacing Medium (16pt)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8), // Spacing Small (8pt)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000000).withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey[200],
                            width: double.infinity,
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '이미지 제목 $index',
                                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '등록일: 2026-07-06',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Image Registration & Analysis Screen
// 2. Image Registration & Analysis Screen
class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  String? _selectedImagePath;
  bool _isAnalyzing = false;
  String _recognizedText = '인식된 결과 텍스트가 여기에 노출됩니다.';
  String _confidence = '0.0%';
  String _photoDate = '날짜 정보 없음';
  double? _latitude;
  double? _longitude;

  String get _analysisResultJson {
    final Map<String, dynamic> data = {
      'metadata': {
        'dateTime': _photoDate,
        'gps': _latitude != null && _longitude != null
            ? {
                'latitude': double.parse(_latitude!.toStringAsFixed(6)),
                'longitude': double.parse(_longitude!.toStringAsFixed(6)),
              }
            : null,
      },
      'ocr': {
        'engine': Platform.isWindows ? 'Windows Native OCR' : 'Google ML Kit',
        'confidence': _confidence,
        'text': _recognizedText,
      }
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  double _ratioToDouble(dynamic val) {
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is Ratio) {
      return val.toDouble();
    }
    final str = val.toString();
    if (str.contains('/')) {
      final parts = str.split('/');
      final num = double.tryParse(parts[0]) ?? 0.0;
      final den = double.tryParse(parts[1]) ?? 1.0;
      return num / den;
    }
    return double.tryParse(str) ?? 0.0;
  }

  double? _convertDegreesMinutesSeconds(dynamic values, String ref) {
    if (values == null) return null;
    List<dynamic> list;
    if (values is List) {
      list = values;
    } else if (values.runtimeType.toString() == 'IfdRatios') {
      list = (values as dynamic).ratios;
    } else {
      try {
        list = (values as dynamic).toList();
      } catch (e) {
        return null;
      }
    }

    if (list.length < 3) return null;
    
    double degrees = _ratioToDouble(list[0]);
    double minutes = _ratioToDouble(list[1]);
    double seconds = _ratioToDouble(list[2]);

    double decimal = degrees + (minutes / 60.0) + (seconds / 3600.0);
    if (ref == 'S' || ref == 'W') {
      decimal = -decimal;
    }
    return decimal;
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        
        // Extract EXIF metadata
        final bytes = await File(path).readAsBytes();
        final tags = await readExifFromBytes(bytes);
        
        String? date;
        double? lat;
        double? lon;

        if (tags.containsKey('Image DateTime')) {
          date = tags['Image DateTime']?.toString();
        } else if (tags.containsKey('EXIF DateTimeOriginal')) {
          date = tags['EXIF DateTimeOriginal']?.toString();
        }

        if (tags.containsKey('GPS GPSLatitude') && tags.containsKey('GPS GPSLongitude')) {
          final latTag = tags['GPS GPSLatitude']!;
          final latRefTag = tags['GPS GPSLatitudeRef']?.toString() ?? 'N';
          final lonTag = tags['GPS GPSLongitude']!;
          final lonRefTag = tags['GPS GPSLongitudeRef']?.toString() ?? 'E';

          lat = _convertDegreesMinutesSeconds(latTag.values, latRefTag);
          lon = _convertDegreesMinutesSeconds(lonTag.values, lonRefTag);
        }

        setState(() {
          _selectedImagePath = path;
          _photoDate = date ?? '날짜 정보 없음 (총 태그: ${tags.length}개)';
          _latitude = lat;
          _longitude = lon;
          _recognizedText = '인식된 결과 텍스트가 여기에 노출됩니다.';
          _confidence = '0.0%';
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
      setState(() {
        _photoDate = '파일 로딩 에러: $e';
        _latitude = null;
        _longitude = null;
      });
    }
  }

  Future<void> _runOCR() async {
    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지를 먼저 불러와주세요.')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _recognizedText = '분석 진행 중...';
      _confidence = '0.0%';
    });

    // 1. Try local ML Kit OCR first (Android/iOS only)
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final inputImage = InputImage.fromFilePath(_selectedImagePath!);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        
        setState(() {
          _recognizedText = recognizedText.text.isNotEmpty 
              ? recognizedText.text 
              : '인식된 텍스트가 없습니다.';
          _confidence = '99.0% (온디바이스)';
          _isAnalyzing = false;
        });
        await textRecognizer.close();
        return;
      }
    } catch (e) {
      debugPrint("Local ML Kit OCR failed: $e");
    }

    // 2. Try Windows native local OCR (using platform_ocr)
    try {
      if (Platform.isWindows) {
        final ocr = PlatformOcr();
        final ocrResult = await ocr.recognizeText(OcrSource.file(File(_selectedImagePath!)));
        setState(() {
          _recognizedText = ocrResult.text.trim().isNotEmpty ? ocrResult.text : '인식된 텍스트가 없습니다.';
          _confidence = '100% (윈도우 로컬 OCR)';
        });
        return;
      }
    } catch (e) {
      setState(() {
        _recognizedText = '윈도우 로컬 OCR 분석 실패: $e';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Widget _buildMap() {
    if (_latitude == null || _longitude == null) return const SizedBox.shrink();
    
    return Container(
      height: 300,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(_latitude!, _longitude!),
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.local_ocr_app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(_latitude!, _longitude!),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('새 이미지 등록 및 분석', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _selectedImagePath != null
                    ? Image.file(
                        File(_selectedImagePath!),
                        fit: BoxFit.contain,
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('불러온 이미지가 여기에 표시됩니다.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _pickImage,
              icon: const Icon(Icons.image_search),
              label: const Text('이미지 불러오기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: const Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _runOCR,
              icon: _isAnalyzing 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Icon(Icons.analytics_outlined),
              label: Text(_isAnalyzing ? '분석 중...' : '분석 실행 (AI)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF28A745),
                foregroundColor: const Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000000).withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('분석 결과 정보 (JSON)', style: theme.textTheme.titleLarge),
                    const Divider(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE9ECEF)),
                      ),
                      child: SelectableText(
                        _analysisResultJson,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: Color(0xFF212529),
                        ),
                      ),
                    ),
                    _buildMap(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_alt),
              label: const Text('분석 내용 저장'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. Menu 1 Screen
class Menu1Screen extends StatelessWidget {
  const Menu1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('메뉴 1', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text('메뉴 1 화면입니다.', style: theme.textTheme.bodyLarge),
      ),
    );
  }
}

// 4. Menu 2 Screen
class Menu2Screen extends StatelessWidget {
  const Menu2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('메뉴 2', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text('메뉴 2 화면입니다.', style: theme.textTheme.bodyLarge),
      ),
    );
  }
}
