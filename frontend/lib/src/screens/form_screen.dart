import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';

class CreditApplicationFormScreen extends ConsumerStatefulWidget {
  const CreditApplicationFormScreen({super.key});

  @override
  ConsumerState<CreditApplicationFormScreen> createState() =>
      _CreditApplicationFormScreenState();
}

class _CreditApplicationFormScreenState
    extends ConsumerState<CreditApplicationFormScreen> {
  final _loan = TextEditingController(text: '5000');
  final _duration = TextEditingController(text: '12');
  final _income = TextEditingController(text: '3500');
  final _debt = TextEditingController(text: '0.3');
  final _age = TextEditingController(text: '30');
  final _employment = TextEditingController(text: 'Full-time');
  // New controllers for personal info / financial details
  final _fullName = TextEditingController(text: 'Alex Johnson');
  final _dob = TextEditingController(text: '1990-04-12');
  final _ssn = TextEditingController(text: '***-**-1234');
  final _email = TextEditingController(text: 'alex.johnson@example.com');
  final _phone = TextEditingController(text: '+1 555 123 4567');
  final _assets = TextEditingController(text: '12000');
  final _liabilities = TextEditingController(text: '3000');

  int _currentStep = 0;

  bool _isLoading = false;

  @override
  void dispose() {
    _loan.dispose();
    _duration.dispose();
    _income.dispose();
    _debt.dispose();
    _age.dispose();
    _employment.dispose();
    _fullName.dispose();
    _dob.dispose();
    _ssn.dispose();
    _email.dispose();
    _phone.dispose();
    _assets.dispose();
    _liabilities.dispose();
    super.dispose();
  }

  Future<void> _onStepContinue() async {
    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
      return;
    }

    // Final submit - call real ML API
    setState(() => _isLoading = true);

    try {
      final income = double.tryParse(_income.text) ?? 3500.0;
      final loanAmount = double.tryParse(_loan.text) ?? 5000.0;
      final age = int.tryParse(_age.text) ?? 30;
      final assets = double.tryParse(_assets.text) ?? 0.0;
      // final liabilities = double.tryParse(_liabilities.text) ?? 0.0;

      // Convert to Home Credit format for ML API
      final formData = {
        'AMT_INCOME_TOTAL': income * 12, // Annual income
        'AMT_CREDIT': loanAmount,
        'AMT_ANNUITY': loanAmount / 12, // Monthly payment estimate
        'AMT_GOODS_PRICE': loanAmount,
        'DAYS_BIRTH': -(age * 365), // Convert age to negative days
        'DAYS_EMPLOYED': -1825, // ~5 years employed
        'CODE_GENDER': 'M',
        'NAME_EDUCATION_TYPE': 'Higher education',
        'NAME_INCOME_TYPE': _employment.text == 'Full-time' ? 'Working' : 'Commercial associate',
        'NAME_FAMILY_STATUS': 'Married',
        'CNT_CHILDREN': 0,
        'FLAG_OWN_CAR': assets > 5000 ? 'Y' : 'N',
        'FLAG_OWN_REALTY': assets > 20000 ? 'Y' : 'N',
        'EXT_SOURCE_1': 0.5,
        'EXT_SOURCE_2': 0.6,
        'EXT_SOURCE_3': 0.5,
      };

      // Call the real AI service
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.predict(formData);

      // Store the result
      ref.read(latestScoreProvider.notifier).state = result;

      // Add to applications list
      ref.read(applicationsProvider.notifier).add(
        CreditApplication(
          id: 'app-${DateTime.now().millisecondsSinceEpoch}',
          amount: loanAmount,
          date: DateTime.now(),
          status: result.status,
        ),
      );

      if (mounted) {
        context.goNamed('userScore');
      }
    } catch (e) {
      // Fallback to local computation if API fails
      debugPrint('ML API failed, using fallback: $e');
      
      final form = {
        'fullName': _fullName.text,
        'dob': _dob.text,
        'ssn': _ssn.text,
        'email': _email.text,
        'phone': _phone.text,
        'loanAmount': double.tryParse(_loan.text) ?? 0.0,
        'durationMonths': int.tryParse(_duration.text) ?? 12,
        'income': double.tryParse(_income.text) ?? 0.0,
        'assets': double.tryParse(_assets.text) ?? 0.0,
        'liabilities': double.tryParse(_liabilities.text) ?? 0.0,
        'debtRatio': double.tryParse(_debt.text) ?? 0.0,
        'age': int.tryParse(_age.text) ?? 0,
        'employment': _employment.text,
      };
      final result = computeScoreFromForm(form);
      ref.read(latestScoreProvider.notifier).state = result;

      ref.read(applicationsProvider.notifier).add(
        CreditApplication(
          id: 'app-${DateTime.now().millisecondsSinceEpoch}',
          amount: form['loanAmount'] as double,
          date: DateTime.now(),
          status: result.status,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Using offline scoring (backend unavailable)'),
            backgroundColor: Colors.orange,
          ),
        );
        context.goNamed('userScore');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep == 0) return; // nothing to do
    setState(() => _currentStep -= 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of 4 - New Credit Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Stepper(
                  currentStep: _currentStep,
                  onStepCancel: _onStepCancel,
                  onStepContinue: _onStepContinue,
                  controlsBuilder: (context, details) {
                    final isLast = _currentStep == 3;
                    return Row(
                      children: [
                        Flexible(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : details.onStepContinue,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 18,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(isLast ? 'Get AI Score' : 'Next'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (_currentStep > 0 && !_isLoading)
                          Flexible(
                            child: TextButton(
                              onPressed: details.onStepCancel,
                              child: const Text('Back'),
                            ),
                          ),
                      ],
                    );
                  },
                  steps: [
                    Step(
                      title: const Text('Step 1 — Personal'),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0
                          ? StepState.complete
                          : StepState.indexed,
                      content: Column(
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Full legal name',
                            ),
                            controller: _fullName,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Date of birth',
                            ),
                            controller: _dob,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: const InputDecoration(labelText: 'SSN'),
                            controller: _ssn,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                            ),
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Step 2 — Financial'),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1
                          ? StepState.complete
                          : StepState.indexed,
                      content: Column(
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Income',
                            ),
                            controller: _income,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Employment status',
                            ),
                            controller: _employment,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Assets',
                            ),
                            controller: _assets,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Liabilities',
                            ),
                            controller: _liabilities,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Step 3 — Review'),
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2
                          ? StepState.complete
                          : StepState.indexed,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${_fullName.text}'),
                          Text('DOB: ${_dob.text}'),
                          Text('Email: ${_email.text}'),
                          const SizedBox(height: 8),
                          Text('Income: ${_income.text}'),
                          Text('Assets: ${_assets.text}'),
                          Text('Liabilities: ${_liabilities.text}'),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Step 4 — Consent'),
                      isActive: _currentStep >= 3,
                      state: _currentStep == 3
                          ? StepState.editing
                          : StepState.indexed,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Please review and accept the terms to continue.',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(value: true, onChanged: (v) {}),
                              const Expanded(
                                child: Text(
                                  'I agree to the Terms and Conditions',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
