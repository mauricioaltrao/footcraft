import 'package:flutter/material.dart';

import 'fcb/fcb_document.dart';
import 'l10n/app_localizations.dart';
import 'midi/midi_link.dart';
import 'src/rust/frb_generated.dart';
import 'ui/home_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  await FcbDocument.instance.init();
  runApp(const FootCraftApp());
  MidiLink.instance.init();
}

class FootCraftApp extends StatelessWidget {
  const FootCraftApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FootCraft',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const HomeScreen(),
  );
}
