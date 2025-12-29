# PowerShell setup script for Windows
# Run in PowerShell (may need to run as Administrator for some operations)

Write-Host "Creating virtual environment in .venv..."
python -m venv .venv

Write-Host "Activating the virtual environment..."
.\.venv\Scripts\Activate.ps1

Write-Host "Upgrading pip and installing Python dependencies..."
python -m pip install --upgrade pip
pip install -r requirements.txt

Write-Host "If PyAudio installation fails, try installing a prebuilt wheel or use pipwin:"
Write-Host "  python -m pip install pipwin"
Write-Host "  python -m pip install pipwin && pipwin install pyaudio"

Write-Host "Setup complete. Start the app with: python app.py"
