import 'package:flutter/material.dart';
import 'package:thai_buddhist_date_pickers/thai_buddhist_date_pickers.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await tbd.ThaiCalendar.ensureInitialized();
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Picked date: ${d ?? '-'}')),
                );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Picked date-time: ${dt ?? '-'}')),
                );
              },
              child: const Text('Pick date-time (ค.ศ.)'),
            ),
          ],
        ),
      ),
    );
  }
}
