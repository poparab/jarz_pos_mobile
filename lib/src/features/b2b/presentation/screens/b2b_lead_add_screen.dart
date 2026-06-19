import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/b2b_repository.dart';
import '../../state/b2b_pipeline_notifier.dart';

/// Quick-add a B2B Lead (create_lead). On success refreshes the pipeline and
/// pops back.
class B2bLeadAddScreen extends ConsumerStatefulWidget {
  const B2bLeadAddScreen({super.key});

  @override
  ConsumerState<B2bLeadAddScreen> createState() => _B2bLeadAddScreenState();
}

class _B2bLeadAddScreenState extends ConsumerState<B2bLeadAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _leadName = TextEditingController();
  final _companyName = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _source = TextEditingController();
  final _territory = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _leadName.dispose();
    _companyName.dispose();
    _mobile.dispose();
    _email.dispose();
    _source.dispose();
    _territory.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(b2bRepositoryProvider).createLead(
            leadName: _leadName.text.trim(),
            companyName: _companyName.text.trim(),
            mobileNo: _mobile.text.trim(),
            emailId: _email.text.trim(),
            source: _source.text.trim(),
            territory: _territory.text.trim(),
          );
      await ref.read(b2bPipelineProvider.notifier).refresh();
      messenger.showSnackBar(const SnackBar(content: Text('Lead created')));
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to create lead: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New lead')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _leadName,
              decoration: const InputDecoration(
                labelText: 'Lead / contact name *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _companyName,
              decoration: const InputDecoration(
                labelText: 'Company name',
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mobile,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _source,
              decoration: const InputDecoration(
                labelText: 'Source',
                prefixIcon: Icon(Icons.input),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _territory,
              decoration: const InputDecoration(
                labelText: 'Territory',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _busy ? null : _submit,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Create lead'),
            ),
          ],
        ),
      ),
    );
  }
}
