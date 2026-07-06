from fastapi import FastAPI, HTTPException, File, UploadFile, Header, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
import os
import requests
import easyocr
import numpy as np
import cv2
import io
from PIL import Image
from google import genai
from typing import Optional
from dotenv import load_dotenv

# Load .env file at startup
load_dotenv()

app = FastAPI(title="Local OCR & AI Backend Server")


# Initialize EasyOCR reader for Korean and English
reader = easyocr.Reader(['ko', 'en'])

# Allow requests from Flutter app (all origins for development)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TextPayload(BaseModel):
    text: str

@app.get("/")
def read_root():
    return {"status": "ok", "message": "FastAPI Server is running"}

@app.post("/api/process-text")
async def process_text(payload: TextPayload):
    if not payload.text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty")
    
    # Process text or call LLM (e.g. OpenAI API if configured)
    api_key = os.getenv("OPENAI_API_KEY")
    
    # Simple echo / processing response
    processed_message = f"Received and processed text: {payload.text}"
    
    return {
        "success": True,
        "original_text": payload.text,
        "processed_result": processed_message,
        "llm_called": api_key is not None
    }

@app.post("/api/ocr")
async def run_ocr(file: UploadFile = File(...)):
    try:
        # Read image bytes
        contents = await file.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        # Run EasyOCR
        results = reader.readtext(img)
        
        # Extract text elements
        extracted_text = " ".join([res[1] for res in results])
        
        # Calculate average confidence
        avg_confidence = 0.0
        if results:
            avg_confidence = sum([res[2] for res in results]) / len(results) * 100
        
        return {
            "success": True,
            "text": extracted_text,
            "confidence": f"{avg_confidence:.1f}%",
            "details": [{"text": res[1], "confidence": float(res[2])} for res in results]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OCR processing failed: {str(e)}")

@app.post("/api/analyze-image")
async def analyze_image(
    file: UploadFile = File(...),
    prompt: Optional[str] = Query("이 이미지를 자세히 분석하고 설명해 주세요."),
    x_gemini_api_key: Optional[str] = Header(None, alias="X-Gemini-API-Key"),
    api_key: Optional[str] = Query(None)
):
    try:
        # Determine which API Key to use
        # 1. Query parameter, 2. Header, 3. Environment variable
        current_api_key = api_key or x_gemini_api_key or os.getenv("GEMINI_API_KEY")
        
        if not current_api_key:
            raise HTTPException(
                status_code=400, 
                detail="Gemini API Key is missing. Please provide it via X-Gemini-API-Key header, api_key query param, or GEMINI_API_KEY environment variable."
            )
        
        # Read image bytes
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        
        # Initialize Gemini Client
        client = genai.Client(api_key=current_api_key)
        
        # Call Gemini API
        from google.genai import types
        
        json_prompt = (
            f"{prompt}\n"
            "반드시 이미지를 분석하여 핵심 내용(예: 요약, 주요 정보, 텍스트 요약 등)을 추출하고 "
            "그 분석 결과를 한국어 JSON 객체 형식(키-값 쌍)으로 구성하여 반환해 주세요."
        )

        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=[image, json_prompt],
            config=types.GenerateContentConfig(
                response_mime_type="application/json"
            )
        )
        
        return {
            "success": True,
            "analysis": response.text
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gemini analysis failed: {str(e)}")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
