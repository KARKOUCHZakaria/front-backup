import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/app_drawer.dart';

class FinancialDetailsFormScreen extends ConsumerStatefulWidget {
  const FinancialDetailsFormScreen({super.key});

  @override
  ConsumerState<FinancialDetailsFormScreen> createState() => _FinancialDetailsFormScreenState();
}

class _FinancialDetailsFormScreenState extends ConsumerState<FinancialDetailsFormScreen> {
  final _employmentController = TextEditingController();
  final _primaryIncomeController = TextEditingController();
  final _additionalIncomeController = TextEditingController();
  final _savingsController = TextEditingController();
  final _investmentsController = TextEditingController();
  final _rentController = TextEditingController();
  final _loanPaymentsController = TextEditingController();
  
  String? _selectedEmployment;

  @override
  void dispose() {
    _employmentController.dispose();
    _primaryIncomeController.dispose();
    _additionalIncomeController.dispose();
    _savingsController.dispose();
    _investmentsController.dispose();
    _rentController.dispose();
    _loanPaymentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg2,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Financial Details', style: TextStyle(color: Colors.white)),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step 2 of 3 : Financials',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              _buildProgressBar(),
              const SizedBox(height: 24),
              Text(
                'Your Financial Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This information helps our AI provide a fair and unbiased assessment.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildFormSections(),
              const SizedBox(height: 24),
              _buildNavigationButtons(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomInfo(),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.brightBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.brightBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.mediumTeal,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Income Section
        Text(
          'Income',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Employment Status',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildDropdown(),
        const SizedBox(height: 16),
        Text(
          'Primary Annual Income',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _primaryIncomeController,
          hintText: '\$ 0.00',
          keyboardType: TextInputType.number,
          dark: true,
        ),
        const SizedBox(height: 16),
        Text(
          'Additional Annual Income ( Optional )',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _additionalIncomeController,
          hintText: '\$ 0.00',
          keyboardType: TextInputType.number,
          dark: true,
        ),
        const SizedBox(height: 28),
        
        // Assets Section
        Text(
          'Assets',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Savings & Checking Account Balance',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _savingsController,
          hintText: '\$ 0.00',
          keyboardType: TextInputType.number,
          dark: true,
        ),
        const SizedBox(height: 16),
        Text(
          'Investments Value ( Optional )',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _investmentsController,
          hintText: '\$ 0.00',
          keyboardType: TextInputType.number,
          dark: true,
        ),
        const SizedBox(height: 28),
        
        // Debts & Liabilities Section
        Text(
          'Debts & Liabilities',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Monthly Rent / Mortgage Payment',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _rentController,
          hintText: '\$ 0.00',
          keyboardType: TextInputType.number,
          dark: true,
        ),
        const SizedBox(height: 16),
        Text(
          'Existing Loan Payments ( Monthly )',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _loanPaymentsController,
          hintText: '\$ 0.00',
          keyboardType: TextInputType.number,
          dark: true,
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.mediumTeal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mediumTeal),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEmployment,
          hint: Text(
            'Select your employment status',
            style: TextStyle(color: AppColors.textMuted),
          ),
          isExpanded: true,
          dropdownColor: AppColors.mediumTeal,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          icon: Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
          items: [
            'Employed Full-Time',
            'Employed Part-Time',
            'Self-Employed',
            'Unemployed',
            'Retired',
            'Student',
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedEmployment = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.textMuted),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Previous',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              context.go('/user/summary');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Next',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkTeal,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, color: AppColors.textMuted, size: 14),
            const SizedBox(width: 8),
            Text(
              'Your data is encrypted and secure.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
