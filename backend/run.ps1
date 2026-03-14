# Run this from the project root: .\run.ps1
# Ensures the virtualenv is used and starts the FastAPI server.

Set-StrictMode -Version Latest

$venvPython = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
if (-not (Test-Path $venvPython)) {
    Write-Error "Virtual environment not found at $venvPython. Create it with python -m venv .venv"
    exit 1
}

& $venvPython -m uvicorn app.main:app --reload --port 3000 --host 127.0.0.1
