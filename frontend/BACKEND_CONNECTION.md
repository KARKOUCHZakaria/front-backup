# Guide de Connexion Frontend-Backend-IA

## Configuration Réseau

### Pour l'émulateur Android
- Backend Java: `http://10.0.2.2:8080`
- Service ML Python: `http://10.0.2.2:8000`

### Pour un appareil physique
Modifiez `frontend/lib/src/config/api_config.dart`:
```dart
static const String backendUrl = 'http://VOTRE_IP_LOCAL:8080';
static const String mlUrl = 'http://VOTRE_IP_LOCAL:8000';
```
Exemple: `192.168.1.100`

## Démarrage des Services

### 1. Backend Java (Spring Boot)
```bash
cd services/backend
./mvnw spring-boot:run
```
Le backend sera accessible sur `http://localhost:8080`

**Endpoints disponibles:**
- `POST /auth/register` - Inscription
- `POST /auth/login` - Connexion
- `POST /auth/verify-cin` - Vérification CIN
- `POST /documents/upload` - Upload de documents
- `GET /documents/user/{userId}` - Documents d'un utilisateur

### 2. Service ML (Python FastAPI)
```bash
cd services/ml
pip install -r requirements.txt
python main.py
```
Le service ML sera accessible sur `http://localhost:8000`

**Endpoints disponibles:**
- `POST /predict` - Prédiction de crédit
- `POST /score` - Score complet avec SHAP
- `POST /explain` - Explications SHAP détaillées
- `GET /health` - État du modèle
- `GET /info` - Informations du modèle

### 3. Frontend Flutter
```bash
cd frontend
flutter pub get
flutter run
```

## Test de la Connexion

### 1. Vérifier que les services sont actifs
**Backend:**
```bash
curl http://localhost:8080/actuator/health
```

**Service ML:**
```bash
curl http://localhost:8000/health
```

### 2. Test d'inscription depuis le frontend
L'application utilisera automatiquement les bons endpoints configurés dans `api_config.dart`

### 3. Test de prédiction ML
Une fois connecté, le formulaire de crédit enverra les données au service ML Python

## Dépendances Requises

### Backend Java
- PostgreSQL (port 5432)
- MinIO (port 9000) - pour le stockage des documents
- Java 17+
- Maven

### Service ML
- Python 3.8+
- Packages: fastapi, uvicorn, scikit-learn, shap, etc.

### Frontend
- Flutter SDK
- Dart SDK
- Packages: dio, flutter_riverpod, go_router

## Structure des Requêtes

### Exemple: Login
```json
POST http://10.0.2.2:8080/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### Exemple: Prédiction ML
```json
POST http://10.0.2.2:8000/predict
Content-Type: application/json

{
  "age": 35,
  "income": 50000,
  "loan_amount": 200000,
  ...
}
```

## Résolution des Problèmes

### "Cannot connect to server"
- Vérifiez que le backend et le service ML sont lancés
- Pour Android emulator: utilisez `10.0.2.2` au lieu de `localhost`
- Pour device physique: vérifiez que votre téléphone et PC sont sur le même réseau

### "Connection timeout"
- Augmentez le timeout dans `api_config.dart`
- Vérifiez votre pare-feu

### "403 Forbidden" 
- Le token JWT a peut-être expiré
- Reconnectez-vous

## Services Utilisés

### AuthService (Mock)
Service d'authentification avec données locales pour le développement

### ApiAuthService (Real)
Service d'authentification connecté au backend Java

### MLApiService
Service connecté au backend ML Python pour les prédictions

### AIService
Service orchestrateur qui utilise MLApiService avec fallback sur données mock
