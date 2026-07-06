# 🎨 [프로젝트 이름] 디자인 가이드라인

본 문서는 프로젝트의 일관된 UI/UX 및 브랜드 아이덴티티를 유지하기 위한 디자인 가이드라인입니다.

---

## 1. 브랜드 컬러 시스템 (Color Palette)

앱 전반에 사용되는 메인 컬러와 서브 컬러 정의입니다. (Flutter의 `ThemeData` 선언 시 참고)

| 구문 | 컬러 예시 | Hex 코드 | 사용 처 |
| :--- | :--- | :--- | :--- |
| **Primary** | 🔵 | `#007BFF` | 메인 버튼, 강조 UI, 활성화 상태 |
| **Secondary**| 🟢 | `#28A745` | 성공 메시지, 완료 상태, 서브 포인트 |
| **Background**| ⚪ / ⚫ | `#FFFFFF` / `#121212` | 기본 라이트/다크 모드 배경색 |
| **Text Primary**| ⬛ | `#212121` | 메인 타이틀 및 본문 텍스트 |

---

## 🔤 2. 타이포그래피 (Typography)

폰트는 기본적으로 **[기본 폰트명, 예: Pretendard]**를 사용합니다.

* **Heading 1 (메인 타이틀):** `24pt` / Bold / Line Height 1.4
* **Heading 2 (서브 타이틀):** `18pt` / Semi-Bold / Line Height 1.4
* **Body (기본 본문):** `14pt` / Regular / Line Height 1.6
* **Caption (설명/주석):** `12pt` / Light / Color: `#757575`

---

## 📐 3. 레이아웃 및 여백 규칙 (Layout & Spacing)

컴포넌트 간의 간격과 패딩은 8의 배수(**8pt Grid System**)를 기본 원칙으로 합니다.

* **Small (xs/s):** `4pt` / `8pt` (아이콘 내부 여백, 아주 좁은 간격)
* **Medium (m):** `16pt` (기본 화면의 좌우 Margin, 카드 컴포넌트 내부 패딩)
* **Large (l/xl):** `24pt` / `32pt` (섹션과 섹션 사이의 큰 간격)

---

## 🧱 4. 주요 컴포넌트 사양 (Components)

### 버튼 (Buttons)
* **Primary Button:** 배경색 `#007BFF`, 글자색 `#FFFFFF`, 테두리 둥글기(`BorderRadius.circular(8)`)
* **Outline Button:** 배경 투명, 테두리 `#007BFF` 1px, 글자색 `#007BFF`

### 카드 (Cards)
* 배경색 `#FFFFFF`, 그림자(`BoxShadow`) 처리: 투명도 5%의 Black, Blur 8

---

## 🔗 5. 디자인 에셋 링크 (Design Assets)

* **Figma 원본 파일:** [Figma 링크 넣기](https://figma.com/...)
* **아이콘 에셋 폴더:** `/assets/icons/`
* **로고 및 이미지 에셋 폴더:** `/assets/images/`
