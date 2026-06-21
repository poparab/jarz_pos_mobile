import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pos/presentation/widgets/customer_search_widget.dart'
    show territoriesProvider;
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
  String? _source;
  String? _territory;
  bool _busy = false;

  @override
  void dispose() {
    _leadName.dispose();
    _companyName.dispose();
    _mobile.dispose();
    _email.dispose();
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
            source: _source,
            territory: _territory,
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
            _buildSourceDropdown(),
            const SizedBox(height: 12),
            _buildTerritoryDropdown(),
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

  /// Lead Source dropdown sourced from `get_lead_sources`. Source is optional.
  Widget _buildSourceDropdown() {
    final sourcesAsync = ref.watch(b2bLeadSourcesProvider);
    return sourcesAsync.when(
      data: (sources) => DropdownButtonFormField<String>(
        initialValue: _source,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Source',
          prefixIcon: Icon(Icons.input),
        ),
        items: sources
            .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
            .toList(),
        onChanged: (value) => setState(() => _source = value),
      ),
      loading: () => const _LoadingField(
        label: 'Source',
        icon: Icons.input,
      ),
      error: (_, _) => const _LoadingField(
        label: 'Source (unavailable)',
        icon: Icons.input,
        showSpinner: false,
      ),
    );
  }

  /// Territory dropdown sourced from the shared [territoriesProvider]. Optional
  /// on lead-add (matching prior free-text behaviour).
  Widget _buildTerritoryDropdown() {
    final territoriesAsync = ref.watch(territoriesProvider(null));
    return territoriesAsync.when(
      data: (territories) => DropdownButtonFormField<String>(
        initialValue: _territory,
        isExpanded: true,
        menuMaxHeight: 320,
        decoration: const InputDecoration(
          labelText: 'Territory',
          prefixIcon: Icon(Icons.location_on_outlined),
        ),
        items: territories.map<DropdownMenuItem<String>>((territory) {
          final name = territory['name']?.toString() ?? '';
          final label = (territory['territory_name_ar'] ??
                  territory['territory_name'] ??
                  name)
              .toString();
          return DropdownMenuItem<String>(
            value: name,
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (value) => setState(() => _territory = value),
      ),
      loading: () => const _LoadingField(
        label: 'Territory',
        icon: Icons.location_on_outlined,
      ),
      error: (_, _) => const _LoadingField(
        label: 'Territory (unavailable)',
        icon: Icons.location_on_outlined,
        showSpinner: false,
      ),
    );
  }
}

/// Disabled placeholder shown while a dropdown's options load (or fail).
class _LoadingField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool showSpinner;
  const _LoadingField({
    required this.label,
    required this.icon,
    this.showSpinner = true,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      child: showSpinner
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const SizedBox(height: 18),
    );
  }
}
