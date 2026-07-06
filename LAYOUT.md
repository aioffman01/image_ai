# 📐 반응형 레이아웃 가이드라인 및 베이스 코드

본 문서에서는 Windows 데스크톱과 모바일 앱 환경을 모두 대응하기 위한 반응형 레이아웃 가이드라인 및 `main.dart` 구성용 Flutter 베이스 코드를 제공합니다.

---

## 1. 반응형 UI 분기 기준 (Responsive Breakpoint)

화면의 가로 크기(Width)에 따라 네비게이션 구조를 동적으로 전환합니다.

* **데스크톱 UI (가로 940px 이상):**
  * 좌측 네비게이션 레일(`NavigationRail`) 적용
  * 넓은 화면을 활용한 다단 레이아웃 설계 가능
* **모바일 UI (가로 940px 미만):**
  * 하단 탭바(`BottomNavigationBar`) 적용
  * 한 손 조작이 용이한 세로 스크롤 중심의 단일 열 레이아웃

---

## 2. 화면 및 메뉴 구성 정의

### 1) 메인 화면 (Main Screen)
* **등록된 이미지 리스트:** GridView 또는 ListView 형태로 이미지 썸네일, 제목, 등록일 표시
* **플로팅 액션 버튼 (FAB):** 이미지 등록 화면으로 이동하는 이미지 등록 버튼 추가
* **서브 메뉴 버튼:** 메뉴 1, 메뉴 2로 바로갈 수 있는 동작 버튼 추가

### 2) 이미지 등록 화면 (Image Registration Screen)
* **이미지 프리뷰 영역:** 불러온 이미지를 화면에 표시하는 영역
* **분석 실행 버튼:** 온디바이스 AI 분석을 구동시키는 버튼
* **분석 결과 표시 영역:** 분석 완료 후 텍스트 및 메타데이터를 보여주는 영역
* **저장 버튼:** 분석된 내용 및 이미지 정보를 로컬/서버에 저장하는 버튼

---

## 3. Flutter 반응형 베이스 코드 (`main.dart` 참고용)

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Image AI App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
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

  // 화면 리스트 정의
  final List<Widget> _screens = [
    const ImageListScreen(),
    const ImageUploadScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 가로 너비가 940px 이상인 경우 데스크톱 레이아웃 (NavigationRail)
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
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            );
          }
          
          // 가로 너비가 940px 미만인 경우 모바일 레이아웃 (BottomNavigationBar)
          return _screens[_selectedIndex];
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          // 940px 미만일 때만 BottomNavigationBar 표시
          if (constraints.maxWidth < 940) {
            return BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.image),
                  label: '메인 화면',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_photo_alternate),
                  label: '이미지 등록',
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

// ------------------------------------
// 1. 메인 화면 (이미지 리스트)
// ------------------------------------
class ImageListScreen extends StatelessWidget {
  const ImageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('등록된 이미지 리스트'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 메뉴 버튼 1, 2
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.dashboard),
                  label: const Text('메뉴 1'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                  label: const Text('메뉴 2'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 이미지 리스트 (그리드 레이아웃 예시)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 6, // 더미 데이터 개수
                itemBuilder: (context, index) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey[300],
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
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '등록일: 2026-07-06',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

// ------------------------------------
// 2. 이미지 등록 및 분석 화면
// ------------------------------------
class ImageUploadScreen extends StatelessWidget {
  const ImageUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 이미지 등록 및 분석'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이미지 표시 영역
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: const Center(
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
            const SizedBox(height: 20),
            // 분석 구동 버튼
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('분석 실행 (AI)'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            const SizedBox(height: 20),
            // 분석 정보 영역
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('분석 결과 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Divider(height: 24),
                    Text('인식된 텍스트: 예시 결과 텍스트가 노출됩니다.'),
                    SizedBox(height: 8),
                    Text('신뢰도: 98.5%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 저장 버튼
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_alt),
              label: const Text('분석 내용 저장'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
```
