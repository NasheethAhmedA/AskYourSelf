import 'package:askyourself/services/storage_service.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  bool _isLoading = false;
  String? _message; // For showing success/error messages

  Future<void> _exportData() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      await _storageService.exportDatabase();
      setState(() {
        _message = "Database exported successfully!";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = "Error exporting database: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _importData() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      await _storageService.importDatabase();
      setState(() {
        _message = "Database imported successfully!";
        _isLoading = false;
      });
      // Optionally, could trigger a refresh of data elsewhere in the app
    } catch (e) {
      setState(() {
        _message = "Error importing database: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_upload),
                  label: const Text("Export Data"),
                  onPressed: _exportData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_download),
                  label: const Text("Import Data"),
                  onPressed: _importData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _message!.startsWith("Error") ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
