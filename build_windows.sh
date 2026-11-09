#!/bin/bash
# Compila este projeto pra Windows dentro da VM WinBoat e copia os
# binários pra "/mnt/BKP/Binários Windows/<projeto>/". Requer o WinBoat
# aberto e rodando. Lógica real em ~/.config/windows-build/common.sh
# (fora do repo de propósito).
source ~/.config/windows-build/common.sh
build_windows_project "$(dirname "$(readlink -f "$0")")"
