// Gera capturas das telas em tamanho de celular para conferir o layout:
//   flutter test test/screens --update-goldens
// As imagens ficam em test/screens/goldens/ (fora do controle de versão).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

import 'package:footcraft/fcb/fcb_document.dart';
import 'package:footcraft/fcb/test_mode.dart';
import 'package:footcraft/midi/midi_link.dart';
import 'package:footcraft/l10n/app_localizations.dart';
import 'package:footcraft/ui/batch_screen.dart';
import 'package:footcraft/ui/home_screen.dart';
import 'package:footcraft/ui/pedal_editor.dart';
import 'package:footcraft/ui/theme.dart';

Future<void> _loadFonts() async {
  const dir = '/opt/flutter/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto');
  for (final f in ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf']) {
    roboto.addFont(Future.value(ByteData.sublistView(File('$dir/$f').readAsBytesSync())));
  }
  await roboto.load();
  final mono = FontLoader('monospace')
    ..addFont(Future.value(ByteData.sublistView(File('/usr/share/fonts/google-noto/NotoSansMono-Regular.ttf').readAsBytesSync())));
  await mono.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(File('$dir/MaterialIcons-Regular.otf').readAsBytesSync())));
  await icons.load();
}

Widget _app(Widget home) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: buildTheme().copyWith(textTheme: buildTheme().textTheme.apply(fontFamily: 'Roboto')),
  locale: const Locale('pt'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFonts();
    FcbDocument.instance.loadSysex(File('test/fixtures/cc102.syx').readAsBytesSync(), SetupSource.device, 'Recebido da FCB');
  });

  for (final (name, size) in [('retrato', const Size(412, 915)), ('paisagem', const Size(915, 412))]) {
    for (final (screen, widget) in [
      ('inicio', const HomeScreen()),
      ('pedal', const Scaffold(body: PedalEditor())),
      ('lote', const BatchScreen()),
    ]) {
      testWidgets('$screen $name', skip: !autoUpdateGoldenFiles, (tester) async {
        tester.view.physicalSize = size * 2.625;
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_app(widget));
        await tester.pumpAndSettle();
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/${screen}_$name.png'));
      });
    }
  }

  testWidgets('modo de teste com pedal pisado', skip: !autoUpdateGoldenFiles, (tester) async {
    tester.view.physicalSize = const Size(412, 915) * 2.625;
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const HomeScreen()));
    TestMode.instance.start();
    // A FCB manda CC 102 = 23 (banco 2, pedal 3) e mexe o pedal de expressão A.
    MidiLink.instance.messages.add(Uint8List.fromList([0xB0, 102, 23]));
    await tester.pump(const Duration(milliseconds: 120));
    MidiLink.instance.messages.add(Uint8List.fromList([0xB0, 7, 90]));
    await tester.pump(const Duration(milliseconds: 50));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/teste_retrato.png'));
    TestMode.instance.stop();
    await tester.pumpAndSettle();
  });
}
