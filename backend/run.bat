@echo off
REM Run this from the project root: run.bat
REM Ensures the virtualenv is used and starts the FastAPI server.

set VENV_PY=%~dp0\.venv\Scripts\python.exe
if not exist "%VENV_PY%" (
  echo Virtual environment not found at %VENV_PY%
  echo Create it with: python -m venv .venv
  exit /b 1
)

"%VENV_PY%" -m uvicorn app.main:app --reload --port 3000 --host 127.0.0.1
