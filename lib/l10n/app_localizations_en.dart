// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FootCraft';

  @override
  String get bank => 'Bank';

  @override
  String bankPedal(int bank, int pedal) {
    return 'Bank $bank · Pedal $pedal';
  }

  @override
  String banksRange(int from, int to) {
    return 'Banks $from to $to';
  }

  @override
  String pedalsRange(int from, int to) {
    return 'Pedals $from to $to';
  }

  @override
  String batchApplied(int count) {
    return '$count pedals programmed. You can undo it.';
  }

  @override
  String batchApply(int count) {
    return 'Apply to $count pedals';
  }

  @override
  String get batchTitle => 'Program many';

  @override
  String get boardHint =>
      'Tap a pedal to edit it. Long-press (or right-click) to copy, paste or silence it. Changes only reach the FCB when you tap Send to FCB.';

  @override
  String get calibrationNote =>
      'Expression pedal calibration is done on the FCB itself and is kept as is.';

  @override
  String get cancel => 'Cancel';

  @override
  String channelN(int n) {
    return 'Channel $n';
  }

  @override
  String get clear => 'Clear';

  @override
  String get close => 'Close';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get controlChanges => 'Control Change';

  @override
  String get controlChangesHint =>
      'Fixed CC messages sent when the pedal is pressed: controller number and value.';

  @override
  String get controller => 'CC';

  @override
  String get copy => 'Copy';

  @override
  String get copyBank => 'Copy bank';

  @override
  String get copyPedal => 'Copy pedal';

  @override
  String get pastePedal => 'Paste pedal';

  @override
  String get silencePedal => 'Silence pedal';

  @override
  String get silencePedalHint =>
      'Turns off program changes, CCs, note and relays (expression pedals stay).';

  @override
  String get directSelect => 'Direct select';

  @override
  String get directSelectHint =>
      'Pedals 1–10 pick the bank and then the preset, without UP/DOWN.';

  @override
  String get runningStatus => 'Running status';

  @override
  String get runningStatusHint =>
      'Omits repeated status bytes. Turn it off if a device misreads the messages.';

  @override
  String get merge => 'Merge (MIDI IN → OUT)';

  @override
  String get mergeHint =>
      'Passes what arrives at the FCB MIDI input on to its output.';

  @override
  String get upTogglesRelay1 => 'UP toggles relay 1';

  @override
  String get downTogglesRelay2 => 'DOWN toggles relay 2';

  @override
  String get relayKeysHint => 'Applies when direct select is on.';

  @override
  String expressionN(String name) {
    return 'Expression $name';
  }

  @override
  String get expressionPedals => 'Expression pedals';

  @override
  String get expressionPedalsHint =>
      'The CC each expression pedal sends in this preset, between minimum and maximum.';

  @override
  String get factoryVAmp => 'V-AMP (factory default)';

  @override
  String get factoryGuitarAmps => 'Behringer guitar amps';

  @override
  String get factoryBassVAmp => 'Bass V-AMP';

  @override
  String factoryNamed(String name) {
    return 'Factory: $name';
  }

  @override
  String get newFromFactory => 'Start from a factory setup:';

  @override
  String fileOpened(String name) {
    return 'File opened: $name';
  }

  @override
  String fileSaved(String path) {
    return 'Saved to $path';
  }

  @override
  String notAnFcbFile(String name) {
    return '$name is not an FCB1010 dump.';
  }

  @override
  String get globalSettings => 'Global settings';

  @override
  String get inputFromFcb => 'Input (from the FCB)';

  @override
  String get outputToFcb => 'Output (to the FCB)';

  @override
  String get maximum => 'Max';

  @override
  String get minimum => 'Min';

  @override
  String get midiChannels => 'MIDI channels';

  @override
  String get midiChannelsHint =>
      'Channel of each message type, for all presets.';

  @override
  String get sameChannelForAll => 'Use the same channel for everything';

  @override
  String get operation => 'Operation';

  @override
  String get midiMonitor => 'MIDI monitor';

  @override
  String get midiMonitorHint =>
      'What arrives from the FCB. Press the pedals to check.';

  @override
  String get monitorEmpty => 'Nothing received yet.';

  @override
  String monitorSysex(int count) {
    return 'SysEx, $count bytes';
  }

  @override
  String get midiPorts => 'MIDI ports';

  @override
  String get midiPortsHint =>
      'Choose the MIDI interface connected to the FCB1010: the input receives what the FCB sends and the output goes to it.';

  @override
  String get noPorts =>
      'No MIDI ports found. Plug in the USB-MIDI interface and tap Refresh.';

  @override
  String get notConnected => 'No MIDI connection';

  @override
  String get refresh => 'Refresh';

  @override
  String get modeKeep => 'Keep';

  @override
  String get modeOff => 'Off';

  @override
  String get modeOn => 'On';

  @override
  String get modeFixed => 'Fixed';

  @override
  String get modeSequence => 'Sequence';

  @override
  String get valueFixed => 'Fixed value';

  @override
  String get valueSequence => 'Value in sequence';

  @override
  String get startAt => 'Starts at';

  @override
  String get step => 'Step';

  @override
  String get value => 'Value';

  @override
  String get program => 'Program';

  @override
  String get modified => 'modified';

  @override
  String get nextBank => 'Next bank';

  @override
  String get previousBank => 'Previous bank';

  @override
  String get nextPedal => 'Next pedal';

  @override
  String get previousPedal => 'Previous pedal';

  @override
  String get noPedalsChosen => 'No pedals chosen.';

  @override
  String get note => 'Note';

  @override
  String get noteSection => 'Note';

  @override
  String get noteHint => 'MIDI note sent when pressed (60 = C4).';

  @override
  String get openFile => 'Open .syx file';

  @override
  String get saveFile => 'Save .syx file';

  @override
  String get openInEditor => 'Open in editor';

  @override
  String pedalCount(int count) {
    return '$count pedals';
  }

  @override
  String get whichPedals => 'Which pedals';

  @override
  String get scopeAll => 'All 100';

  @override
  String scopeCurrentBank(int bank) {
    return 'Only bank $bank';
  }

  @override
  String get preview => 'Preview';

  @override
  String get programChanges => 'Program Change';

  @override
  String get programChangesHint =>
      'Up to 5 program changes per pedal, each on its own channel (global settings).';

  @override
  String get receiveFromFcb => 'Receive from FCB';

  @override
  String get sendToFcb => 'Send to FCB';

  @override
  String get receiveTitle => 'Receive from the FCB1010';

  @override
  String get sendTitle => 'Send to the FCB1010';

  @override
  String get stepPowerDown =>
      'Power on the FCB holding the DOWN pedal for about 2 seconds.';

  @override
  String get stepConfiguration =>
      'Press UP until the CONFIGURATION LED lights up.';

  @override
  String get stepSysexSend => 'Press pedal 6 (SYSEX SEND).';

  @override
  String get stepSysexRcv => 'Press pedal 7 (SYSEX RCV): its LED lights up.';

  @override
  String get stepPressSend =>
      'Tap Send now. When the pedal 7 LED goes off, exit with a long press on DOWN.';

  @override
  String get waitingDump => 'Waiting for the FCB…';

  @override
  String receiving(int done, int total) {
    return 'Receiving: $done of $total bytes';
  }

  @override
  String get receivedDump => 'Setup received!';

  @override
  String receivedIncomplete(int count) {
    return 'An incomplete Behringer SysEx arrived ($count bytes). Try again.';
  }

  @override
  String get receiveNote =>
      'A copy of what arrives is kept in Documents/FootCraft/backups.';

  @override
  String receivedAt(String when) {
    return 'Received from the FCB on $when';
  }

  @override
  String receivedOk(String path) {
    return 'FCB setup opened. Copy at $path';
  }

  @override
  String get sendWarning =>
      'This replaces the FCB\'s 100 presets and global settings. If you want a copy of what\'s on it, use Receive from FCB first.';

  @override
  String get sendNow => 'Send now';

  @override
  String get sending => 'Sending…';

  @override
  String get sentCheckLed =>
      'Sent! Check that the pedal 7 LED went off and leave setup with a long press on DOWN. If it stays lit, the FCB didn\'t receive it: redo steps 1 to 3.';

  @override
  String sendFailed(String error) {
    return 'Could not send: $error';
  }

  @override
  String get sendsNothing => 'sends nothing';

  @override
  String get recipes => 'Ready-made recipes';

  @override
  String get recipeOneCc => 'One CC per pedal';

  @override
  String get recipeOneCcHint =>
      'Each pedal sends only this CC, with values 1, 2, 3… in order. Easy to map in other apps.';

  @override
  String get recipeProgram => 'Program Change per pedal';

  @override
  String get recipeProgramHint =>
      'Each pedal switches to program 0, 1, 2… in order.';

  @override
  String get recipeClear => 'Start over';

  @override
  String get redo => 'Redo';

  @override
  String get undo => 'Undo';

  @override
  String relayN(int n) {
    return 'Relay $n';
  }

  @override
  String get relays => 'Relays (SWITCH 1 and 2)';

  @override
  String get relaysHint =>
      'The relay contacts on the back of the FCB, for switching amp channels.';

  @override
  String get replace => 'Replace';

  @override
  String get replaceTitle => 'Replace the open setup?';

  @override
  String get replaceBody =>
      'There are changes that were not sent or saved. You can go back with Undo.';

  @override
  String get use => 'Use';
}
