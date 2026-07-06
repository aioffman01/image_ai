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

class AppConfig {
  static bool useBackendServer = false;

  static Future<void> load() async {
    try {
      final file = File('DATA/config.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> data = json.decode(content);
        useBackendServer = data['useBackendServer'] ?? false;
      }
    } catch (e) {
      debugPrint("Error loading config: $e");
    }
  }

  static Future<void> save() async {
    try {
      final dataDir = Directory('DATA');
      if (!await dataDir.exists()) {
        await dataDir.create(recursive: true);
      }
      final file = File('DATA/config.json');
      await file.writeAsString(json.encode({
        'useBackendServer': useBackendServer,
      }));
    } catch (e) {
      debugPrint("Error saving config: $e");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
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
class ImageListScreen extends StatefulWidget {
  const ImageListScreen({super.key});

  @override
  State<ImageListScreen> createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> {
  List<Map<String, dynamic>> _savedAnalyses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAnalyses();
  }

  Future<void> _loadSavedAnalyses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dataDir = Directory('DATA');
      if (await dataDir.exists()) {
        final List<Map<String, dynamic>> loadedList = [];
        final List<FileSystemEntity> entities = dataDir.listSync();
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.json')) {
            try {
              final content = await entity.readAsString();
              final Map<String, dynamic> data = json.decode(content);
              data['filePath'] = entity.path;
              loadedList.add(data);
            } catch (e) {
              debugPrint("Error parsing ${entity.path}: $e");
            }
          }
        }
        
        loadedList.sort((a, b) => (b['saveTime'] ?? '').compareTo(a['saveTime'] ?? ''));

        setState(() {
          _savedAnalyses = loadedList;
        });
      } else {
        setState(() {
          _savedAnalyses = [];
        });
      }
    } catch (e) {
      debugPrint("Error loading saved analyses: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAnalysis(Map<String, dynamic> item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('분석 내용 삭제'),
        content: const Text('이 분석 기록을 영구히 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final jsonFile = File(item['filePath']);
        if (await jsonFile.exists()) {
          await jsonFile.delete();
        }
        final imagePath = item['imagePath'];
        if (imagePath != null) {
          final imgFile = File(imagePath);
          if (await imgFile.exists()) {
            await imgFile.delete();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제되었습니다.')),
        );
        _loadSavedAnalyses();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  void _showDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        final double? lat = item['latitude'] != null ? (item['latitude'] as num).toDouble() : null;
        final double? lon = item['longitude'] != null ? (item['longitude'] as num).toDouble() : null;
        
        final Map<String, dynamic> dataJson = {
          'metadata': {
            'dateTime': item['dateTime'] ?? '날짜 정보 없음',
            'gps': lat != null && lon != null
                ? {
                    'latitude': double.parse(lat.toStringAsFixed(6)),
                    'longitude': double.parse(lon.toStringAsFixed(6)),
                  }
                : null,
          },
          'ocr': {
            'confidence': item['confidence'] ?? '0.0%',
            'text': item['recognizedText'] ?? '',
          },
          'ai': {
            'isAiAnalyzed': item['isAiAnalyzed'] ?? false,
            'geminiAnalysis': (() {
              final val = item['geminiAnalysis'];
              if (val is String) {
                try {
                  if (val.trim().startsWith('{') || val.trim().startsWith('[')) {
                    return json.decode(val.trim());
                  }
                } catch (_) {}
              }
              return val ?? '';
            })(),
          }
        };
        final String formattedJson = const JsonEncoder.withIndent('  ').convert(dataJson);

        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('상세 분석 정보', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (item['imagePath'] != null && File(item['imagePath']).existsSync())
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(item['imagePath']), fit: BoxFit.contain),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text('결과 데이터 (JSON):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: SelectableText(
                      formattedJson,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ),
                  if (lat != null && lon != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(lat, lon),
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
                                  point: LatLng(lat, lon),
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
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        bool tempUseServer = AppConfig.useBackendServer;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('설정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('백엔드 서버 사용'),
                    subtitle: const Text('체크 해제 시 100% 로컬 온디바이스 OCR 분석을 실행합니다.'),
                    value: tempUseServer,
                    onChanged: (val) {
                      setDialogState(() {
                        tempUseServer = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    AppConfig.useBackendServer = tempUseServer;
                    await AppConfig.save();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppConfig.useBackendServer
                              ? '설정이 저장되었습니다 (백엔드 서버 사용).'
                              : '설정이 저장되었습니다 (로컬 온디바이스 사용).',
                        ),
                      ),
                    );
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('등록된 이미지 리스트', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSavedAnalyses,
            tooltip: '목록 새로고침',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: '설정',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedAnalyses.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('저장된 분석 기록이 없습니다.', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('이미지 등록 화면에서 분석 후 저장해 보세요.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _savedAnalyses.length,
                    itemBuilder: (context, index) {
                      final item = _savedAnalyses[index];
                      final hasLocalImage = item['imagePath'] != null && File(item['imagePath']).existsSync();
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 2,
                        child: InkWell(
                          onTap: () => _showDetails(item),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      color: Colors.grey[100],
                                      width: double.infinity,
                                      child: hasLocalImage
                                          ? Image.file(
                                              File(item['imagePath']),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          : const Icon(Icons.image, size: 50, color: Colors.grey),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['dateTime'] != '날짜 정보 없음'
                                              ? (item['dateTime'] ?? '분석 기록')
                                              : '날짜 정보 없음',
                                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '저장: ${item['saveTime'] ?? ''}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white70,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                    onPressed: () => _deleteAnalysis(item),
                                    tooltip: '삭제',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
  String _localOcrText = '';
  String _localConfidence = '';
  String _serverOcrText = '';
  String _serverConfidence = '';
  String _photoDate = '';
  double? _latitude;
  double? _longitude;
  bool _hasAnalyzed = false;
  String _geminiAnalysis = '';

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
        'local': {
          'engine': Platform.isWindows ? 'Windows Native OCR' : 'Google ML Kit',
          'confidence': _localConfidence,
          'text': _localOcrText,
        },
        'server': {
          'engine': 'Backend EasyOCR',
          'confidence': _serverConfidence,
          'text': _serverOcrText,
        }
      },
      'ai': {
        'isAiAnalyzed': _geminiAnalysis.isNotEmpty,
        'geminiAnalysis': (() {
          try {
            if (_geminiAnalysis.trim().startsWith('{') || _geminiAnalysis.trim().startsWith('[')) {
              return json.decode(_geminiAnalysis.trim());
            }
          } catch (_) {}
          return _geminiAnalysis;
        })(),
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
          _localOcrText = '';
          _localConfidence = '';
          _serverOcrText = '';
          _serverConfidence = '';
          _geminiAnalysis = '';
          _hasAnalyzed = false;
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

  Future<void> _runAnalysis({required bool isServer}) async {
    if (_selectedImagePath == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('알림'),
          content: const Text('이미지를 먼저 불러와주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _hasAnalyzed = false;
      if (isServer) {
        _geminiAnalysis = 'AI 분석 진행 중...';
        _serverOcrText = 'AI 분석 진행 중...';
      } else {
        _localOcrText = '로컬 분석 진행 중...';
      }
    });

    if (isServer) {
      try {
        final dio = dio_pkg.Dio();
        
        // 1. Run EasyOCR
        final formDataOcr = dio_pkg.FormData.fromMap({
          'file': await dio_pkg.MultipartFile.fromFile(
            _selectedImagePath!,
            filename: _selectedImagePath!.split(Platform.pathSeparator).last,
          ),
        });
        final responseOcr = await dio.post(
          'http://127.0.0.1:8000/api/ocr',
          data: formDataOcr,
        );

        // 2. Run Gemini Vision Analysis
        final formDataAi = dio_pkg.FormData.fromMap({
          'file': await dio_pkg.MultipartFile.fromFile(
            _selectedImagePath!,
            filename: _selectedImagePath!.split(Platform.pathSeparator).last,
          ),
        });
        final responseAi = await dio.post(
          'http://127.0.0.1:8000/api/analyze-image',
          data: formDataAi,
        );

        String ocrText = '인식된 텍스트가 없습니다.';
        String confidence = '0.0%';
        if (responseOcr.statusCode == 200 && responseOcr.data != null) {
          ocrText = responseOcr.data['text'] ?? '인식된 텍스트가 없습니다.';
          confidence = responseOcr.data['confidence'] ?? '0.0%';
        }

        String aiResult = 'Gemini 분석을 가져오지 못했습니다.';
        if (responseAi.statusCode == 200 && responseAi.data != null) {
          aiResult = responseAi.data['analysis'] ?? '분석 결과가 없습니다.';
        }

        setState(() {
          _serverOcrText = ocrText;
          _serverConfidence = confidence;
          _geminiAnalysis = aiResult;
          _hasAnalyzed = true;
        });
      } catch (e) {
        setState(() {
          _serverOcrText = '분석 진행 실패: $e\n(백엔드 서버가 켜져 있는지 확인해 주세요)';
          _geminiAnalysis = 'Gemini 분석 실패';
        });
      } finally {
        setState(() {
          _isAnalyzing = false;
        });
      }
    } else {
      // 1. Try local ML Kit OCR first (Android/iOS only)
      try {
        if (Platform.isAndroid || Platform.isIOS) {
          final inputImage = InputImage.fromFilePath(_selectedImagePath!);
          final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
          final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
          
          setState(() {
            _localOcrText = recognizedText.text.isNotEmpty 
                ? recognizedText.text 
                : '인식된 텍스트가 없습니다.';
            _localConfidence = '99.0% (온디바이스)';
            _isAnalyzing = false;
            _hasAnalyzed = true;
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
            _localOcrText = ocrResult.text.trim().isNotEmpty ? ocrResult.text : '인식된 텍스트가 없습니다.';
            _localConfidence = '100% (윈도우 로컬 OCR)';
            _hasAnalyzed = true;
          });
          return;
        }
      } catch (e) {
        setState(() {
          _localOcrText = '윈도우 로컬 OCR 분석 실패: $e';
        });
      } finally {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _saveAnalysis() async {
    if (!_hasAnalyzed) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('경고'),
          content: const Text('이미지가 분석되지 않았습니다. 로컬 분석 또는 AI 분석을 먼저 실행해 주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장 확인'),
        content: const Text('분석 결과를 저장하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final dataDir = Directory('DATA');
      if (!await dataDir.exists()) {
        await dataDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Copy selected image to DATA folder
      final File originalFile = File(_selectedImagePath!);
      final extension = originalFile.path.split('.').last;
      final copiedImagePath = 'DATA/${timestamp}_image.$extension';
      final File copiedFile = await originalFile.copy(copiedImagePath);
      final String absoluteImagePath = copiedFile.absolute.path;

      // Create JSON data
      final Map<String, dynamic> data = {
        'imagePath': absoluteImagePath,
        'dateTime': _photoDate,
        'latitude': _latitude,
        'longitude': _longitude,
        'localOcrText': _localOcrText,
        'localConfidence': _localConfidence,
        'serverOcrText': _serverOcrText,
        'serverConfidence': _serverConfidence,
        'recognizedText': _localOcrText.isNotEmpty ? _localOcrText : _serverOcrText,
        'confidence': _localConfidence.isNotEmpty ? _localConfidence : _serverConfidence,
        'saveTime': DateTime.now().toString().substring(0, 19),
        'isAiAnalyzed': _geminiAnalysis.isNotEmpty,
        'geminiAnalysis': _geminiAnalysis,
      };

      final File jsonFile = File('DATA/analysis_$timestamp.json');
      await jsonFile.writeAsString(json.encode(data));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 되었습니다.')),
      );

      _resetScreen();
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('에러'),
          content: Text('저장 실패: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  void _resetScreen() {
    setState(() {
      _selectedImagePath = null;
      _isAnalyzing = false;
      _localOcrText = '';
      _localConfidence = '';
      _serverOcrText = '';
      _serverConfidence = '';
      _photoDate = '';
      _latitude = null;
      _longitude = null;
      _hasAnalyzed = false;
      _geminiAnalysis = '';
    });
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

  String _formatGeminiJson(String raw) {
    try {
      final trimmed = raw.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        final decoded = json.decode(trimmed);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
    } catch (_) {}
    return raw;
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
              onPressed: _isAnalyzing ? null : () => _runAnalysis(isServer: false),
              icon: (_isAnalyzing && !_hasAnalyzed && !AppConfig.useBackendServer)
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Icon(Icons.computer),
              label: Text(_isAnalyzing && !AppConfig.useBackendServer ? '로컬 분석 중...' : '로컬 분석'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF28A745),
                foregroundColor: const Color(0xFFFFFFFF),
              ),
            ),
            if (_localOcrText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('로컬 OCR 결과 (신뢰도: $_localConfidence)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Divider(height: 16),
                    SelectableText(
                      _localOcrText,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF212529)),
                    ),
                    if (_photoDate.isNotEmpty) ...[
                      const Divider(height: 16),
                      Text('촬영 일자: $_photoDate', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                    _buildMap(),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: (!AppConfig.useBackendServer || _isAnalyzing)
                  ? null
                  : () => _runAnalysis(isServer: true),
              icon: (_isAnalyzing && !_hasAnalyzed && AppConfig.useBackendServer)
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Icon(Icons.psychology),
              label: Text(_isAnalyzing && AppConfig.useBackendServer ? 'AI 분석 중...' : 'AI 분석'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF8A2BE2),
                foregroundColor: const Color(0xFFFFFFFF),
              ),
            ),
            if (_geminiAnalysis.isNotEmpty || _serverOcrText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_serverOcrText.isNotEmpty) ...[
                      Text('서버 EasyOCR 결과 (신뢰도: $_serverConfidence)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const Divider(height: 16),
                      SelectableText(
                        _serverOcrText,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF212529)),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_geminiAnalysis.isNotEmpty) ...[
                      const Text('Gemini AI 분석 결과', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const Divider(height: 16),
                      SelectableText(
                        _formatGeminiJson(_geminiAnalysis),
                        style: const TextStyle(fontSize: 13, color: Color(0xFF212529), fontFamily: 'monospace'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (_hasAnalyzed) ...[
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
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _saveAnalysis,
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
