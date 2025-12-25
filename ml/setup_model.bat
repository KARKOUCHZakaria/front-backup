@echo off
echo ================================================
echo ML Model Training Pipeline
echo ================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ and try again
    pause
    exit /b 1
)

echo [1/4] Installing dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)
echo ✓ Dependencies installed
echo.

echo [2/4] Generating training datasets...
python generate_dataset.py
if errorlevel 1 (
    echo ERROR: Failed to generate datasets
    pause
    exit /b 1
)
echo ✓ Datasets generated
echo.

echo [3/4] Training ML model...
python train_model.py
if errorlevel 1 (
    echo ERROR: Failed to train model
    pause
    exit /b 1
)
echo ✓ Model trained
echo.

echo [4/4] Evaluating model performance...
python evaluate_model.py
if errorlevel 1 (
    echo ERROR: Failed to evaluate model
    pause
    exit /b 1
)
echo ✓ Model evaluated
echo.

echo ================================================
echo ✓ ML Model Training Complete!
echo ================================================
echo.
echo Model files saved in: models/trained/
echo Datasets saved in: data/
echo Evaluation report: models/trained/evaluation_report.txt
echo.
echo Next steps:
echo 1. Review the evaluation report
echo 2. Start the FastAPI server: python main.py
echo 3. The trained model will be automatically loaded
echo.
pause
