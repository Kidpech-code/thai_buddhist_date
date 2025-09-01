import 'package:flutter/material.dart';
import 'package:thai_buddhist_date_pickers/thai_buddhist_date_pickers.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await tbd.ThaiDateService().initializeLocale('th_TH');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thai Pickers Example')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final d = await showThaiDatePicker(
                  context,
                  initialDate: DateTime.now(),
                  era: tbd.Era.be,
                  locale: 'th_TH',
                );
                if (!context.mounted) return;
                final label = d == null ? '-' : tbd.format(d, pattern: 'dmy', era: tbd.Era.be);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Picked date (พ.ศ.): $label')));
              },
              child: const Text('Pick a date (พ.ศ.)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final dt = await showThaiDateTimePicker(
                  context,
                  initialDateTime: DateTime.now(),
                  era: tbd.Era.ce,
                  locale: 'th_TH',
                  formatString: 'dd/MM/yyyy HH:mm',
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Picked date-time (ค.ศ.): ${dt ?? '-'}')));
              },
              child: const Text('Pick date-time (ค.ศ.)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final range = await showThaiDateRangePicker(
                  context,
                  era: tbd.Era.be,
                  locale: 'th_TH',
                );
                if (!context.mounted) return;
                final text = range == null ? '-' : '${tbd.format(range.start, pattern: 'dmy')} → ${tbd.format(range.end, pattern: 'dmy')}';
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Picked range: $text')));
              },
              child: const Text('Pick range (พ.ศ.)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final multiple = await showThaiMultiDatePicker(
                  context,
                  era: tbd.Era.be,
                  locale: 'th_TH',
                );
                if (!context.mounted) return;
                final list = (multiple ?? const <DateTime>{}).map((d) => tbd.format(d, pattern: 'dd/MM/yyyy')).join(', ');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Picked multiple: ${list.isEmpty ? '-' : list}')));
              },
              child: const Text('Pick multiple (พ.ศ.)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final d = await showThaiDatePickerFullscreen(
                  context,
                  initialDate: DateTime.now(),
                  era: tbd.Era.be,
                  locale: 'th_TH',
                );
                if (!context.mounted) return;
                final label = d == null ? '-' : tbd.format(d, pattern: 'dmy', era: tbd.Era.be);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Picked fullscreen: $label')));
              },
              child: const Text('Pick fullscreen (พ.ศ.)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final s = await showThaiDatePickerFormatted(
                  context,
                  era: tbd.Era.be,
                  locale: 'th_TH',
                  formatString: 'dd MMM yyyy',
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Formatted (dialog returns string): ${s ?? '-'}')));
              },
              child: const Text('Pick date (formatted)'),
            ),
          ],
        ),
      ),
    );
  }
}
