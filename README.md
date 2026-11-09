# FootCraft

Editor para a controladora MIDI **Behringer FCB1010** (firmware original), para
Linux, Android e Windows.

- Recebe o dump SysEx da FCB (pedal 6, SYSEX SEND) e envia de volta (pedal 7,
  SYSEX RCV), com os passos na tela.
- Edita pedal por pedal: 5 Program Change, 2 Control Change, nota, relés e os
  dois pedais de expressão.
- Programa vários pedais de uma vez (manter, desligar, valor fixo ou em
  sequência), com receitas prontas como "um CC por pedal".
- Configurações globais: canais MIDI, seleção direta, running status, merge.
- Abre e salva arquivos `.syx`; guarda cópia de tudo que vem da FCB em
  `Documentos/FootCraft/backups`.

## Estrutura

- `lib/fcb/fcb_sysex.dart`: formato do dump (2352 bytes, pacotes de 7 bits).
  Edita só os bytes conhecidos e preserva o resto.
- `lib/fcb/batch.dart`: programação em lote.
- `rust/src/api/midi.rs`: portas MIDI pelo `midir` (mesma cópia com correção
  para Android usada no Guitarrero e no GigFlow).
- `test/`: o formato é conferido contra dumps reais (backup de uma FCB e o
  arquivo gravado nela) e contra as configurações de fábrica.

O formato vem de engenharia reversa da comunidade: fcbtool (Jason March, MIT,
a partir do trabalho de Brian Walton) e o editor fcb1010.online. As
configurações de fábrica em `assets/factory` vêm do fcbtool.
