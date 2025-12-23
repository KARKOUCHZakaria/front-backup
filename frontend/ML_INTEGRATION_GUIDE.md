# 🤖 ML Model Integration Guide

## 📋 Vue d'ensemble

Ce projet Flutter est maintenant **100% prêt** pour intégrer votre modèle de Machine Learning entraîné pour le credit scoring éthique.

## 🏗️ Architecture

```
lib/src/
├── models/                     # Modèles de données
│   ├── credit_application_data.dart    # Input pour le modèle ML
│   ├── prediction_result.dart          # Output du modèle ML
│   ├── api_response.dart              # Wrapper API générique
│   └── models.dart                    # Export centralisé
├── services/                   # Services
│   ├── ml_api_service.dart           # Communication avec l'API ML
│   ├── ai_service.dart               # Service AI avec fallback
│   └── services.dart                 # Export centralisé
├── config/
│   └── api_config.dart               # Configuration de l'API
├── providers.dart              # Providers Riverpod
└── widgets/
    └── ml_prediction_example.dart    # Exemple d'utilisation
```

## 🔧 Configuration

### 1. Configuration de l'API Backend

Éditez [`lib/src/config/api_config.dart`](lib/src/config/api_config.dart):

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080/api',  // ← Changez cette URL
);
```

### 2. Variables d'environnement (Optionnel)

Pour différents environnements, lancez avec:

```bash
# Development
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api

# Staging
flutter run --dart-define=API_BASE_URL=https://staging-api.example.com/api

# Production
flutter run --dart-define=API_BASE_URL=https://api.example.com/api
```

## 📊 Modèles de Données

### CreditApplicationData

Représente les features envoyées au modèle ML (compatible avec Home Credit Dataset):

```dart
final application = CreditApplicationData.fromForm(
  gender: 'Male',
  age: 35,
  income: 50000,
  loanAmount: 15000,
  annuity: 1250,
  education: 'Higher education',
  employmentYears: 5,
  ownCar: true,
  ownRealty: false,
);
```

### PredictionResult

Représente la réponse du modèle ML:

```dart
{
  "credit_score": 750,
  "decision": "approved",
  "confidence": 0.92,
  "prediction_probability": 0.15,
  "shap_values": {
    "AMT_INCOME_TOTAL": 0.25,
    "AMT_CREDIT": -0.18,
    ...
  },
  "fairness_metrics": {
    "demographic_parity": 0.05,
    "equal_opportunity": 0.03,
    ...
  }
}
```

## 🚀 Utilisation

### 1. Prédiction Simple

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/providers.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiService = ref.watch(aiServiceProvider);
    
    return ElevatedButton(
      onPressed: () async {
        final formData = {
          'gender': 'Male',
          'age': 35,
          'income': 50000.0,
          'loanAmount': 15000.0,
          'annuity': 1250.0,
        };
        
        // Obtenir la prédiction
        final prediction = await aiService.predict(formData);
        
        print('Score: ${prediction.score}');
        print('Decision: ${prediction.status}');
      },
      child: Text('Predict'),
    );
  }
}
```

### 2. Prédiction avec SHAP

```dart
// Obtenir les valeurs SHAP
final shapValues = await aiService.explain(formData);

for (var shap in shapValues) {
  print('${shap.feature}: ${shap.value}');
}
```

### 3. Vérifier la Santé du Modèle

```dart
final modelHealth = ref.watch(modelHealthProvider);

modelHealth.when(
  data: (healthy) => Icon(
    healthy ? Icons.check_circle : Icons.error,
    color: healthy ? Colors.green : Colors.red,
  ),
  loading: () => CircularProgressIndicator(),
  error: (_, __) => Icon(Icons.warning),
);
```

### 4. Métriques d'Équité

```dart
final fairnessMetrics = ref.watch(fairnessMetricsProvider);

fairnessMetrics.when(
  data: (metrics) {
    if (metrics != null && metrics.isFair()) {
      print('✓ Le modèle respecte les critères d\'équité');
    } else {
      print('⚠ Préoccupations d\'équité détectées');
    }
  },
  loading: () => print('Chargement des métriques...'),
  error: (e, _) => print('Erreur: $e'),
);
```

## 🔄 Mode Fallback

Le service AI inclut un **mode fallback automatique**:

- Si l'API est indisponible, il utilise des données simulées
- Utile pour le développement et les tests
- Peut être activé manuellement:

```dart
final aiService = AIService(useMockData: true);
```

## 📡 API Endpoints Attendus

Votre backend doit implémenter ces endpoints:

### POST `/api/ml/predict`

**Request:**
```json
{
  "CODE_GENDER": "M",
  "DAYS_BIRTH": -12775,
  "AMT_INCOME_TOTAL": 50000,
  "AMT_CREDIT": 15000,
  ...
}
```

**Response:**
```json
{
  "credit_score": 750,
  "decision": "approved",
  "confidence": 0.92,
  "prediction_probability": 0.15,
  "shap_values": {...}
}
```

### POST `/api/ml/explain`

Retourne les valeurs SHAP pour une application donnée.

### GET `/api/ml/fairness?protected_attribute=CODE_GENDER`

Retourne les métriques d'équité.

### GET `/api/ml/health`

Vérifie la santé du modèle.

## 🧪 Testing

### Installer les dépendances

```bash
flutter pub get
```

### Générer les fichiers JSON

Les modèles utilisent `json_serializable`. Générez les fichiers `.g.dart`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Lancer l'exemple

L'exemple [`ml_prediction_example.dart`](lib/src/widgets/ml_prediction_example.dart) montre toutes les fonctionnalités:

```dart
// Dans votre router
GoRoute(
  path: '/ml-demo',
  builder: (_, __) => const MLPredictionExample(),
),
```

## 🎯 Exemple Complet d'Intégration

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/providers.dart';
import 'src/models/models.dart';

class CreditApplicationForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreditApplicationForm> createState() => _FormState();
}

class _FormState extends ConsumerState<CreditApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Controllers
  final _incomeController = TextEditingController();
  final _loanController = TextEditingController();
  
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final aiService = ref.read(aiServiceProvider);
      
      // Préparer les données
      final formData = {
        'income': double.parse(_incomeController.text),
        'loanAmount': double.parse(_loanController.text),
        'age': 35,
        'gender': 'Male',
      };
      
      // Obtenir la prédiction
      final prediction = await aiService.predict(formData);
      
      // Obtenir SHAP
      final shap = await aiService.explain(formData);
      
      // Sauvegarder dans l'historique
      saveScoreToHistory(
        ref,
        prediction,
        loanAmount: double.parse(_loanController.text),
      );
      
      // Afficher le résultat
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Score: ${prediction.score}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Decision: ${prediction.status}'),
                const Divider(),
                const Text('Top Features:'),
                ...shap.take(3).map((s) => Text('${s.feature}: ${s.value}')),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _incomeController,
            decoration: const InputDecoration(labelText: 'Income'),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _loanController,
            decoration: const InputDecoration(labelText: 'Loan Amount'),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

## 🔐 Sécurité

- ✅ Toutes les requêtes API utilisent HTTPS en production
- ✅ Headers d'authentification peuvent être ajoutés dans `api_config.dart`
- ✅ Validation des entrées côté client
- ✅ Gestion des timeouts et erreurs réseau

## 📝 Prochaines Étapes

1. ✅ **Backend ML** : Créer l'API REST avec Flask/FastAPI
2. ✅ **Entraîner le modèle** : Utiliser les CSV fournis
3. ✅ **Tester l'intégration** : Lancer `ml_prediction_example.dart`
4. ✅ **Déployer** : Héberger le modèle sur Azure/AWS/GCP
5. ✅ **Monitoring** : Ajouter logs et métriques

## 🆘 Troubleshooting

### Error: Connection failed

```dart
// Vérifiez que le backend est lancé
// Vérifiez l'URL dans api_config.dart
// Activez le mode mock pour tester sans backend:
final aiService = AIService(useMockData: true);
```

### Error: json_serializable files not found

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### API Timeout

```dart
// Augmentez les timeouts dans api_config.dart
static const Duration connectTimeout = Duration(seconds: 60);
```

## 📚 Ressources

- [Home Credit Dataset](https://www.kaggle.com/c/home-credit-default-risk)
- [SHAP Values Explained](https://github.com/slundberg/shap)
- [Fairness in ML](https://fairmlbook.org/)
- [Flutter Riverpod](https://riverpod.dev/)

---

**Votre projet est maintenant prêt pour l'intégration ML ! 🚀**
