// Recording Diagnostic Screen
// This screen will help diagnose the Agora recording issue by logging all API responses

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sep/services/agora/agora_recording_service.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';

class RecordingDiagnosticScreen extends StatefulWidget {
  const RecordingDiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<RecordingDiagnosticScreen> createState() => _RecordingDiagnosticScreenState();
}

class _RecordingDiagnosticScreenState extends State<RecordingDiagnosticScreen> {
  final TextEditingController _channelController = TextEditingController(text: 'test-diagnostic');
  final TextEditingController _uidController = TextEditingController(text: '123456');
  
  final List<Map<String, dynamic>> _logs = [];
  String? _resourceId;
  String? _sid;
  String? _fileUrl;
  bool _isAcquiring = false;
  bool _isStarting = false;
  bool _isStopping = false;

  void _addLog(String action, Map<String, dynamic> data) {
    setState(() {
      _logs.insert(0, {
        'time': DateTime.now().toIso8601String(),
        'action': action,
        'data': data,
      });
      // Keep only last 50 logs
      if (_logs.length > 50) {
        _logs.removeRange(50, _logs.length);
      }
    });
    AppUtils.log('DIAGNOSTIC: $action - ${jsonEncode(data)}');
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
      _resourceId = null;
      _sid = null;
      _fileUrl = null;
    });
  }

  Future<void> _testAcquire() async {
    final channel = _channelController.text.trim();
    final uid = _uidController.text.trim();
    
    if (channel.isEmpty || uid.isEmpty) {
      _addLog('ERROR', {'message': 'Channel and UID are required'});
      return;
    }

    setState(() => _isAcquiring = true);
    
    try {
      _addLog('ACQUIRE:REQUEST', {
        'channelName': channel,
        'uid': uid,
        'endpoint': '/api/agora/recording/acquire',
      });

      final result = await AgoraRecordingService.acquire(
        channelName: channel,
        uid: uid,
      );

      _addLog('ACQUIRE:RESPONSE', {
        'success': result.success,
        'resourceId': result.resourceId,
        'message': result.message,
        'errorMessage': result.errorMessage,
      });

      if (result.success && result.resourceId != null) {
        setState(() => _resourceId = result.resourceId);
        _addLog('ACQUIRE:SUCCESS', {
          'resourceId': result.resourceId,
          'canStartRecording': true,
        });
      } else {
        _addLog('ACQUIRE:FAILED', {
          'reason': result.errorMessage ?? 'Unknown error',
        });
      }
    } catch (e, stackTrace) {
      _addLog('ACQUIRE:EXCEPTION', {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      });
    } finally {
      setState(() => _isAcquiring = false);
    }
  }

  Future<void> _testStart() async {
    if (_resourceId == null) {
      _addLog('ERROR', {'message': 'Must acquire resourceId first'});
      return;
    }

    final channel = _channelController.text.trim();
    final uid = _uidController.text.trim();

    setState(() => _isStarting = true);

    try {
      _addLog('START:REQUEST', {
        'channelName': channel,
        'uid': uid,
        'resourceId': _resourceId,
        'endpoint': '/api/agora/recording/start',
      });

      final result = await AgoraRecordingService.start(
        channelName: channel,
        uid: uid,
        resourceId: _resourceId!,
      );

      _addLog('START:RESPONSE', {
        'success': result.success,
        'sid': result.sid,
        'resourceId': result.resourceId,
        'message': result.message,
        'errorMessage': result.errorMessage,
      });

      if (result.success && result.sid != null) {
        setState(() => _sid = result.sid);
        _addLog('START:SUCCESS', {
          'sid': result.sid,
          'canStopRecording': true,
        });
      } else {
        _addLog('START:FAILED', {
          'reason': result.errorMessage ?? 'Unknown error',
          'checkBackendLogs': 'Check your Node.js backend console NOW',
          'possibleCauses': [
            '1. resourceId expired (>5 min since acquire)',
            '2. Channel not live / No one broadcasting',
            '3. Backend Agora credentials invalid',
            '4. Backend not running',
            '5. Invalid channelName or uid',
          ],
          'whatToDoNext': [
            'Open backend terminal/console',
            'Look for error message in backend logs',
            'Check BACKEND_DEBUGGING.md for solutions',
          ],
        });
      }
    } catch (e, stackTrace) {
      _addLog('START:EXCEPTION', {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      });
    } finally {
      setState(() => _isStarting = false);
    }
  }

  Future<void> _testStop() async {
    if (_resourceId == null || _sid == null) {
      _addLog('ERROR', {
        'message': 'Must have resourceId and sid',
        'resourceId': _resourceId,
        'sid': _sid,
      });
      return;
    }

    final channel = _channelController.text.trim();
    final uid = _uidController.text.trim();

    setState(() => _isStopping = true);

    try {
      _addLog('STOP:REQUEST', {
        'channelName': channel,
        'uid': uid,
        'resourceId': _resourceId,
        'sid': _sid,
        'endpoint': '/api/agora/recording/stop',
      });

      final result = await AgoraRecordingService.stop(
        channelName: channel,
        uid: uid,
        resourceId: _resourceId!,
        sid: _sid!,
      );

      _addLog('STOP:RESPONSE', {
        'success': result.success,
        'fileUrl': result.fileUrl,
        'mp4Url': result.mp4Url,
        'message': result.message,
        'errorMessage': result.errorMessage,
        'serverResponse': result.serverResponse,
      });

      if (result.success) {
        setState(() => _fileUrl = result.fileUrl);
        
        if (result.fileUrl != null && result.fileUrl!.isNotEmpty) {
          _addLog('STOP:SUCCESS', {
            'fileUrl': result.fileUrl,
            'status': 'Video URL available immediately',
          });
        } else {
          _addLog('STOP:WARNING', {
            'fileUrl': null,
            'status': 'No file URL - Storage not configured on backend',
            'serverResponse': result.serverResponse,
            'recommendation': 'Check AGORA_RECORDING_SETUP.md',
          });
        }
      } else {
        _addLog('STOP:FAILED', {
          'reason': result.errorMessage ?? 'Unknown error',
        });
      }
    } catch (e, stackTrace) {
      _addLog('STOP:EXCEPTION', {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      });
    } finally {
      setState(() => _isStopping = false);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording Diagnostic Tool'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '📋 Recording Diagnostic Tool',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Test the recording APIs step-by-step:\n'
                    '1. Acquire → Gets resource ID\n'
                    '2. Start → Begins recording (needs resource ID)\n'
                    '3. Stop → Stops recording (returns file URL if storage configured)',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Backend Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '⚠️ If "Start Failed" - Check Backend',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Backend must be running at: http://67.225.241.58:4004\n'
                    'Open backend console and watch for errors\n'
                    'See BACKEND_DEBUGGING.md for common issues',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Input fields
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _channelController,
                    decoration: const InputDecoration(
                      labelText: 'Channel Name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _uidController,
                    decoration: const InputDecoration(
                      labelText: 'UID',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: _isAcquiring ? 'Acquiring...' : '1. Acquire',
                    buttonColor: _resourceId != null ? Colors.green : AppColors.primaryColor,
                    onTap: _isAcquiring ? null : _testAcquire,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: _isStarting ? 'Starting...' : '2. Start',
                    buttonColor: _sid != null ? Colors.green : Colors.orange,
                    onTap: (_isStarting || _resourceId == null) ? null : _testStart,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: _isStopping ? 'Stopping...' : '3. Stop',
                    buttonColor: _fileUrl != null ? Colors.green : Colors.red,
                    onTap: (_isStopping || _sid == null) ? null : _testStop,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: _clearLogs,
                  tooltip: 'Clear Logs',
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Status indicators
            if (_resourceId != null || _sid != null || _fileUrl != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_resourceId != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          const Text('Resource ID: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              _resourceId!,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: () => _copyToClipboard(_resourceId!),
                          ),
                        ],
                      ),
                    ],
                    if (_sid != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          const Text('SID: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              _sid!,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: () => _copyToClipboard(_sid!),
                          ),
                        ],
                      ),
                    ],
                    if (_fileUrl != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          const Text('File URL: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              _fileUrl!,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: () => _copyToClipboard(_fileUrl!),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Logs section
            const Text(
              'API Logs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _logs.isEmpty
                    ? const Center(
                        child: Text(
                          'No logs yet. Click buttons above to test.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          final action = log['action'] as String;
                          final data = log['data'] as Map<String, dynamic>;
                          final time = log['time'] as String;

                          Color actionColor = Colors.black;
                          if (action.contains('ERROR') || action.contains('FAILED') || action.contains('EXCEPTION')) {
                            actionColor = Colors.red;
                          } else if (action.contains('SUCCESS')) {
                            actionColor = Colors.green;
                          } else if (action.contains('WARNING')) {
                            actionColor = Colors.orange;
                          } else if (action.contains('RESPONSE')) {
                            actionColor = Colors.blue;
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              title: Row(
                                children: [
                                  Text(
                                    action,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: actionColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateTime.parse(time).toLocal().toString().substring(11, 19),
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  color: Colors.grey.shade50,
                                  child: SelectableText(
                                    JsonEncoder.withIndent('  ').convert(data),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

  @override
  void dispose() {
    _channelController.dispose();
    _uidController.dispose();
    super.dispose();
  }
}
