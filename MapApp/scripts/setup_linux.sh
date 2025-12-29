#!/usr/bin/env bash
set -e

# This script is targeting Debian/Ubuntu-based systems.
# It installs system dependencies required for PyAudio/portaudio and sets up a Python venv.

echo "Updating package lists..."
sudo apt update

echo "Installing system packages: python3-venv, python3-dev, build-essential, portaudio19-dev, libsndfile1"
sudo apt install -y python3-venv python3-dev build-essential portaudio19-dev libsndfile1

echo "Creating virtual environment in .venv..."
python3 -m venv .venv

echo "Activating virtual environment and upgrading pip..."
source .venv/bin/activate
python -m pip install --upgrade pip

echo "Installing Python dependencies from requirements.txt..."
pip install -r requirements.txt

echo "Setup complete. Start the app with:"
echo "  source .venv/bin/activate && python3 app.py"
