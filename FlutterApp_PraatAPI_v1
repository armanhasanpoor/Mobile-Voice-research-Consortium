import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: AnalysisScreen());
  }
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});
  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String selectedFile = 'track24.wav'; // default file
  Map<String, dynamic>? analysisResult;
  bool isLoading = false;
  String error = '';

  Future<void> analyzeFile() async {
    setState(() {
      isLoading = true;
      error = '';
      analysisResult = null;
    });

    final uri = Uri.parse('http://127.0.0.1:5000/analyze?file=$selectedFile');
    //  final uri = Uri.parse(' http://172.28.169.211:5000/analyze?file=$selectedFile');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          analysisResult = json.decode(response.body);
        });
      } else {
        setState(() {
          error = json.decode(response.body)['error'] ?? 'Unknown error';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to connect: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Praat Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedFile,
              items: const [
                DropdownMenuItem(
                  value: 'track24.wav',
                  child: Text('track24.wav'),
                ),
                // Add more filenames if needed
              ],
              onChanged: (value) => setState(() => selectedFile = value!),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: analyzeFile,
              child: const Text('Analyze'),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (error.isNotEmpty)
              Text('Error: $error', style: const TextStyle(color: Colors.red)),
            if (analysisResult != null) ...[
              for (var key in analysisResult!.keys)
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: key,
                    hintText: '${analysisResult![key]}',
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
