import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';
import '../services/application_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';

class FinancialsStepScreen extends ConsumerStatefulWidget {
  const FinancialsStepScreen({super.key});

  @override
  ConsumerState<FinancialsStepScreen> createState() =>
      _FinancialsStepScreenState();
}

class _FinancialsStepScreenState extends ConsumerState<FinancialsStepScreen> {
  final TextEditingController _incomeCtrl = TextEditingController();
  final TextEditingController _expensesCtrl = TextEditingController();
  final TextEditingController _dependentsCtrl = TextEditingController();
  final TextEditingController _existingLoansCtrl = TextEditingController();

  final ApplicationService _service = ApplicationService();

  bool _loading = false;

  @override
  void dispose() {
    _incomeCtrl.dispose();
    _expensesCtrl.dispose();
    _dependentsCtrl.dispose();
    _existingLoansCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF071213), Color(0xFF163C2F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Step 2 of 4 : Financials',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView(
                    children: [
                      _glassField(
                        child: CustomTextField(
                          label: 'Monthly Income',
                          controller: _incomeCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _glassField(
                        child: CustomTextField(
                          label: 'Monthly Expenses',
                          controller: _expensesCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _glassField(
                        child: CustomTextField(
                          label: 'Number of Dependents',
                          controller: _dependentsCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _glassField(
                        child: CustomTextField(
                          label: 'Existing Loans',
                          controller: _existingLoansCtrl,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withAlpha((0.08 * 255).round()),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: _loading ? 'Working…' : 'Next',
                        onPressed: _loading ? null : _onNext,
                        borderRadius: 40,
                        colors: const [Color(0xFF23F6D9), Color(0xFF1DE6C0)],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onNext() async {
    setState(() => _loading = true);

    final income =
        double.tryParse(_incomeCtrl.text.replaceAll(',', '')) ?? 3000.0;
    final expenses =
        double.tryParse(_expensesCtrl.text.replaceAll(',', '')) ?? 1200.0;
    final dependents = int.tryParse(_dependentsCtrl.text) ?? 0;
    final existingLoans = _existingLoansCtrl.text;

    final debtRatio = income > 0 ? (expenses / income) : 0.3;

    final form = <String, dynamic>{
      'income': income,
      'expenses': expenses,
      'debtRatio': debtRatio,
      'dependents': dependents,
      'existingLoans': existingLoans,
      // include defaults for computing
      'age': 30,
      'loanAmount': 5000,
    };

    // Create a lightweight application record for the local list
    final app = CreditApplication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: form['loanAmount'].toDouble(),
      date: DateTime.now(),
      status: 'Pending',
    );

    // submit and compute a demo score
    try {
      final score = await _service.submitApplicationWithScore(app, form);
      // save to providers
      ref.read(applicationsProvider.notifier).add(app);
      ref.read(latestScoreProvider.notifier).state = score;

      // navigate to the summary screen
      if (mounted) context.push('/user/score-summary');
    } catch (e) {
      // show a small error
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to compute score.')),
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _glassField({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.02 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }
}
