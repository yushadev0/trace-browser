from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import httpx
import uvicorn

# Trace'in özel AI Servisi
app = FastAPI(title="Trace AI Agent", description="Otonom Araştırma ve Hafıza Merkezi")

# Hedef Model (Ollama içinde yüklü olan modelin adı)
TARGET_MODEL = "gemma3:4b"

# Delphi'den (Trace) gelecek JSON verisinin şeması
class AskRequest(BaseModel):
    prompt: str
    context: str = "" # İleride SQLite'tan (maillerden) gelen hafızayı buraya besleyeceğiz

@app.post("/ask")
async def ask_ai(request: AskRequest):
    print(f"\n📥 [İSTEK GELDİ] Kullanıcı Sorusu: {request.prompt}")
    print(f"🧠 [DÜŞÜNÜYOR] {TARGET_MODEL} modeline iletiliyor, Ollama uyanıyor...")
    
    # Modelin ufkunu açan ve dünyayı tanımasını sağlayan yeni sistem komutu
    system_prompt = (
        "You are a highly intelligent, knowledgeable, and helpful AI assistant that works directly in Trace Browser, and your name is Trace AI."
        "You possess extensive knowledge about the world, geography, culture, coding, and science. "
        "Your primary task is to provide direct, accurate, and highly detailed answers to the user's questions. "
        "You MUST ALWAYS respond in fluent Turkish. Use Markdown formatting to make your answers easy to read."
    )
    
    if request.context:
         system_prompt += f"\n\nGeçmiş Bilgi:\n{request.context}"

    ollama_url = "http://localhost:11434/api/chat"
    
    payload = {
        "model": TARGET_MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": request.prompt}
        ],
        "stream": False,
        # Modelin halüsinasyon görmesini engelleyen kesinlik ayarı
        "options": {
            "temperature": 0.3, 
            "top_p": 0.9
        }
    }

    try:
        async with httpx.AsyncClient(timeout=120.0) as client:
            response = await client.post(ollama_url, json=payload)
            response.raise_for_status()
            
            data = response.json()
            cevap = data.get("message", {}).get("content", "").strip()
            
            print("✅ [CEVAP HAZIR] Trace arayüzüne fırlatılıyor!")
            return {"response": cevap}
            
    except httpx.RequestError as e:
        print(f"❌ [HATA] Ollama'ya ulaşılamadı: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Ollama bağlantı hatası: {str(e)}")

# Sunucuyu Başlat
if __name__ == "__main__":
    print("==================================================")
    print("🚀 Trace AI Agent başlatılıyor... (Port: 62808)")
    print("📡 Arayüzden gelecek komutlar bekleniyor...")
    print("==================================================")
    # Bu script çalıştığında arka planda sessizce bekler.
    uvicorn.run(app, host="127.0.0.1", port=62808, log_level="warning")