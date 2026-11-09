import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'FootCraft'**
  String get appTitle;

  /// No description provided for @bank.
  ///
  /// In pt, this message translates to:
  /// **'Banco'**
  String get bank;

  /// No description provided for @bankPedal.
  ///
  /// In pt, this message translates to:
  /// **'Banco {bank} · Pedal {pedal}'**
  String bankPedal(int bank, int pedal);

  /// No description provided for @banksRange.
  ///
  /// In pt, this message translates to:
  /// **'Bancos {from} a {to}'**
  String banksRange(int from, int to);

  /// No description provided for @pedalsRange.
  ///
  /// In pt, this message translates to:
  /// **'Pedais {from} a {to}'**
  String pedalsRange(int from, int to);

  /// No description provided for @batchApplied.
  ///
  /// In pt, this message translates to:
  /// **'{count} pedais programados. Dá para desfazer.'**
  String batchApplied(int count);

  /// No description provided for @batchApply.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar em {count} pedais'**
  String batchApply(int count);

  /// No description provided for @batchTitle.
  ///
  /// In pt, this message translates to:
  /// **'Programar vários'**
  String get batchTitle;

  /// No description provided for @boardHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque num pedal para editar. Toque longo (ou botão direito) para copiar, colar ou silenciar. As mudanças só vão para a FCB quando você toca em Enviar para a FCB.'**
  String get boardHint;

  /// No description provided for @calibrationNote.
  ///
  /// In pt, this message translates to:
  /// **'A calibração dos pedais de expressão é feita na própria FCB e é preservada como está.'**
  String get calibrationNote;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @channelN.
  ///
  /// In pt, this message translates to:
  /// **'Canal {n}'**
  String channelN(int n);

  /// No description provided for @clear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get clear;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @connect.
  ///
  /// In pt, this message translates to:
  /// **'Conectar'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In pt, this message translates to:
  /// **'Desconectar'**
  String get disconnect;

  /// No description provided for @controlChanges.
  ///
  /// In pt, this message translates to:
  /// **'Control Change'**
  String get controlChanges;

  /// No description provided for @controlChangesHint.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens CC fixas mandadas ao pisar no pedal: número do controle e valor.'**
  String get controlChangesHint;

  /// No description provided for @controller.
  ///
  /// In pt, this message translates to:
  /// **'CC'**
  String get controller;

  /// No description provided for @copy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get copy;

  /// No description provided for @copyBank.
  ///
  /// In pt, this message translates to:
  /// **'Copiar banco'**
  String get copyBank;

  /// No description provided for @copyPedal.
  ///
  /// In pt, this message translates to:
  /// **'Copiar pedal'**
  String get copyPedal;

  /// No description provided for @pastePedal.
  ///
  /// In pt, this message translates to:
  /// **'Colar pedal'**
  String get pastePedal;

  /// No description provided for @silencePedal.
  ///
  /// In pt, this message translates to:
  /// **'Silenciar pedal'**
  String get silencePedal;

  /// No description provided for @silencePedalHint.
  ///
  /// In pt, this message translates to:
  /// **'Desliga trocas de programa, CCs, nota e relés (os pedais de expressão ficam).'**
  String get silencePedalHint;

  /// No description provided for @directSelect.
  ///
  /// In pt, this message translates to:
  /// **'Seleção direta'**
  String get directSelect;

  /// No description provided for @directSelectHint.
  ///
  /// In pt, this message translates to:
  /// **'Os pedais 1–10 escolhem o banco e depois o preset, sem usar UP/DOWN.'**
  String get directSelectHint;

  /// No description provided for @runningStatus.
  ///
  /// In pt, this message translates to:
  /// **'Running status'**
  String get runningStatus;

  /// No description provided for @runningStatusHint.
  ///
  /// In pt, this message translates to:
  /// **'Omite o byte de status repetido. Desligue se algum aparelho estranhar as mensagens.'**
  String get runningStatusHint;

  /// No description provided for @merge.
  ///
  /// In pt, this message translates to:
  /// **'Merge (MIDI IN → OUT)'**
  String get merge;

  /// No description provided for @mergeHint.
  ///
  /// In pt, this message translates to:
  /// **'Repassa para a saída da FCB o que chega na entrada MIDI dela.'**
  String get mergeHint;

  /// No description provided for @upTogglesRelay1.
  ///
  /// In pt, this message translates to:
  /// **'UP liga/desliga o relé 1'**
  String get upTogglesRelay1;

  /// No description provided for @downTogglesRelay2.
  ///
  /// In pt, this message translates to:
  /// **'DOWN liga/desliga o relé 2'**
  String get downTogglesRelay2;

  /// No description provided for @relayKeysHint.
  ///
  /// In pt, this message translates to:
  /// **'Vale quando a seleção direta está ligada.'**
  String get relayKeysHint;

  /// No description provided for @expressionN.
  ///
  /// In pt, this message translates to:
  /// **'Expressão {name}'**
  String expressionN(String name);

  /// No description provided for @expressionPedals.
  ///
  /// In pt, this message translates to:
  /// **'Pedais de expressão'**
  String get expressionPedals;

  /// No description provided for @expressionPedalsHint.
  ///
  /// In pt, this message translates to:
  /// **'O CC que cada pedal de expressão manda neste preset, entre o mínimo e o máximo.'**
  String get expressionPedalsHint;

  /// No description provided for @factoryVAmp.
  ///
  /// In pt, this message translates to:
  /// **'V-AMP (padrão de fábrica)'**
  String get factoryVAmp;

  /// No description provided for @factoryGuitarAmps.
  ///
  /// In pt, this message translates to:
  /// **'Amplificadores Behringer'**
  String get factoryGuitarAmps;

  /// No description provided for @factoryBassVAmp.
  ///
  /// In pt, this message translates to:
  /// **'Bass V-AMP'**
  String get factoryBassVAmp;

  /// No description provided for @factoryNamed.
  ///
  /// In pt, this message translates to:
  /// **'Fábrica: {name}'**
  String factoryNamed(String name);

  /// No description provided for @newFromFactory.
  ///
  /// In pt, this message translates to:
  /// **'Começar da configuração de fábrica:'**
  String get newFromFactory;

  /// No description provided for @fileOpened.
  ///
  /// In pt, this message translates to:
  /// **'Arquivo aberto: {name}'**
  String fileOpened(String name);

  /// No description provided for @fileSaved.
  ///
  /// In pt, this message translates to:
  /// **'Salvo em {path}'**
  String fileSaved(String path);

  /// No description provided for @notAnFcbFile.
  ///
  /// In pt, this message translates to:
  /// **'{name} não é um dump da FCB1010.'**
  String notAnFcbFile(String name);

  /// No description provided for @globalSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações globais'**
  String get globalSettings;

  /// No description provided for @inputFromFcb.
  ///
  /// In pt, this message translates to:
  /// **'Entrada (vem da FCB)'**
  String get inputFromFcb;

  /// No description provided for @outputToFcb.
  ///
  /// In pt, this message translates to:
  /// **'Saída (vai para a FCB)'**
  String get outputToFcb;

  /// No description provided for @maximum.
  ///
  /// In pt, this message translates to:
  /// **'Máx'**
  String get maximum;

  /// No description provided for @minimum.
  ///
  /// In pt, this message translates to:
  /// **'Mín'**
  String get minimum;

  /// No description provided for @midiChannels.
  ///
  /// In pt, this message translates to:
  /// **'Canais MIDI'**
  String get midiChannels;

  /// No description provided for @midiChannelsHint.
  ///
  /// In pt, this message translates to:
  /// **'Canal de cada tipo de mensagem, para todos os presets.'**
  String get midiChannelsHint;

  /// No description provided for @sameChannelForAll.
  ///
  /// In pt, this message translates to:
  /// **'Usar o mesmo canal para tudo'**
  String get sameChannelForAll;

  /// No description provided for @operation.
  ///
  /// In pt, this message translates to:
  /// **'Funcionamento'**
  String get operation;

  /// No description provided for @midiMonitor.
  ///
  /// In pt, this message translates to:
  /// **'Monitor MIDI'**
  String get midiMonitor;

  /// No description provided for @midiMonitorHint.
  ///
  /// In pt, this message translates to:
  /// **'O que chega da FCB. Pise nos pedais para conferir.'**
  String get midiMonitorHint;

  /// No description provided for @monitorEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nada recebido ainda.'**
  String get monitorEmpty;

  /// No description provided for @monitorSysex.
  ///
  /// In pt, this message translates to:
  /// **'SysEx de {count} bytes'**
  String monitorSysex(int count);

  /// No description provided for @midiPorts.
  ///
  /// In pt, this message translates to:
  /// **'Portas MIDI'**
  String get midiPorts;

  /// No description provided for @midiPortsHint.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a interface MIDI ligada à FCB1010: a entrada recebe o que a FCB manda e a saída leva até ela.'**
  String get midiPortsHint;

  /// No description provided for @noPorts.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma porta MIDI encontrada. Ligue a interface USB-MIDI e toque em Atualizar.'**
  String get noPorts;

  /// No description provided for @notConnected.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão MIDI'**
  String get notConnected;

  /// No description provided for @refresh.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get refresh;

  /// No description provided for @modeKeep.
  ///
  /// In pt, this message translates to:
  /// **'Manter'**
  String get modeKeep;

  /// No description provided for @modeOff.
  ///
  /// In pt, this message translates to:
  /// **'Desligar'**
  String get modeOff;

  /// No description provided for @modeOn.
  ///
  /// In pt, this message translates to:
  /// **'Ligar'**
  String get modeOn;

  /// No description provided for @modeFixed.
  ///
  /// In pt, this message translates to:
  /// **'Fixo'**
  String get modeFixed;

  /// No description provided for @modeSequence.
  ///
  /// In pt, this message translates to:
  /// **'Sequência'**
  String get modeSequence;

  /// No description provided for @valueFixed.
  ///
  /// In pt, this message translates to:
  /// **'Valor fixo'**
  String get valueFixed;

  /// No description provided for @valueSequence.
  ///
  /// In pt, this message translates to:
  /// **'Valor em sequência'**
  String get valueSequence;

  /// No description provided for @startAt.
  ///
  /// In pt, this message translates to:
  /// **'Começa em'**
  String get startAt;

  /// No description provided for @step.
  ///
  /// In pt, this message translates to:
  /// **'Passo'**
  String get step;

  /// No description provided for @value.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get value;

  /// No description provided for @program.
  ///
  /// In pt, this message translates to:
  /// **'Programa'**
  String get program;

  /// No description provided for @modified.
  ///
  /// In pt, this message translates to:
  /// **'alterada'**
  String get modified;

  /// No description provided for @nextBank.
  ///
  /// In pt, this message translates to:
  /// **'Próximo banco'**
  String get nextBank;

  /// No description provided for @previousBank.
  ///
  /// In pt, this message translates to:
  /// **'Banco anterior'**
  String get previousBank;

  /// No description provided for @nextPedal.
  ///
  /// In pt, this message translates to:
  /// **'Próximo pedal'**
  String get nextPedal;

  /// No description provided for @previousPedal.
  ///
  /// In pt, this message translates to:
  /// **'Pedal anterior'**
  String get previousPedal;

  /// No description provided for @noPedalsChosen.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum pedal escolhido.'**
  String get noPedalsChosen;

  /// No description provided for @note.
  ///
  /// In pt, this message translates to:
  /// **'Nota'**
  String get note;

  /// No description provided for @noteSection.
  ///
  /// In pt, this message translates to:
  /// **'Nota'**
  String get noteSection;

  /// No description provided for @noteHint.
  ///
  /// In pt, this message translates to:
  /// **'Nota MIDI mandada ao pisar (60 = C4).'**
  String get noteHint;

  /// No description provided for @openFile.
  ///
  /// In pt, this message translates to:
  /// **'Abrir arquivo .syx'**
  String get openFile;

  /// No description provided for @saveFile.
  ///
  /// In pt, this message translates to:
  /// **'Salvar arquivo .syx'**
  String get saveFile;

  /// No description provided for @openInEditor.
  ///
  /// In pt, this message translates to:
  /// **'Abrir no editor'**
  String get openInEditor;

  /// No description provided for @pedalCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} pedais'**
  String pedalCount(int count);

  /// No description provided for @whichPedals.
  ///
  /// In pt, this message translates to:
  /// **'Quais pedais'**
  String get whichPedals;

  /// No description provided for @scopeAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos os 100'**
  String get scopeAll;

  /// No description provided for @scopeCurrentBank.
  ///
  /// In pt, this message translates to:
  /// **'Só o banco {bank}'**
  String scopeCurrentBank(int bank);

  /// No description provided for @preview.
  ///
  /// In pt, this message translates to:
  /// **'Como vai ficar'**
  String get preview;

  /// No description provided for @programChanges.
  ///
  /// In pt, this message translates to:
  /// **'Program Change'**
  String get programChanges;

  /// No description provided for @programChangesHint.
  ///
  /// In pt, this message translates to:
  /// **'Até 5 trocas de programa por pedal, cada uma no seu canal (configurações globais).'**
  String get programChangesHint;

  /// No description provided for @receiveFromFcb.
  ///
  /// In pt, this message translates to:
  /// **'Receber da FCB'**
  String get receiveFromFcb;

  /// No description provided for @sendToFcb.
  ///
  /// In pt, this message translates to:
  /// **'Enviar para a FCB'**
  String get sendToFcb;

  /// No description provided for @receiveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Receber da FCB1010'**
  String get receiveTitle;

  /// No description provided for @sendTitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviar para a FCB1010'**
  String get sendTitle;

  /// No description provided for @stepPowerDown.
  ///
  /// In pt, this message translates to:
  /// **'Ligue a FCB segurando o pedal DOWN por uns 2 segundos.'**
  String get stepPowerDown;

  /// No description provided for @stepConfiguration.
  ///
  /// In pt, this message translates to:
  /// **'Pressione UP até acender o LED CONFIGURATION.'**
  String get stepConfiguration;

  /// No description provided for @stepSysexSend.
  ///
  /// In pt, this message translates to:
  /// **'Pise no pedal 6 (SYSEX SEND).'**
  String get stepSysexSend;

  /// No description provided for @stepSysexRcv.
  ///
  /// In pt, this message translates to:
  /// **'Pise no pedal 7 (SYSEX RCV): o LED dele acende.'**
  String get stepSysexRcv;

  /// No description provided for @stepPressSend.
  ///
  /// In pt, this message translates to:
  /// **'Toque em Enviar agora. Quando o LED do pedal 7 apagar, saia com um toque longo em DOWN.'**
  String get stepPressSend;

  /// No description provided for @waitingDump.
  ///
  /// In pt, this message translates to:
  /// **'Esperando a FCB mandar…'**
  String get waitingDump;

  /// No description provided for @receiving.
  ///
  /// In pt, this message translates to:
  /// **'Recebendo: {done} de {total} bytes'**
  String receiving(int done, int total);

  /// No description provided for @receivedDump.
  ///
  /// In pt, this message translates to:
  /// **'Configuração recebida!'**
  String get receivedDump;

  /// No description provided for @receivedIncomplete.
  ///
  /// In pt, this message translates to:
  /// **'Chegou um SysEx da Behringer incompleto ({count} bytes). Tente de novo.'**
  String receivedIncomplete(int count);

  /// No description provided for @receiveNote.
  ///
  /// In pt, this message translates to:
  /// **'Uma cópia do que chegar fica guardada em Documentos/FootCraft/backups.'**
  String get receiveNote;

  /// No description provided for @receivedAt.
  ///
  /// In pt, this message translates to:
  /// **'Recebido da FCB em {when}'**
  String receivedAt(String when);

  /// No description provided for @receivedOk.
  ///
  /// In pt, this message translates to:
  /// **'Configuração da FCB aberta. Cópia em {path}'**
  String receivedOk(String path);

  /// No description provided for @sendWarning.
  ///
  /// In pt, this message translates to:
  /// **'Isto substitui os 100 presets e as configurações globais da FCB. Se quiser uma cópia do que está nela, use Receber da FCB antes.'**
  String get sendWarning;

  /// No description provided for @sendNow.
  ///
  /// In pt, this message translates to:
  /// **'Enviar agora'**
  String get sendNow;

  /// No description provided for @sending.
  ///
  /// In pt, this message translates to:
  /// **'Enviando…'**
  String get sending;

  /// No description provided for @sentCheckLed.
  ///
  /// In pt, this message translates to:
  /// **'Enviado! Confira se o LED do pedal 7 apagou e saia da configuração com um toque longo em DOWN. Se o LED continuar aceso, a FCB não recebeu: refaça os passos 1 a 3.'**
  String get sentCheckLed;

  /// No description provided for @sendFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar: {error}'**
  String sendFailed(String error);

  /// No description provided for @sendsNothing.
  ///
  /// In pt, this message translates to:
  /// **'não manda nada'**
  String get sendsNothing;

  /// No description provided for @recipes.
  ///
  /// In pt, this message translates to:
  /// **'Receitas prontas'**
  String get recipes;

  /// No description provided for @recipeOneCc.
  ///
  /// In pt, this message translates to:
  /// **'Um CC por pedal'**
  String get recipeOneCc;

  /// No description provided for @recipeOneCcHint.
  ///
  /// In pt, this message translates to:
  /// **'Cada pedal manda só este CC, com valores 1, 2, 3… em ordem. Fácil de mapear em outros apps.'**
  String get recipeOneCcHint;

  /// No description provided for @recipeProgram.
  ///
  /// In pt, this message translates to:
  /// **'Program Change por pedal'**
  String get recipeProgram;

  /// No description provided for @recipeProgramHint.
  ///
  /// In pt, this message translates to:
  /// **'Cada pedal troca para o programa 0, 1, 2… em ordem.'**
  String get recipeProgramHint;

  /// No description provided for @recipeClear.
  ///
  /// In pt, this message translates to:
  /// **'Recomeçar'**
  String get recipeClear;

  /// No description provided for @redo.
  ///
  /// In pt, this message translates to:
  /// **'Refazer'**
  String get redo;

  /// No description provided for @undo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get undo;

  /// No description provided for @relayN.
  ///
  /// In pt, this message translates to:
  /// **'Relé {n}'**
  String relayN(int n);

  /// No description provided for @relays.
  ///
  /// In pt, this message translates to:
  /// **'Relés (SWITCH 1 e 2)'**
  String get relays;

  /// No description provided for @relaysHint.
  ///
  /// In pt, this message translates to:
  /// **'Os contatos de relé na traseira da FCB, para trocar canal de amplificador.'**
  String get relaysHint;

  /// No description provided for @replace.
  ///
  /// In pt, this message translates to:
  /// **'Substituir'**
  String get replace;

  /// No description provided for @replaceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Substituir a configuração aberta?'**
  String get replaceTitle;

  /// No description provided for @replaceBody.
  ///
  /// In pt, this message translates to:
  /// **'Há mudanças que não foram enviadas nem salvas. Dá para voltar com Desfazer.'**
  String get replaceBody;

  /// No description provided for @use.
  ///
  /// In pt, this message translates to:
  /// **'Usar'**
  String get use;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
