import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_builder.dart';
import '../widgets/app_drawer.dart';
import '../providers.dart';
import '../providers/auth_provider.dart';

/// Document types required for credit application
enum DocumentType {
  paySlip,
  taxDeclaration,
  incomeConsistency,
  loanPayments,
  businessCertificate,
  incomeDeclaration,
}

/// Document upload status
class DocumentStatus {
  final DocumentType type;
  final String title;
  final String description;
  final String fileType;
  final File? file;
  final Uint8List? fileBytes; // For web platform
  final String? fileName; // For web platform
  final bool isOptional;
  final bool isForSelfEmployed;

  DocumentStatus({
    required this.type,
    required this.title,
    required this.description,
    required this.fileType,
    this.file,
    this.fileBytes,
    this.fileName,
    this.isOptional = false,
    this.isForSelfEmployed = false,
  });

  DocumentStatus copyWith({
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) {
    return DocumentStatus(
      type: type,
      title: title,
      description: description,
      fileType: fileType,
      file: file ?? this.file,
      fileBytes: fileBytes ?? this.fileBytes,
      fileName: fileName ?? this.fileName,
      isOptional: isOptional,
      isForSelfEmployed: isForSelfEmployed,
    );
  }

  // Check if file is uploaded (either as File or bytes)
  bool get isUploaded => file != null || fileBytes != null;
}

/// Document Upload Screen - Complete Docs after authentication
class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  bool _isSelfEmployed = false;
  bool _isSubmitting = false;
  int _currentStep = 0;

  // Document statuses
  late List<DocumentStatus> _incomeDocuments;
  late List<DocumentStatus> _financialDocuments;
  late List<DocumentStatus> _loanDocuments;
  late List<DocumentStatus> _businessDocuments;

  @override
  void initState() {
    super.initState();
    _initializeDocuments();
  }

  void _initializeDocuments() {
    // Income & Employment Verification
    _incomeDocuments = [
      DocumentStatus(
        type: DocumentType.paySlip,
        title: 'Recent Pay Slips',
        description: 'Last 3 months pay slips',
        fileType: 'PDF',
      ),
      DocumentStatus(
        type: DocumentType.taxDeclaration,
        title: 'Tax Declaration',
        description: 'Most recent tax declaration',
        fileType: 'PDF',
      ),
    ];

    // Financial Activity
    _financialDocuments = [
      DocumentStatus(
        type: DocumentType.incomeConsistency,
        title: 'Income Consistency',
        description: 'Bank statements showing 3 months income',
        fileType: 'XLSX',
      ),
    ];

    // Loan History Documents
    _loanDocuments = [
      DocumentStatus(
        type: DocumentType.loanPayments,
        title: 'Loan Payments',
        description: 'History of loan payments',
        fileType: 'XLSX',
      ),
    ];

    // Business Documents (Self-employed only)
    _businessDocuments = [
      DocumentStatus(
        type: DocumentType.businessCertificate,
        title: 'Business Registration Certificate',
        description: 'Official business registration',
        fileType: 'PDF',
        isForSelfEmployed: true,
      ),
      DocumentStatus(
        type: DocumentType.incomeDeclaration,
        title: 'Income Declaration',
        description: 'Self-employment income declaration',
        fileType: 'PDF',
        isForSelfEmployed: true,
      ),
    ];
  }

  Future<void> _pickFile(DocumentStatus doc, List<DocumentStatus> list) async {
    try {
      // Determine allowed extensions based on file type
      List<String> allowedExtensions;
      if (doc.fileType == 'PDF') {
        allowedExtensions = ['pdf'];
      } else if (doc.fileType == 'XLSX') {
        allowedExtensions = ['xlsx'];
      } else if (doc.fileType == 'JPG/PNG') {
        allowedExtensions = ['jpg', 'jpeg', 'png'];
      } else {
        allowedExtensions = ['pdf'];
      }

      // Pick file with type validation
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
        withData: kIsWeb, // Load bytes on web
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        final fileName = pickedFile.name;
        final fileExtension = fileName.split('.').last.toLowerCase();

        // Validate file extension
        if (!allowedExtensions.contains(fileExtension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please upload a ${doc.fileType} file only'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Update the document with the selected file
        final index = list.indexOf(doc);
        setState(() {
          if (kIsWeb) {
            // On web, use bytes
            list[index] = doc.copyWith(
              fileBytes: pickedFile.bytes,
              fileName: fileName,
            );
          } else {
            // On mobile, use file path
            if (pickedFile.path != null) {
              list[index] = doc.copyWith(
                file: File(pickedFile.path!),
                fileName: fileName,
              );
            }
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ ${doc.title} uploaded successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isStepComplete(int step) {
    switch (step) {
      case 0:
        return _incomeDocuments.every((d) => d.isUploaded);
      case 1:
        return _financialDocuments.every((d) => d.isUploaded);
      case 2:
        return _loanDocuments.every((d) => d.isUploaded);
      case 3:
        if (!_isSelfEmployed) return true;
        return _businessDocuments.every((d) => d.isUploaded);
      default:
        return false;
    }
  }

  bool _canSubmit() {
    // Check all required documents (CIN auto-approved)
    final incomeComplete = _incomeDocuments.every((d) => d.isUploaded);
    final financialComplete = _financialDocuments.every((d) => d.isUploaded);
    final loanComplete = _loanDocuments.every((d) => d.isUploaded);

    if (_isSelfEmployed) {
      final businessComplete = _businessDocuments.every((d) => d.isUploaded);
      return incomeComplete &&
          financialComplete &&
          loanComplete &&
          businessComplete;
    }

    return incomeComplete && financialComplete && loanComplete;
  }

  Future<void> _submitDocuments() async {
    if (!_canSubmit()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      print('🔵 [Upload] Starting document submission');

      // Get document service
      final documentService = ref.read(documentServiceProvider);

      // Collect all documents (CIN auto-approved, no need to upload)
      final payslip1 = _incomeDocuments[0];
      final payslip2 = _incomeDocuments[0]; // Using same for demo
      final payslip3 = _incomeDocuments[0]; // Using same for demo
      final taxDeclaration = _incomeDocuments[1];
      final bankStatement = _financialDocuments[0];

      // Validate all documents have bytes
      if (payslip1.fileBytes == null ||
          taxDeclaration.fileBytes == null ||
          bankStatement.fileBytes == null) {
        throw Exception('Some documents are missing');
      }

      // Call document service to upload and analyze
      print('🔵 [Upload] Calling backend API');
      final result = await documentService.uploadDocumentsAndAnalyze(
        payslip1Bytes: payslip1.fileBytes!,
        payslip1Name: payslip1.fileName ?? 'payslip1.pdf',
        payslip2Bytes: payslip2.fileBytes!,
        payslip2Name: payslip2.fileName ?? 'payslip2.pdf',
        payslip3Bytes: payslip3.fileBytes!,
        payslip3Name: payslip3.fileName ?? 'payslip3.pdf',
        taxBytes: taxDeclaration.fileBytes!,
        taxName: taxDeclaration.fileName ?? 'tax.pdf',
        bankBytes: bankStatement.fileBytes!,
        bankName: bankStatement.fileName ?? 'bank.pdf',
      );

      setState(() => _isSubmitting = false);

      if (result.success && mounted) {
        print('✅ [Upload] Success! Application ID: ${result.applicationId}');
        print('   Credit Score: ${result.creditScore}');
        print('   Decision: ${result.decision}');

        // Invalidate applications provider to refetch data
        ref.invalidate(userApplicationsProvider);

        // Show success message with details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✓ Application submitted successfully!'),
                SizedBox(height: 4),
                Text('Credit Score: ${result.creditScore}'),
                Text('Decision: ${result.decision}'),
                if (result.documentScores?.averageScore != null)
                  Text(
                    'Document Score: ${result.documentScores!.averageScore!.toStringAsFixed(1)}%',
                  ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );

        // Navigate to dashboard
        context.go('/user/home');
      } else {
        throw Exception(result.message ?? 'Upload failed');
      }
    } catch (e) {
      print('❌ [Upload] Error: $e');
      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Upload failed: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        title: const Text(
          'Financial Documents',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, deviceType, constraints) {
            final padding = ResponsiveValue<double>(
              mobile: 16.0,
              tablet: 32.0,
              desktop: 48.0,
            ).getValue(deviceType);

            return SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildEmploymentTypeSelector(),
                      const SizedBox(height: 32),
                      _buildStepper(deviceType),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Financial Documents',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'To complete your credit application, please upload the following financial documents for verification.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmploymentTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkTeal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.work_outline, color: AppColors.primaryCyan),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Are you self-employed?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: _isSelfEmployed,
            onChanged: (value) {
              setState(() {
                _isSelfEmployed = value;
              });
            },
            activeColor: AppColors.primaryCyan,
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(DeviceType deviceType) {
    final steps = [
      _buildStep(
        index: 0,
        title: 'Income & Employment Verification',
        icon: Icons.receipt_long,
        documents: _incomeDocuments,
      ),
      _buildStep(
        index: 1,
        title: 'Financial Activity',
        icon: Icons.account_balance,
        documents: _financialDocuments,
      ),
      _buildStep(
        index: 2,
        title: 'Loan History Documents',
        icon: Icons.history,
        documents: _loanDocuments,
      ),
      if (_isSelfEmployed)
        _buildStep(
          index: 3,
          title: 'Business Documents',
          icon: Icons.business,
          documents: _businessDocuments,
        ),
    ];

    return Column(children: steps);
  }

  Widget _buildStep({
    required int index,
    required String title,
    required IconData icon,
    required List<DocumentStatus> documents,
  }) {
    final isComplete = _isStepComplete(index);
    final isActive = _currentStep == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isActive ? AppColors.darkTeal : AppColors.darkBg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete
              ? AppColors.primaryCyan
              : isActive
              ? AppColors.primaryCyan.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: isComplete ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isActive,
          onExpansionChanged: (expanded) {
            if (expanded) {
              setState(() => _currentStep = index);
            }
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isComplete
                  ? AppColors.primaryCyan.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isComplete ? Icons.check : icon,
              color: isComplete ? AppColors.primaryCyan : Colors.white70,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            isComplete
                ? 'All documents uploaded'
                : '${documents.where((d) => d.isUploaded).length}/${documents.length} documents',
            style: TextStyle(
              color: isComplete
                  ? AppColors.primaryCyan
                  : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          trailing: Icon(
            isActive ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.white70,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: documents
                    .map((doc) => _buildDocumentItem(doc, documents))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(DocumentStatus doc, List<DocumentStatus> list) {
    final isUploaded = doc.isUploaded;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded
              ? AppColors.primaryCyan.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppColors.primaryCyan.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle : Icons.upload_file,
                  color: isUploaded ? AppColors.primaryCyan : Colors.white54,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            doc.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brightBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            doc.fileType,
                            style: TextStyle(
                              color: AppColors.brightBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc.description,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isUploaded)
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primaryCyan,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'File uploaded',
                        style: TextStyle(
                          color: AppColors.primaryCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Spacer(),
              ElevatedButton(
                onPressed: () => _pickFile(doc, list),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUploaded
                      ? AppColors.primaryCyan.withOpacity(0.2)
                      : AppColors.primaryCyan,
                  foregroundColor: isUploaded
                      ? AppColors.primaryCyan
                      : Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isUploaded ? 'Replace' : 'Upload',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _canSubmit();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkTeal,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(
                canSubmit ? Icons.check_circle : Icons.info_outline,
                color: canSubmit
                    ? AppColors.primaryCyan
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  canSubmit
                      ? 'All required documents uploaded. Ready to submit!'
                      : 'Please upload all required documents to continue.',
                  style: TextStyle(
                    color: canSubmit ? Colors.white : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : (canSubmit ? _submitDocuments : null),
            style: ElevatedButton.styleFrom(
              backgroundColor: canSubmit ? AppColors.primaryCyan : Colors.grey,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey.withOpacity(0.3),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const Text(
                    'Submit Documents',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }
}
