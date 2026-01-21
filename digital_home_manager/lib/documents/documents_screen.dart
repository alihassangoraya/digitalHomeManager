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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _pickAndUpload,
        tooltip: 'Upload Document',
        icon: _loading ? const CircularProgressIndicator() : const Icon(Icons.upload_file),
        label: const Text('Add Document'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            const SizedBox(height: 18),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.description, color: Colors.teal, size: 32),
                  const SizedBox(width: 10),
                  Text(
                    'Documents & Archive',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: StreamBuilder<List<StoredDocument>>(
                  stream: DocumentsService.docsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!;
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.folder_off, size: 44, color: Colors.teal),
                            SizedBox(height: 12),
                            Text('No documents uploaded yet.\nTap + to add important files.', textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final d = docs[i];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.teal[100]!,
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal[100],
                              foregroundColor: Colors.teal[900],
                              child: const Icon(Icons.file_present, size: 22),
                            ),
                            title: Text(
                              d.label,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                            ),
                            subtitle: Text(
                              'Uploaded: ${d.uploaded.toLocal().toString().split(" ")[0]}\n${d.filename}',
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                            trailing: Wrap(
                              spacing: 2,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.download, color: Colors.teal),
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
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  tooltip: 'Delete',
                                  onPressed: () async {
                                    await DocumentsService.deleteDoc(d);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
