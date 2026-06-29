#!/usr/bin/env bash
# Setup script for the ECG_Smoking_Prediction notebooks (macOS / Linux).
#
# Creates a Python 3.11 virtual environment in .venv, installs all the
# required packages, and registers a Jupyter kernel. Run it from THIS folder:
#
#     bash setup.sh
#
# Then start JupyterLab with:
#
#     source .venv/bin/activate
#     jupyter lab

set -euo pipefail
cd "$(dirname "$0")"

# Find a Python 3.11 interpreter (TensorFlow has no wheels for 3.13/3.14).
PYTHON=""
for name in python3.11 python3 python; do
    if command -v "$name" >/dev/null 2>&1; then
        if "$name" --version 2>&1 | grep -q "3.11"; then
            PYTHON="$name"
            break
        fi
    fi
done

if [ -z "$PYTHON" ]; then
    echo "Python 3.11 not found. Install it (e.g. 'brew install python@3.11' or your package manager) and re-run." >&2
    exit 1
fi

echo "Creating virtual environment (.venv) with $PYTHON ..."
"$PYTHON" -m venv .venv

.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python -m ipykernel install --user --name ecg-smoking-hang --display-name "Python 3.11 (ECG_Smoking_Prediction)"

echo ""
echo "Done. To run the notebooks:"
echo "    source .venv/bin/activate"
echo "    jupyter lab"
echo "In each notebook, select the 'Python 3.11 (ECG_Smoking_Prediction)' kernel."
