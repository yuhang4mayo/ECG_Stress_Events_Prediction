# Setup script for the ECG_Smoking_Prediction notebooks (Windows / PowerShell).
#
# Creates a Python 3.11 virtual environment in .venv, installs all the
# required packages, and registers a Jupyter kernel. Run it from THIS folder:
#
#     powershell -ExecutionPolicy Bypass -File .\setup.ps1
#
# Then start JupyterLab with:
#
#     .\.venv\Scripts\Activate.ps1
#     jupyter lab

$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

# Find a Python 3.11 interpreter (TensorFlow has no wheels for 3.13/3.14).
$python = $null
if (Get-Command py -ErrorAction SilentlyContinue) {
    try { & py -3.11 --version | Out-Null; $python = "py -3.11" } catch {}
}
if (-not $python) {
    foreach ($name in @("python3.11", "python")) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) {
            $ver = & $cmd.Source --version 2>&1
            if ($ver -match "3\.11") { $python = $cmd.Source; break }
        }
    }
}
if (-not $python) {
    Write-Error "Python 3.11 not found. Install it from https://www.python.org/downloads/release/python-3119/ and re-run."
    exit 1
}

Write-Host "Creating virtual environment (.venv) with $python ..."
Invoke-Expression "$python -m venv .venv"

$venvPython = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"
& $venvPython -m pip install --upgrade pip
& $venvPython -m pip install -r requirements.txt
& $venvPython -m ipykernel install --user --name ecg-smoking-hang --display-name "Python 3.11 (ECG_Smoking_Prediction)"

Write-Host ""
Write-Host "Done. To run the notebooks:"
Write-Host "    .\.venv\Scripts\Activate.ps1"
Write-Host "    jupyter lab"
Write-Host "In each notebook, select the 'Python 3.11 (ECG_Smoking_Prediction)' kernel."
