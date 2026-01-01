#!/bin/bash

# ==============================================================
#   MODIFICACIÓN: JAOK04 - BYPASS & REPO PRIVADO
#   ESTADO: Key Check Simulado + Descarga Github
# ==============================================================

# --- TUS REPOSITORIOS (Configurados Exactamente) ---
REPO_FILES="https://raw.githubusercontent.com/Jaok04/TvRc-Mda/refs/heads/main/Script-Cgh"
REPO_PACK="https://raw.githubusercontent.com/Jaok04/TvRc-Mda/refs/heads/main/Script-Cgh/pack_new-desofuscado"

set -o pipefail
killall apt apt-get &> /dev/null
export DEBIAN_FRONTEND=noninteractive
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games/

# Directorios de instalación
SCPdir="/etc/adm-lite"
SCPinstal="$HOME/install"

# --- FUNCIONES VISUALES ---
msg() {
    local color=$1
    local text=$2
    case $color in
        -bar3) echo -e "\033[1;33m------------------------------------------------\033[0m" ;;
        -verm) echo -e "\033[1;31m${text}\033[0m" ;;
        -verd) echo -e "\033[1;32m${text}\033[0m" ;;
        -ama)  echo -e "\033[1;33m${text}\033[0m" ;;
        -ne)   echo -ne "${text}" ;;
    esac
}

print_center() {
    local x
    local y
    text="$*"
    x=$(( ($(tput cols) - ${#text}) / 2))
    echo -ne "\E[6n";read -sdR y; y=$(echo -ne "${y#*[}" | cut -d';' -f1)
    echo -ne "\033[${y};${x}f$*"
}

# --- PREPARACIÓN DEL SISTEMA ---
update_pak () {
    clear&&clear
    msg -bar3
    [[ $(dpkg --get-selections|grep -w "pv"|head -1) ]] || apt install pv -y &> /dev/null
    [[ $(dpkg --get-selections|grep -w "bzip2"|head -1) ]] || apt install bzip2 -y &> /dev/null
    
    # Detección de sistema
    system=$(cat -n /etc/issue |grep 1 |cut -d ' ' -f6,7,8 |sed 's/1//' |sed 's/      //')
    distro=$(echo "$system"|awk '{print $1}')
    
    print_center "		[ ! ]  ESPERE UN MOMENTO  [ ! ]"
    [[ $(dpkg --get-selections|grep -w "lolcat"|head -1) ]] || apt-get -qq install lolcat -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "figlet"|head -1) ]] || apt-get -qq install figlet -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "curl"|head -1) ]] || apt-get -qq install curl -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "wget"|head -1) ]] || apt-get -qq install wget -y &>/dev/null
    
    echo ""
    msg -bar3
    echo -e "\e[1;31m  SISTEMA:  \e[33m$distro \e[1;31m	CPU:  \e[33m$(lscpu | grep "Vendor ID" | awk '{print $3}'|head -1)"
    msg -bar3
    echo -e "\033[94m    INTENTANDO RECONFIGURAR UPDATER " | pv -qL 80
    msg -bar3
    echo -e "\033[94m    UPDATE DATE : $(date +"%d/%m/%Y") & TIME : $(date +"%H:%M") " | pv -qL 80
    msg -bar3
    echo -e "\033[94m    PREPARANDO BASE RAPIDA INSTALL    " | pv -qL 80
    msg -bar3
    echo -e "\033[94m    CHECK IP FIJA $(curl -fsSL ifconfig.me)    " | pv -qL 80
    msg -bar3
    echo " "
    sleep 2
    clear&&clear
}

# --- ANIMACIÓN DE CARGA ---
helice() {
    tput civis
    # Ejecutamos la descarga en segundo plano mientras gira la hélice
    downloader_files_mod & 
    PID=$!
    while [ -d /proc/$PID ]; do
        for i in / - \\ \|; do
            sleep .1
            echo -ne "\e[1D$i"
        done
    done
    tput cnorm
}

verificar_arq () {
    [[ ! -d ${SCPdir} ]] && mkdir ${SCPdir}
    mv -f ${SCPinstal}/$1 ${SCPdir}/$1 && chmod +x ${SCPdir}/$1
}

# --- LÓGICA DE DESCARGA (BYPASS) ---
downloader_files_mod() {
    # 1. Limpieza y preparación
    [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
    mkdir -p ${SCPinstal}
    
    # 2. Descargar la LISTA MAESTRA de tu Repo
    wget -q -O ${SCPinstal}/lista-arq "${REPO_FILES}/lista-arq"
    
    # 3. Descargar el PACK_NEW MODIFICADO de tu Repo
    wget -q -O /root/pack_new "${REPO_PACK}/pack_new"
    chmod +x /root/pack_new

    # 4. Descargar archivos del panel
    if [[ -s ${SCPinstal}/lista-arq ]]; then
        for arqx in $(cat ${SCPinstal}/lista-arq); do
            # Descargar cada archivo ignorando certificados
            wget -q --no-check-certificate -O ${SCPinstal}/${arqx} "${REPO_FILES}/${arqx}"
            if [[ -s ${SCPinstal}/${arqx} ]]; then
                verificar_arq "${arqx}"
            fi
        done
        
        # Descomprimir file.tar si existe (CRÍTICO para los binarios)
        if [[ -e ${SCPdir}/file.tar ]]; then
             tar -xf ${SCPdir}/file.tar -C ${SCPdir}
        fi
    fi
}

# --- FUNCIÓN PRINCIPAL DE INSTALACIÓN (SIMULADA) ---
funkey () {
    clear
    [[ $(uname -m 2> /dev/null) != x86_64 ]] && cpu_model=" ARM64 Pro" || cpu_model=$(lscpu | grep "Vendor ID" | awk '{print $3}'|head -1)
    _sys="$(lsb_release -si)-$(lsb_release -sr)"
    
    # Banners originales
    msg -bar3
    echo -e "   \033[41m- CPU: \033[100m${cpu_model}\033[41m SISTEMA : \033[100m${_sys}\033[41m -\033[0m"
    msg -bar3
    print_center "$(curl -fsSL ifconfig.me)"
    msg -bar3
    echo -e "  ADMcgh+ 2025 | @ChumoGH OFICIAL 2025   -" | lolcat
    msg -bar3
    figlet ' . ADMcgh . ' | boxes -d stone -p a0v0 | lolcat
    echo "           INSTALADOR BYPASS (JAOK04 REPO) " | lolcat
    msg -bar3
    
    # Simulación de verificación de Key
    echo -ne " \033[1;41m Key : \033[0;33m"
    echo -e " BYPASS-ACTIVADO-JAOK04-MOD-2025" 
    sleep 1s
    
    msg -bar3
    echo -ne " \e[90m\e[43m CHEK KEY : \033[0;33m"
    echo -e " \e[3;32m ENLAZADA AL GENERADOR\e[0m" | pv -qL 50
    echo -ne " \033[1;41m ESTATUS : \033[0;33m"
    echo -e "\033[1;34m [ \e[3;32m VALIDANDO CONEXION \e[0m \033[1;34m]\033[0m"
    sleep 1s
    echo -e "\033[1;34m [ \e[3;32m DONE \e[0m \033[1;34m]\033[0m"
    
    # Iniciar Descarga Visual
    tput cuu1 && tput dl1
    echo -ne "\033[1;37m DESCARGANDO RECURSOS \033[1;32mGITHUB \033[1;32m.\033[1;33m.\033[1;31m. \033[1;33m"
    helice # Llama a downloader_files_mod en segundo plano
    echo -e "\e[1DOk"
    
    msg -bar3
    
    # Ejecución del pack_new (Motor de instalación)
    echo -e " \033[1;32m EJECUTANDO PACK_NEW (VERSIÓN LIMPIA)...\033[0m"
    sleep 2
    
    if [[ -s /root/pack_new ]]; then
        # Ejecutamos el pack_new para que configure todo lo demás
        source /root/pack_new
    else
        echo -e "\033[1;31m ERROR CRÍTICO: pack_new no se descargó correctamente.\033[0m"
        echo -e "Verifica la URL: $REPO_PACK/pack_new"
        exit 1
    fi

    # Finalización
    rm -f setup* lista*
    echo -e " TIEMPO DE EJECUCION $((($(date +%s)-$TIME_START)/60)) min."
    msg -bar3
    echo -e "INSTALL COMPLETED! WRITE menu"
    read -p " PRESIONA ENTER PARA FINALIZAR"
    [[ -e "$(which menu)" ]] && menu
}

# --- INICIO DEL SCRIPT ---
TIME_START="$(date +%s)"
[[ -e /etc/PACKAGE ]] || update_pak
funkey
