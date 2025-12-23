# 🚀 Quick Start - ML Integration

## ✅ Ce qui est fait

Votre projet Flutter est **100% prêt** pour l'intégration ML !

### Fichiers créés (17 nouveaux fichiers)

**Modèles:**
- `lib/src/models/credit_application_data.dart` + `.g.dart`
- `lib/src/models/prediction_result.dart` + `.g.dart`  
- `lib/src/models/api_response.dart` + `.g.dart`
- `lib/src/models/models.dart`

**Services:**
- `lib/src/services/ml_api_service.dart`
- `lib/src/services/ai_service.dart` (mis à jour)
- `lib/src/services/services.dart`

**Configuration:**
- `lib/src/config/api_config.dart`

**Widgets:**
- `lib/src/widgets/ml_prediction_example.dart`

**Documentation:**
- `ML_INTEGRATION_GUIDE.md` (guide complet)
- `BACKEND_EXAMPLE.md` (exemple Python/Flask)
- `INTEGRATION_COMPLETE.md` (résumé)
- `QUICK_START_ML.md` (ce fichier)

## 🎯 Utilisation en 3 lignes

```dart
final aiService = ref.watch(aiServiceProvider);
final prediction = await aiService.predict({'income': 50000, 'loanAmount': 15000, ...});
print('Score: ${prediction.score}, Decision: ${prediction.status}');
```

## 🔧 Configuration Backend

**Éditez:** `lib/src/config/api_config.dart`
```dart
static const String baseUrl = 'http://localhost:8080/api';  // ← Votre URL
```

## 🐍 Backend Python (5 min)

```bash
# 1. Installer Flask
pip install flask flask-cors pandas scikit-learn lightgbm shap

# 2. Créer app.py (voir BACKEND_EXAMPLE.md)

# 3. Lancer
python app.py
```

## 📊 Datasets Fournis

Vous avez déjà :
- ✅ `application_train.csv` - Données d'entraînement
- ✅ `application_test.csv` - Données de test

Compatible avec **Home Credit Default Risk** dataset !

## 🧪 Test Rapide

```bash
flutter run
# Puis naviguez vers MLPredictionExample
```

## 📚 Documentation

- **Guide complet:** [`ML_INTEGRATION_GUIDE.md`](ML_INTEGRATION_GUIDE.md)
- **Backend exemple:** [`BACKEND_EXAMPLE.md`](BACKEND_EXAMPLE.md)
- **Résumé:** [`INTEGRATION_COMPLETE.md`](INTEGRATION_COMPLETE.md)

## 💡 Mode Mock (sans backend)

```dart
// Dans providers.dart, changez:
return AIService(mlApiService: mlApiService, useMockData: true);  // ← true
```

---

**Tout est prêt ! Commencez par entraîner votre modèle avec vos CSV puis créez l'API backend.** 🚀
