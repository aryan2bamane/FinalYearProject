# Voice Enabled Map UI

This repository contains a voice-enabled interactive map. The main map application lives under the `MapApp/` folder and is implemented as a Flask web app that uses server-side speech recognition and Leaflet on the client.

## Key features ✅

- **Voice Control (server-side)**: Capture audio via the server's microphone and process with `SpeechRecognition` for commands such as `navigate to <place>`, `zoom in/out`, `move up/down/left/right`, etc.
- **Interactive Map**: UI uses Leaflet to display maps and layers (road, satellite, terrain).
- **Realtime Communication**: `Flask-SocketIO` handles real-time events between the browser and server.
- **Geocoding**: `geopy` (Nominatim) is used to resolve textual locations into coordinates.

## Project layout 🔧

- `MapApp/` — Flask app (run `python app.py` inside this folder to start)
  - `app.py` — server, socket handlers, speech recognition
  - `requirements.txt` — Python dependencies for the Flask app
  - `static/` — JS, CSS, and assets (Leaflet client code in `static/js/main.js`)
  - `templates/index.html` — main page
- `README.md` — this document
- `REFs/`, `Journals/`, `Documentation/` — project resources

## How to run the Map app (quick)

1. Create and activate a virtual environment:

   ```powershell
   cd .\MapApp\
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   ```

2. Install dependencies from `MapApp/requirements.txt`:

   ```powershell
   pip install -r requirements.txt
   ```

3. Run the app:

   ```powershell
   python app.py
   ```

4. Open http://localhost:5000 in your browser and click the microphone toggle to start voice commands.

> Note: This app uses the machine's microphone via Python's `SpeechRecognition` and `PyAudio` — on Windows you may need a pre-built PyAudio wheel or `pipwin install pyaudio`.

## Contributing & Notes 🤝

- Please open issues for bugs or feature requests.
- Follow the usual fork → branch → PR workflow and add descriptive commit messages.

---

*Updated to reflect the Flask-based implementation in `MapApp/`.*
