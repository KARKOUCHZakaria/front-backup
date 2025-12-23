# 🏗️ Architecture ML Integration

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                               │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                    UI LAYER                             │    │
│  │  • ml_prediction_example.dart (Demo Widget)            │    │
│  │  • Formulaires de saisie                               │    │
│  │  • Affichage des résultats                             │    │
│  │  • Visualisation SHAP                                  │    │
│  └─────────────────┬──────────────────────────────────────┘    │
│                    │                                             │
│  ┌─────────────────▼──────────────────────────────────────┐    │
│  │              RIVERPOD PROVIDERS                         │    │
│  │  • aiServiceProvider                                    │    │
│  │  • mlApiServiceProvider                                │    │
│  │  • modelHealthProvider                                  │    │
│  │  • fairnessMetricsProvider                             │    │
│  │  • currentPredictionProvider                           │    │
│  └─────────────────┬──────────────────────────────────────┘    │
│                    │                                             │
│  ┌─────────────────▼──────────────────────────────────────┐    │
│  │               AI SERVICE                                │    │
│  │  • predict(formData) → ScoreResult                     │    │
│  │  • explain(formData) → SHAP Values                     │    │
│  │  • getFairnessMetrics() → FairnessMetrics              │    │
│  │  • checkModelHealth() → bool                           │    │
│  │  ✓ Fallback automatique vers mock data                 │    │
│  └─────────────────┬──────────────────────────────────────┘    │
│                    │                                             │
│  ┌─────────────────▼──────────────────────────────────────┐    │
│  │            ML API SERVICE (Dio)                         │    │
│  │  • POST /api/ml/predict                                │    │
│  │  • POST /api/ml/explain                                │    │
│  │  • GET  /api/ml/fairness                               │    │
│  │  • GET  /api/ml/health                                 │    │
│  │  • GET  /api/ml/info                                   │    │
│  │  ✓ Error handling & timeouts                           │    │
│  └─────────────────┬──────────────────────────────────────┘    │
└────────────────────┼──────────────────────────────────────────┘
                     │
                     │ HTTP/REST API
                     │
┌────────────────────▼──────────────────────────────────────────┐
│                  BACKEND API (Flask/FastAPI)                   │
│                                                                 │
│  ┌───────────────────────────────────────────────────────┐   │
│  │                  ENDPOINTS                             │   │
│  │  POST /api/ml/predict      → Credit Score Prediction   │   │
│  │  POST /api/ml/explain      → SHAP Values              │   │
│  │  GET  /api/ml/fairness     → Fairness Metrics         │   │
│  │  GET  /api/ml/health       → Model Health Status      │   │
│  │  GET  /api/ml/info         → Model Information        │   │
│  └───────────────────┬───────────────────────────────────┘   │
│                      │                                         │
│  ┌───────────────────▼───────────────────────────────────┐   │
│  │              ML PIPELINE                               │   │
│  │  • Preprocessing (encoding, scaling)                   │   │
│  │  • Feature engineering                                 │   │
│  │  • Missing value handling                              │   │
│  └───────────────────┬───────────────────────────────────┘   │
│                      │                                         │
│  ┌───────────────────▼───────────────────────────────────┐   │
│  │          TRAINED ML MODEL                              │   │
│  │  • LightGBM / XGBoost / RandomForest                  │   │
│  │  • Trained on Home Credit Dataset                      │   │
│  │  • Saved with joblib/pickle                            │   │
│  └───────────────────┬───────────────────────────────────┘   │
│                      │                                         │
│  ┌───────────────────▼───────────────────────────────────┐   │
│  │         EXPLAINABILITY LAYER                           │   │
│  │  • SHAP TreeExplainer                                  │   │
│  │  • Feature importance calculation                      │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │            FAIRNESS VALIDATION                          │  │
│  │  • AIF360 / Fairlearn integration                      │  │
│  │  • Demographic Parity check                            │  │
│  │  • Equal Opportunity validation                         │  │
│  │  • Disparate Impact calculation                         │  │
│  └─────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    DATA STORAGE                                  │
│                                                                  │
│  📁 application_train.csv    (Training data - ~300k rows)       │
│  📁 application_test.csv     (Test data)                        │
│  📁 credit_model.pkl         (Trained model)                    │
│  📁 preprocessor.pkl         (Feature transformer)              │
│  📁 feature_names.json       (Feature metadata)                 │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow

```
1. User Input (Flutter UI)
   ↓
2. Form Validation
   ↓
3. AIService.predict()
   ↓
4. Convert to CreditApplicationData
   ↓
5. MLApiService → HTTP POST /api/ml/predict
   ↓
6. Backend receives request
   ↓
7. Preprocessing pipeline
   ↓
8. Model prediction
   ↓
9. SHAP explanation (if requested)
   ↓
10. Fairness check
   ↓
11. PredictionResult response
   ↓
12. Convert to ScoreResult
   ↓
13. Update UI with results
```

## 📦 Data Models

```dart
// INPUT
CreditApplicationData {
  CODE_GENDER: String
  DAYS_BIRTH: int
  AMT_INCOME_TOTAL: double
  AMT_CREDIT: double
  AMT_ANNUITY: double
  ... (21 features total)
}

// OUTPUT  
PredictionResult {
  credit_score: int (0-900)
  decision: String ('approved'/'rejected')
  confidence: double (0-1)
  prediction_probability: double
  shap_values: Map<String, double>
  fairness_metrics: FairnessMetrics
  risk_level: String ('low'/'medium'/'high')
}

// FAIRNESS
FairnessMetrics {
  demographic_parity: double
  equal_opportunity: double
  disparate_impact: double
  fairness_score: double (0-100)
}
```

## 🔌 API Contract

### Request Example
```json
POST /api/ml/predict
{
  "CODE_GENDER": "M",
  "DAYS_BIRTH": -12775,
  "AMT_INCOME_TOTAL": 50000,
  "AMT_CREDIT": 15000,
  "AMT_ANNUITY": 1250,
  "DAYS_EMPLOYED": -1825,
  ...
}
```

### Response Example
```json
{
  "application_id": "app-1234567890",
  "credit_score": 750,
  "decision": "approved",
  "confidence": 0.92,
  "prediction_probability": 0.15,
  "risk_level": "low",
  "shap_values": {
    "AMT_INCOME_TOTAL": 0.25,
    "AMT_CREDIT": -0.18,
    "DAYS_BIRTH": 0.05
  },
  "fairness_metrics": {
    "demographic_parity": 0.05,
    "equal_opportunity": 0.03,
    "disparate_impact": 0.95,
    "fairness_score": 88.5
  },
  "timestamp": "2024-12-13T10:30:00Z"
}
```

## 🛡️ Error Handling

```
API Call Failed?
    ↓
┌───▼────────────────┐
│ AIService Fallback │
│  • Use Mock Data   │
│  • Log Error       │
│  • Return Result   │
└────────────────────┘
```

## 🔒 Security Layers

1. **Frontend Validation** : Input sanitization
2. **HTTPS** : Encrypted communication (production)
3. **Rate Limiting** : API throttling (backend)
4. **Authentication** : JWT tokens (optional)
5. **CORS** : Restricted origins

## 📊 Monitoring Points

- ✅ **Health Check** : Model availability
- ✅ **Latency** : Response times
- ✅ **Error Rate** : Failed predictions
- ✅ **Fairness** : Bias metrics
- ✅ **Model Drift** : Performance degradation

---

**Architecture complète et production-ready !** 🏗️
