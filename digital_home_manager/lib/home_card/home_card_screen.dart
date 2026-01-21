import 'package:flutter/material.dart';

import 'home_card_service.dart';

class HomeCardScreen extends StatefulWidget {
  const HomeCardScreen({super.key});

  @override
  State<HomeCardScreen> createState() => _HomeCardScreenState();
}

class _HomeCardScreenState extends State<HomeCardScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  final _addressController = TextEditingController();
  final _yearController = TextEditingController();
  final _typeController = TextEditingController();
  final _techController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _yearController.dispose();
    _typeController.dispose();
    _techController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await HomeCardService.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile ?? {};
        _addressController.text = _profile?['address'] ?? '';
        _yearController.text = _profile?['year']?.toString() ?? '';
        _typeController.text = _profile?['type'] ?? '';
        _techController.text = _profile?['technologies'] ?? '';
        _valueController.text = _profile?['value'] ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await HomeCardService.saveProfile({
        'address': _addressController.text.trim(),
        'year': _yearController.text.trim(),
        'type': _typeController.text.trim(),
        'technologies': _techController.text.trim(),
        'value': _valueController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text('Digital Home Card', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Property Address'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              enabled: !_loading,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Year of Construction'),
              keyboardType: TextInputType.number,
              enabled: !_loading,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type of Structure'),
              enabled: !_loading,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _techController,
              decoration: const InputDecoration(labelText: 'Installed Technologies'),
              enabled: !_loading,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(labelText: 'Estimated Property Value'),
              keyboardType: TextInputType.text,
              enabled: !_loading,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _saveProfile,
              child: _loading ? const CircularProgressIndicator() : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
