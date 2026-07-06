from fastapi import FastAPI, HTTPException, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
import os
import requests
import easyocr
import numpy as np
import cv2

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

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
