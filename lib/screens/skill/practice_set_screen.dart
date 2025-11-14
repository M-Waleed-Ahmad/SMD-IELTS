import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/api_client.dart';
import '../../models/practice_set.dart';
import '../../widgets/primary_button.dart';

class PracticeSetScreen extends StatefulWidget {
  final PracticeSet? set;
  final String? practiceSetId;
  const PracticeSetScreen({super.key, this.set, this.practiceSetId});

  @override
  State<PracticeSetScreen> createState() => _PracticeSetScreenState();
}

class _PracticeSetScreenState extends State<PracticeSetScreen> {
  final _api = ApiClient();
  Map<String, dynamic>? _detail;
  late String _id;

  @override
  void initState() {
    super.initState();
    _id = widget.practiceSetId ?? widget.set!.id;
    _load();
  }

  Future<void> _load() async {
    final d = await _api.getPracticeSet(_id);
    setState(() => _detail = d);
  }

  @override
  Widget build(BuildContext context) {
    if (_detail == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final ps = _detail!['practice_set'] as Map<String, dynamic>;
    final skill = _detail!['skill'] as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: Text(ps['title'] as String)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.school),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${skill['name']} • ${ps['level_tag']}', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('${_detail!['question_count']} questions • ~${ps['estimated_minutes']} min', style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 14),
              Text(ps['short_description'] ?? ''),
              const SizedBox(height: 24),
              const Spacer(),
              PrimaryButton(
                label: 'Start',
                onPressed: () {
                  Navigator.pushNamed(context, '/questionPlayer', arguments: _id);
                },
              ),
              const SizedBox(height: kPageHPad),
            ],
          ),
        ),
      ),
    );
  }
}
