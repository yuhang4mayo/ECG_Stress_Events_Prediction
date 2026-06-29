# ECG_Smoking_Prediction

This repository holds a portion of my smoking detection and prediction project,
which studies whether wearable sensors can predict smoking events before they
happen. Participants wear devices that record ECG, PPG, EDA, and accelerometer
signals as they go about daily life, and the pipeline cleans those signals,
derives heart-rate-variability and stress features, and trains models to
recognize the patterns leading up to a smoking event. The notebooks here are
three standalone pieces of that broader effort, each focused on a different part
of the ECG-based analysis.

Three Jupyter notebooks for ECG/HRV stress-feature extraction and a BiLSTM
model, with synthetic data included under `R21_data/`.

All three run in **one Python 3.11 environment**. Python 3.11 is required.

## Project structure

```
ECG_Smoking_Prediction/
├── README.md
├── requirements.txt
├── notebooks/        # the three Jupyter notebooks
├── R21_data/         # synthetic input data
└── outputs/          # generated plots and model summaries
```

## Notebooks

### `features_ecg_neuro_si.ipynb` — HRV and stress-index feature extraction
Extracts heart-rate-variability (HRV) and a Baevsky stress index directly from a
raw ECG signal using NeuroKit2.

- Loads a participant's combined ECG pickle (and, for UMN participants, a Kubios
  stress-index export) from `R21_data/synthetic_data_neuro/`.
- Slides a fixed-length window (60s, 50s step) across continuous ECG segments.
- Computes per-window NeuroKit2 HRV features plus a Baevsky stress index
  (`SI = AMo / (2 * Mo * MxDMn)`).
- Runs data-quality diagnostics, saves the feature table, and validates the
  derived stress index / mean-NN against the Kubios reference for UMN
  participants.

### `ml_data_generation_pipeline.ipynb` — per-participant feature tables
Turns raw Kubios CSVs and interpolated signals into the labeled ML training
table.

- Parses Kubios 60s/10s CSV exports, keeping a mapped subset of HRV columns.
- Labels each Kubios row as smoking vs. non-smoking using saved pre-15-minute
  window timestamp lists, then combines per-participant pickles into one dataset
  (`h10_features_everyone_pre15_clean.pkl`) for the BiLSTM notebook.
- Set `participant_id` in the final cell to process a participant end-to-end.

### `h10_pre15_bilstm_precision.ipynb` — BiLSTM model (TensorFlow)
Trains and evaluates a bidirectional LSTM that predicts smoking from features in
the 15 minutes before an event.

- Loads the combined feature table and reshapes flat rows into fixed-length
  (17-step) windowed sequences grouped by event.
- Builds a compact two-layer BiLSTM binary classifier.
- Runs leave-one-participant-out evaluation: trains a base model on everyone
  else (StratifiedGroupKFold), briefly fine-tunes on a slice of the held-out
  participant, and scores the rest.
- Writes per-participant and aggregate accuracy summaries to
  `R21_data/ml_models/bilstm_precision_pre15_clean/`.

## Setup

Run the setup script from this folder. It creates a `.venv` virtual
environment, installs the pinned packages from `requirements.txt`, and
registers a Jupyter kernel named **Python 3.11 (ECG_Smoking_Prediction)**.

**Expected setup and execution time:**

- **Environment setup:** Creating the virtual environment and installing
  dependencies takes approximately 10 -15 minutes depending on the machine.
- **Execution:** Once the environment is activated, the scripts take roughly
  2–3 minutes to run to completion.

**Windows (PowerShell):**

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
.\.venv\Scripts\Activate.ps1
jupyter lab
```

**macOS / Linux:**

```bash
bash setup.sh
source .venv/bin/activate
jupyter lab
```

If you prefer a manual install instead of the script:

```bash
python3.11 -m venv .venv
# activate it (see commands above), then:
pip install -r requirements.txt
```

## Running the notebooks

1. Start JupyterLab and open a notebook from `notebooks/` (it loads data with
   paths relative to `../R21_data/`, so keep the notebooks inside `notebooks/`).
2. Select the **Python 3.11 (ECG_Smoking_Prediction)** kernel.
3. Run all cells. Generated plots and model summaries are written to `outputs/`.


