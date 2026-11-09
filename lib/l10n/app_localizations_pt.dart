// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'FootCraft';

  @override
  String get bank => 'Banco';

  @override
  String bankPedal(int bank, int pedal) {
    return 'Banco $bank · Pedal $pedal';
  }

  @override
  String banksRange(int from, int to) {
    return 'Bancos $from a $to';
  }

  @override
  String pedalsRange(int from, int to) {
    return 'Pedais $from a $to';
  }

  @override
  String batchApplied(int count) {
    return '$count pedais programados. Dá para desfazer.';
  }

  @override
  String batchApply(int count) {
    return 'Aplicar em $count pedais';
  }

  @override
  String get batchTitle => 'Programar vários';

  @override
  String get boardHint =>
      'Toque num pedal para editar. Toque longo (ou botão direito) para copiar, colar ou silenciar. As mudanças só vão para a FCB quando você toca em Enviar para a FCB.';

  @override
  String get calibrationNote =>
      'A calibração dos pedais de expressão é feita na própria FCB e é preservada como está.';

  @override
  String get cancel => 'Cancelar';

  @override
  String channelN(int n) {
    return 'Canal $n';
  }

  @override
  String get clear => 'Limpar';

  @override
  String get close => 'Fechar';

  @override
  String get connect => 'Conectar';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get controlChanges => 'Control Change';

  @override
  String get controlChangesHint =>
      'Mensagens CC fixas mandadas ao pisar no pedal: número do controle e valor.';

  @override
  String get controller => 'CC';

  @override
  String get copy => 'Copiar';

  @override
  String get copyBank => 'Copiar banco';

  @override
  String get copyPedal => 'Copiar pedal';

  @override
  String get pastePedal => 'Colar pedal';

  @override
  String get silencePedal => 'Silenciar pedal';

  @override
  String get silencePedalHint =>
      'Desliga trocas de programa, CCs, nota e relés (os pedais de expressão ficam).';

  @override
  String get directSelect => 'Seleção direta';

  @override
  String get directSelectHint =>
      'Os pedais 1–10 escolhem o banco e depois o preset, sem usar UP/DOWN.';

  @override
  String get runningStatus => 'Running status';

  @override
  String get runningStatusHint =>
      'Omite o byte de status repetido. Desligue se algum aparelho estranhar as mensagens.';

  @override
  String get merge => 'Merge (MIDI IN → OUT)';

  @override
  String get mergeHint =>
      'Repassa para a saída da FCB o que chega na entrada MIDI dela.';

  @override
  String get upTogglesRelay1 => 'UP liga/desliga o relé 1';

  @override
  String get downTogglesRelay2 => 'DOWN liga/desliga o relé 2';

  @override
  String get relayKeysHint => 'Vale quando a seleção direta está ligada.';

  @override
  String expressionN(String name) {
    return 'Expressão $name';
  }

  @override
  String get expressionPedals => 'Pedais de expressão';

  @override
  String get expressionPedalsHint =>
      'O CC que cada pedal de expressão manda neste preset, entre o mínimo e o máximo.';

  @override
  String get factoryVAmp => 'V-AMP (padrão de fábrica)';

  @override
  String get factoryGuitarAmps => 'Amplificadores Behringer';

  @override
  String get factoryBassVAmp => 'Bass V-AMP';

  @override
  String factoryNamed(String name) {
    return 'Fábrica: $name';
  }

  @override
  String get newFromFactory => 'Começar da configuração de fábrica:';

  @override
  String fileOpened(String name) {
    return 'Arquivo aberto: $name';
  }

  @override
  String fileSaved(String path) {
    return 'Salvo em $path';
  }

  @override
  String notAnFcbFile(String name) {
    return '$name não é um dump da FCB1010.';
  }

  @override
  String get globalSettings => 'Configurações globais';

  @override
  String get inputFromFcb => 'Entrada (vem da FCB)';

  @override
  String get outputToFcb => 'Saída (vai para a FCB)';

  @override
  String get maximum => 'Máx';

  @override
  String get minimum => 'Mín';

  @override
  String get midiChannels => 'Canais MIDI';

  @override
  String get midiChannelsHint =>
      'Canal de cada tipo de mensagem, para todos os presets.';

  @override
  String get sameChannelForAll => 'Usar o mesmo canal para tudo';

  @override
  String get operation => 'Funcionamento';

  @override
  String get midiMonitor => 'Monitor MIDI';

  @override
  String get midiMonitorHint =>
      'O que chega da FCB. Pise nos pedais para conferir.';

  @override
  String get monitorEmpty => 'Nada recebido ainda.';

  @override
  String monitorSysex(int count) {
    return 'SysEx de $count bytes';
  }

  @override
  String get midiPorts => 'Portas MIDI';

  @override
  String get midiPortsHint =>
      'Escolha a interface MIDI ligada à FCB1010: a entrada recebe o que a FCB manda e a saída leva até ela.';

  @override
  String get noPorts =>
      'Nenhuma porta MIDI encontrada. Ligue a interface USB-MIDI e toque em Atualizar.';

  @override
  String get notConnected => 'Sem conexão MIDI';

  @override
  String get refresh => 'Atualizar';

  @override
  String get modeKeep => 'Manter';

  @override
  String get modeOff => 'Desligar';

  @override
  String get modeOn => 'Ligar';

  @override
  String get modeFixed => 'Fixo';

  @override
  String get modeSequence => 'Sequência';

  @override
  String get valueFixed => 'Valor fixo';

  @override
  String get valueSequence => 'Valor em sequência';

  @override
  String get startAt => 'Começa em';

  @override
  String get step => 'Passo';

  @override
  String get value => 'Valor';

  @override
  String get program => 'Programa';

  @override
  String get modified => 'alterada';

  @override
  String get nextBank => 'Próximo banco';

  @override
  String get previousBank => 'Banco anterior';

  @override
  String get nextPedal => 'Próximo pedal';

  @override
  String get previousPedal => 'Pedal anterior';

  @override
  String get noPedalsChosen => 'Nenhum pedal escolhido.';

  @override
  String get note => 'Nota';

  @override
  String get noteSection => 'Nota';

  @override
  String get noteHint => 'Nota MIDI mandada ao pisar (60 = C4).';

  @override
  String get openFile => 'Abrir arquivo .syx';

  @override
  String get saveFile => 'Salvar arquivo .syx';

  @override
  String get openInEditor => 'Abrir no editor';

  @override
  String pedalCount(int count) {
    return '$count pedais';
  }

  @override
  String get whichPedals => 'Quais pedais';

  @override
  String get scopeAll => 'Todos os 100';

  @override
  String scopeCurrentBank(int bank) {
    return 'Só o banco $bank';
  }

  @override
  String get preview => 'Como vai ficar';

  @override
  String get programChanges => 'Program Change';

  @override
  String get programChangesHint =>
      'Até 5 trocas de programa por pedal, cada uma no seu canal (configurações globais).';

  @override
  String get receiveFromFcb => 'Receber da FCB';

  @override
  String get sendToFcb => 'Enviar para a FCB';

  @override
  String get receiveTitle => 'Receber da FCB1010';

  @override
  String get sendTitle => 'Enviar para a FCB1010';

  @override
  String get stepPowerDown =>
      'Ligue a FCB segurando o pedal DOWN por uns 2 segundos.';

  @override
  String get stepConfiguration =>
      'Pressione UP até acender o LED CONFIGURATION.';

  @override
  String get stepSysexSend => 'Pise no pedal 6 (SYSEX SEND).';

  @override
  String get stepSysexRcv => 'Pise no pedal 7 (SYSEX RCV): o LED dele acende.';

  @override
  String get stepPressSend =>
      'Toque em Enviar agora. Quando o LED do pedal 7 apagar, saia com um toque longo em DOWN.';

  @override
  String get waitingDump => 'Esperando a FCB mandar…';

  @override
  String receiving(int done, int total) {
    return 'Recebendo: $done de $total bytes';
  }

  @override
  String get receivedDump => 'Configuração recebida!';

  @override
  String receivedIncomplete(int count) {
    return 'Chegou um SysEx da Behringer incompleto ($count bytes). Tente de novo.';
  }

  @override
  String get receiveNote =>
      'Uma cópia do que chegar fica guardada em Documentos/FootCraft/backups.';

  @override
  String receivedAt(String when) {
    return 'Recebido da FCB em $when';
  }

  @override
  String receivedOk(String path) {
    return 'Configuração da FCB aberta. Cópia em $path';
  }

  @override
  String get sendWarning =>
      'Isto substitui os 100 presets e as configurações globais da FCB. Se quiser uma cópia do que está nela, use Receber da FCB antes.';

  @override
  String get sendNow => 'Enviar agora';

  @override
  String get sending => 'Enviando…';

  @override
  String get sentCheckLed =>
      'Enviado! Confira se o LED do pedal 7 apagou e saia da configuração com um toque longo em DOWN. Se o LED continuar aceso, a FCB não recebeu: refaça os passos 1 a 3.';

  @override
  String sendFailed(String error) {
    return 'Não foi possível enviar: $error';
  }

  @override
  String get sendsNothing => 'não manda nada';

  @override
  String get recipes => 'Receitas prontas';

  @override
  String get recipeOneCc => 'Um CC por pedal';

  @override
  String get recipeOneCcHint =>
      'Cada pedal manda só este CC, com valores 1, 2, 3… em ordem. Fácil de mapear em outros apps.';

  @override
  String get recipeProgram => 'Program Change por pedal';

  @override
  String get recipeProgramHint =>
      'Cada pedal troca para o programa 0, 1, 2… em ordem.';

  @override
  String get recipeClear => 'Recomeçar';

  @override
  String get redo => 'Refazer';

  @override
  String get undo => 'Desfazer';

  @override
  String relayN(int n) {
    return 'Relé $n';
  }

  @override
  String get relays => 'Relés (SWITCH 1 e 2)';

  @override
  String get relaysHint =>
      'Os contatos de relé na traseira da FCB, para trocar canal de amplificador.';

  @override
  String get replace => 'Substituir';

  @override
  String get replaceTitle => 'Substituir a configuração aberta?';

  @override
  String get replaceBody =>
      'Há mudanças que não foram enviadas nem salvas. Dá para voltar com Desfazer.';

  @override
  String get use => 'Usar';

  @override
  String get testMode => 'Modo de teste';

  @override
  String get testModeStop => 'Parar';

  @override
  String get testModeHint =>
      'Com a FCB fora da configuração, pise nos pedais: o app mostra qual foi reconhecido, pelo que ele mandou.';

  @override
  String get testWaiting => 'Esperando um pedal…';

  @override
  String testPressed(String pedal) {
    return 'Pisado: $pedal';
  }

  @override
  String testAmbiguous(int count) {
    return '(mais $count pedais mandam o mesmo)';
  }

  @override
  String testUnmatched(String messages) {
    return 'Nenhum pedal desta configuração manda isso: $messages. A FCB pode estar com outra programação.';
  }
}
