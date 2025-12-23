import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers.dart';

/// Example widget showing how to use the ML API integration
class MLPredictionExample extends ConsumerStatefulWidget {
  const MLPredictionExample({super.key});

  @override
  ConsumerState<MLPredictionExample> createState() =>
      _MLPredictionExampleState();
}

class _MLPredictionExampleState extends ConsumerState<MLPredictionExample> {
  bool _isLoading = false;
  PredictionResult? _prediction;
  String? _error;

  // Form controllers
  final _incomeController = TextEditingController(text: '50000');
  final _loanController = TextEditingController(text: '15000');
  final _ageController = TextEditingController(text: '35');
  
  String _selectedGender = 'Male';
  String _selectedEducation = 'Secondary / secondary special';

  @override
  void dispose() {
    _incomeController.dispose();
    _loanController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitPrediction() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      
      // Prepare form data
      final formData = {
        'gender': _selectedGender,
        'age': int.parse(_ageController.text),
        'income': double.parse(_incomeController.text),
        'loanAmount': double.parse(_loanController.text),
        'education': _selectedEducation,
        'annuity': double.parse(_loanController.text) / 12,
        'employmentYears': 5,
        'children': 0,
        'ownCar': true,
        'ownRealty': false,
      };

      // Get prediction
      final scoreResult = await aiService.predict(formData);
      
      // Get SHAP explanation
      final shapValues = await aiService.explain(formData);
      
      setState(() {
        _prediction = PredictionResult(
          predictionProbability: (900 - scoreResult.score) / 900,
          creditScore: scoreResult.score,
          decision: scoreResult.status,
          confidence: 0.85,
          shapValues: {
            for (var shap in shapValues) shap.feature: shap.value
          },
          timestamp: DateTime.now(),
        );
        _isLoading = false;
      });

      // Save to current prediction provider
      ref.read(currentPredictionProvider.notifier).state = _prediction;
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final modelHealth = ref.watch(modelHealthProvider);
    final fairnessMetrics = ref.watch(fairnessMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Prediction Example'),
        actions: [
          // Model health indicator
          modelHealth.when(
            data: (healthy) => Icon(
              healthy ? Icons.check_circle : Icons.error,
              color: healthy ? Colors.green : Colors.red,
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Icon(Icons.warning, color: Colors.orange),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Model Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Model Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    modelHealth.when(
                      data: (healthy) => Text(
                        healthy ? '✓ Model is healthy' : '✗ Model is unhealthy',
                        style: TextStyle(
                          color: healthy ? Colors.green : Colors.red,
                        ),
                      ),
                      loading: () => const Text('Checking model health...'),
                      error: (error, _) => Text(
                        'Health check failed: $error',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Input Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Application Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Gender
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: ['Male', 'Female']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedGender = value!),
                    ),
                    const SizedBox(height: 12),
                    
                    // Age
                    TextField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    
                    // Income
                    TextField(
                      controller: _incomeController,
                      decoration: const InputDecoration(
                        labelText: 'Annual Income',
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    
                    // Loan Amount
                    TextField(
                      controller: _loanController,
                      decoration: const InputDecoration(
                        labelText: 'Loan Amount',
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    
                    // Education
                    DropdownButtonFormField<String>(
                      value: _selectedEducation,
                      decoration: const InputDecoration(labelText: 'Education'),
                      items: [
                        'Secondary / secondary special',
                        'Higher education',
                        'Incomplete higher',
                        'Lower secondary',
                      ]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedEducation = value!),
                    ),
                    const SizedBox(height: 20),
                    
                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitPrediction,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Get Prediction'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Error Display
            if (_error != null)
              Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Error',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_error!),
                    ],
                  ),
                ),
              ),

            // Prediction Result
            if (_prediction != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prediction Result',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Credit Score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Credit Score:'),
                          Text(
                            '${_prediction!.creditScore}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Decision
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Decision:'),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _prediction!.isApproved
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _prediction!.decision.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Confidence
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Confidence:'),
                          Text(
                            '${(_prediction!.confidence * 100).toStringAsFixed(1)}%',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Risk Level
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Risk Level:'),
                          Text(
                            _prediction!.getRiskLevel().toUpperCase(),
                            style: TextStyle(
                              color: _prediction!.getRiskLevel() == 'low'
                                  ? Colors.green
                                  : _prediction!.getRiskLevel() == 'medium'
                                      ? Colors.orange
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      // SHAP Values
                      if (_prediction!.shapValues != null &&
                          _prediction!.shapValues!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Feature Importance (SHAP):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._prediction!.getTopFeatures().map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: entry.value > 0
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.red.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: FractionallySizedBox(
                                    widthFactor: entry.value.abs().clamp(0, 1),
                                    alignment: entry.value > 0
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: entry.value > 0
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  entry.value.toStringAsFixed(3),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: entry.value > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Fairness Metrics
            fairnessMetrics.when(
              data: (metrics) {
                if (metrics == null) return const SizedBox.shrink();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fairness Metrics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (metrics.fairnessScore != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Fairness Score:'),
                              Text(
                                '${metrics.fairnessScore!.toStringAsFixed(1)}/100',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        if (metrics.demographicParity != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Demographic Parity:'),
                              Text(metrics.demographicParity!.toStringAsFixed(3)),
                            ],
                          ),
                        if (metrics.equalOpportunity != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Equal Opportunity:'),
                              Text(metrics.equalOpportunity!.toStringAsFixed(3)),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              metrics.isFair() ? Icons.check_circle : Icons.warning,
                              color: metrics.isFair() ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              metrics.isFair()
                                  ? 'Meets fairness criteria'
                                  : 'Potential fairness concerns',
                              style: TextStyle(
                                color: metrics.isFair() ? Colors.green : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
