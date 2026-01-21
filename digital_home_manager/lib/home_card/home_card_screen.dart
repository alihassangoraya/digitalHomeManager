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
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Heading and greeting/branding
          Row(
            children: [
              const Icon(Icons.home, size: 36, color: Colors.indigo),
              const SizedBox(width: 12),
              Text('My Digital Home', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.blue[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Overview', style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: _dashTile(
                          icon: Icons.event,
                          label: "Upcoming Deadlines",
                          value: _profile?['deadlinesCount']?.toString() ?? "-",
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _dashTile(
                          icon: Icons.archive,
                          label: "Documents",
                          value: _profile?['documentsCount']?.toString() ?? "-",
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _dashTile(
                          icon: Icons.health_and_safety,
                          label: "Home Health",
                          value: _profile?['healthStatus'] ?? "Good",
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _dashTile(
                          icon: Icons.handyman,
                          label: "Recent Services",
                          value: _profile?['servicesCount']?.toString() ?? "-",
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("My Property", style: Theme.of(context).textTheme.titleMedium),
                  const Divider(),
                  _infoRow("Address", _profile?['address'] ?? "-"),
                  _infoRow("Year Built", _profile?['year'] ?? "-"),
                  _infoRow("Type", _profile?['type'] ?? "-"),
                  _infoRow("Technologies", _profile?['technologies'] ?? "-"),
                  _infoRow("Estimated Value", _profile?['value'] ?? "-"),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit, size: 17),
                      label: const Text('Edit'),
                      onPressed: _loading ? null : () => _showEditDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashTile({required IconData icon, required String label, required String value, Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: color?.withOpacity(0.10) ?? Colors.indigo[50],
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 30, color: color ?? Colors.indigo),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(value, style: TextStyle(color: color ?? Colors.indigo, fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          SizedBox(width: 105, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value.isNotEmpty ? value : "-")),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Edit Property", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Property Address'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Year of Construction'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(labelText: 'Type of Structure'),
                ),
                TextFormField(
                  controller: _techController,
                  decoration: const InputDecoration(labelText: 'Installed Technologies'),
                ),
                TextFormField(
                  controller: _valueController,
                  decoration: const InputDecoration(labelText: 'Estimated Property Value'),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : () async {
                      await _saveProfile();
                      if (mounted) Navigator.of(ctx).pop();
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
