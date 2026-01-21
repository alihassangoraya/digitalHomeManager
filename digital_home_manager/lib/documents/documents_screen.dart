import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'documents_service.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _labelController = TextEditingController();
  bool _loading = false;

  Future<void> _pickAndUpload() async {
    _labelController.clear();
    final labelResult = await showDialog<String>(
      context: context,
      builder: (_) {
        String userLabel = '';
        return AlertDialog(
          title: const Text('Document Label'),
          content: TextField(
            autofocus: true,
            onChanged: (v) => userLabel = v,
            decoration: const InputDecoration(labelText: 'E.g. Invoice, Report, etc.'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(userLabel),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (labelResult == null || labelResult.isEmpty) return;

    setState(() => _loading = true);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null) return;
      final file = File(result.files.single.path!);
      await DocumentsService.uploadFile(file, labelResult);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document uploaded.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _loading ? null : _pickAndUpload,
        tooltip: 'Upload Document',
        child: _loading ? const CircularProgressIndicator() : const Icon(Icons.upload_file),
      ),
      body: StreamBuilder<List<StoredDocument>>(
        stream: DocumentsService.docsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!;
          if (docs.isEmpty) {
            return const Center(child: Text('No documents uploaded yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = docs[i];
              return ListTile(
                tileColor: Colors.teal[50],
                leading: const Icon(Icons.archive, color: Colors.teal),
                title: Text(d.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Uploaded: ${d.uploaded.toLocal().toString().split(" ")[0]}\n${d.filename}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download),
                      tooltip: 'Download/View',
                      onPressed: () async {
                        final uri = Uri.parse(d.url);
                        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open URL')),
                            );
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete',
                      onPressed: () async {
                        await DocumentsService.deleteDoc(d);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
