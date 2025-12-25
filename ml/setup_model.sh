#!/bin/bash

echo "================================================"
echo "ML Model Training Pipeline"
echo "================================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    echo "Please install Python 3.8+ and try again"
    exit 1
fi

echo "[1/4] Installing dependencies..."
pip3 install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install dependencies"
    exit 1
fi
echo "✓ Dependencies installed"
echo ""

echo "[2/4] Generating training datasets..."
python3 generate_dataset.py
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to generate datasets"
    exit 1
fi
echo "✓ Datasets generated"
echo ""

echo "[3/4] Training ML model..."
python3 train_model.py
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to train model"
    exit 1
fi
echo "✓ Model trained"
echo ""

echo "[4/4] Evaluating model performance..."
python3 evaluate_model.py
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to evaluate model"
    exit 1
fi
echo "✓ Model evaluated"
echo ""

echo "================================================"
echo "✓ ML Model Training Complete!"
echo "================================================"
echo ""
echo "Model files saved in: models/trained/"
echo "Datasets saved in: data/"
echo "Evaluation report: models/trained/evaluation_report.txt"
echo ""
echo "Next steps:"
echo "1. Review the evaluation report"
echo "2. Start the FastAPI server: python3 main.py"
echo "3. The trained model will be automatically loaded"
echo ""
