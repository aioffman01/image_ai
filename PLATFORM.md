Flutter(앱) + FastAPI(서버) + 온디바이스 AI 환경을 결합한 프로그램을 구현하려고 해. 
Antigravity 에어전트로서 아래 요구사항과 폴더 구조에 맞춰 초기 환경 세팅을 터미널 명령어를 통해 직접 실행하고 완료해 줘.

[전체 프로젝트 구조]
하나의 워크스페이스 안에 두 개의 메인 폴더를 생성해 줘.
- /frontend : Flutter 앱 프로젝트
- /backend : Python FastAPI 서버 프로젝트

[파트별 세팅 요구사항]
1. 프론트엔드 (/frontend)
- Flutter 프로젝트를 새로 생성해 줘. (패키지명: com.example.local_ocr_app)
- 기기 내에서 원본을 전송하지 않고 텍스트 추출 및 이미지 분석을 수행할 수 있도록 공식 OCR 및 온디바이스 AI 관련 플러그인을 추가해줘.
  * `google_mlkit_text_recognition` (텍스트 인식)
  * `google_mlkit_object_detection` (객체 감지 및 추적)
  * `google_mlkit_image_labeling` (이미지 분류/라벨링)
  * `tflite_flutter` (TensorFlow Lite 모델 실행 엔진)
- 이미지 분석을 위해 디바이스 갤러리나 카메라에서 이미지를 가져올 수 있도록 `image_picker` 패키지를 추가해줘.
- HTTP 통신을 위해 `dio` 또는 `http` 패키지도 함께 추가해 줘.

2. 백엔드 (/backend)
- Python 가상환경(.venv)을 생성하고 활성화해 줘.
- FastAPI, Uvicorn, 그리고 텍스트 수신 및 LLM 호출을 위한 라이브러리(requests, openai 등 필요한 기본 패키지)를 설치해 줘.
- **온디바이스 OCR 및 이미지 분석 환경**: 로컬/온디바이스 환경에서 직접 이미지 분석 및 OCR을 수행할 수 있도록 `easyocr`, `opencv-python-headless`, `pillow` 패키지를 추가로 설치해 줘.
- `requirements.txt` 파일을 생성하고 설치된 패키지를 기록해 줘.
- 간단하게 텍스트를 수신해서 응답을 반환하는 테스트용 `main.py` (FastAPI 기본 보일러플레이트)를 작성해 줘.

[추가된 세팅 명령어 (터미널)]

### 프론트엔드 패키지 추가
```bash
cd frontend
flutter pub add google_mlkit_text_recognition google_mlkit_object_detection google_mlkit_image_labeling tflite_flutter dio image_picker
```

### 백엔드 OCR/이미지 분석 패키지 추가
```bash
cd ../backend
# 가상환경 활성화 상태에서 실행
pip install fastapi uvicorn requests openai easyocr opencv-python-headless pillow
pip freeze > requirements.txt
```

[최종 요청]
- 위의 모든 폴더 생성, Flutter init, Python 가상환경 세팅 및 패키지 설치를 터미널에서 직접 실행해서 완료해 준 뒤, 전체적인 폴더 구조를 요약해서 설명해 줘.
