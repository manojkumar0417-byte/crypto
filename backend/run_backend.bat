@echo off
echo ========================================================
echo   Starting CryptoGecko Python FastAPI Backend Service
echo ========================================================
cd /d "%~dp0"
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
pause
