#!/usr/bin/env bash
set -euo pipefail

echo "Setting up waller development environment..."

# Create and activate virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Upgrade pip and install dependencies
pip install --upgrade pip setuptools wheel
pip install -r ../requirements.txt

echo ""
echo "──────────────────────────────────────────────"
echo "  Virtual environment ready!"
echo ""
echo "  To activate in future sessions:"
echo "     source .venv/bin/activate"
echo ""
echo "  To run waller (after we implement main):"
echo "     python -m waller.main"
echo "──────────────────────────────────────────────"
