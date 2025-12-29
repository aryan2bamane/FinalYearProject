# Voice-Enabled Map (Flask)

This folder contains the Flask-based map application that supports voice-driven map controls using server-side speech recognition and WebSockets.

## Features ✅

- Voice commands to control the map (navigation, zoom, pan, markers, layers)
- Real-time updates via Flask-SocketIO
- Uses Leaflet for interactive map UI
- Geocoding via `geopy` to resolve location names
- Stores a short navigation history in the browser (localStorage)

## Voice commands (examples) 🎙️

- `navigate to <city or place>` — jump to a location
- `zoom in` / `zoom out` — change zoom level
- `move up|down|left|right` — pan the map
- `center on <place>` — center map on a location
- `add a marker at <place>` — place a marker
- `show <layer>` / `hide <layer>` — toggle layers (satellite, road, terrain)

## Quick start 🔧

### Windows

1. Create and activate a virtual environment:

   ```powershell
   cd .\MapApp\
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   ```

2. Install dependencies from the `MapApp/requirements.txt`:

   ```powershell
   pip install -r requirements.txt
   ```

   Note: On Windows, `PyAudio` may need a pre-built wheel (or use `pipwin install pyaudio`) for microphone support.

3. Run the app:

   ```powershell
   python app.py
   ```

4. Open your browser to http://localhost:5000

5. Click the microphone toggle in the UI to start voice recognition. The server uses your system microphone and Google SpeechRecognition by default.

### Linux

1. Create and activate a virtual environment:

   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```

2. Install required system packages (Debian/Ubuntu example) and Python dependencies:

   ```bash
   sudo apt update
   sudo apt install -y python3-dev build-essential portaudio19-dev libsndfile1
   pip install -r requirements.txt
   ```

   - On other distributions, install the equivalent PortAudio development package (e.g., `dnf install portaudio-devel` on Fedora).
   - If `PyAudio` installation fails, try installing `python3-pyaudio` from your package manager or build from source after installing PortAudio dev headers.

3. Run the app:

   ```bash
   python3 app.py
   ```

4. Open your browser to http://localhost:5000 and use the microphone toggle in the UI to start voice recognition.

> Note: On headless servers or CI environments without a local microphone, server-side speech recognition won't work; consider using a client-side Web Speech API or provide audio files for processing.


## Structure 🔍

- `app.py` — Flask app + Flask-SocketIO and server-side speech recognition
- `templates/index.html` — main UI
- `static/js/main.js` — client-side map code (Leaflet + Socket.IO integration)
- `static/css/styles.css` — styles
- `uploads/` — (empty by default) for storing user uploads if used

## Notes & Troubleshooting ⚠️

- Make sure your microphone is enabled and accessible to Python.
- If speech recognition fails due to network or API limits, check console logs for errors.
- The app uses the `geopy.Nominatim` geocoder (OpenStreetMap) — usage is subject to Nominatim's terms.

### Common PyAudio / PortAudio fixes

If you run into problems installing `PyAudio` or capturing audio, use the commands below for your platform and then re-run `pip install -r requirements.txt` inside the virtual environment.

- Debian / Ubuntu (example):

  ```bash
  sudo apt update
  sudo apt install -y python3-dev build-essential portaudio19-dev libsndfile1
  ```

- Fedora (example):

  ```bash
  sudo dnf install -y python3-devel portaudio-devel libsndfile
  ```

- Arch / Manjaro (example):

  ```bash
  sudo pacman -Syu --needed base-devel portaudio libsndfile
  ```

- Windows:

  - Try installing a prebuilt PyAudio wheel for your Python version from https://www.lfd.uci.edu/~gohlke/pythonlibs/#pyaudio or use `pipwin`:

    ```powershell
    python -m pip install pipwin
    python -m pip install pipwin && pipwin install pyaudio
    ```

### Headless / server environments

- If your server doesn't have a microphone (headless VM), server-side live speech recognition won't work. Options:
  - Use client-side Web Speech API (in-browser) to capture audio and send text/commands to the server.
  - Send audio files to the server for batch processing.

### Setup scripts

For convenience, the repository includes simple helper scripts in `MapApp/scripts/`:

- `setup_linux.sh` — Debian/Ubuntu helper that installs system packages, creates a venv, and installs Python dependencies.
- `setup_windows.ps1` — PowerShell helper to create a venv and install Python dependencies (Windows-specific PyAudio notes included).

Run them from inside the `MapApp/` directory (review them before executing):

```bash
# Linux
bash scripts/setup_linux.sh

# Windows (PowerShell)
.\scripts\setup_windows.ps1
```

## Contributing 🤝

Feel free to open issues or send PRs. For code changes, create a branch, add tests, and submit a pull request.

---

*Created and maintained as part of the Voice Enabled Map UI project.*
