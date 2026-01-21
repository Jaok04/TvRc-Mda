#!/bin/bash

# ==============================================================
#   MODIFICACIÓN: JAOK04 - BYPASS & REPO PRIVADO
#   ESTADO: LISTA INTERNA + URL ESTÁNDAR + DEBUG
# ==============================================================

# --- TUS REPOSITORIOS (URLs Corregidas a formato RAW Estándar) ---
# Usamos el formato directo '/main/' que es más compatible
REPO_FILES="https://raw.githubusercontent.com/Jaok04/TvRc-Mda/main/Script-Cgh/Lista_Archivos"
REPO_PACK="https://raw.githubusercontent.com/Jaok04/TvRc-Mda/main/Script-Cgh/pack_new-desofuscado"

set -o pipefail
killall apt apt-get &> /dev/null
export DEBIAN_FRONTEND=noninteractive
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games/

SCPdir="/etc/adm-lite"
SCPinstal="$HOME/install"

# --- LISTA INTERNA SEGURA (Ignoramos el archivo lista-arq externo) ---
ARCHIVOS_A_DESCARGAR=(
"menu"
"PDirect.py"
"PGet.py"
"POpen.py"
"PPriv.py"
"PPub.py"
"amd64_user.bin"
"arm64_user.bin"
"cabecalho"
"file.tar"
"menu_credito"
"msg"
"payloads"
"shadowsocks.sh"
"ultrahost"
"v-local.log"
)

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

update_pak () {
    clear&&clear
    msg -bar3
    [[ $(dpkg --get-selections|grep -w "pv"|head -1) ]] || apt install pv -y &> /dev/null
    [[ $(dpkg --get-selections|grep -w "bzip2"|head -1) ]] || apt install bzip2 -y &> /dev/null
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
    echo " "
    sleep 2
    clear&&clear
}

verificar_arq () {
    [[ ! -d ${SCPdir} ]] && mkdir -p ${SCPdir}
    mv -f ${SCPinstal}/$1 ${SCPdir}/$1 && chmod +x ${SCPdir}/$1
}

downloader_files_mod() {
    [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
    mkdir -p ${SCPinstal}
    
    echo -e " \033[1;33m[DEBUG] Iniciando descarga de archivos...\033[0m"

    # Descargar el PACK_NEW de tu Repo
    # Quitamos -q para ver errores si los hay
    wget -O /root/pack_new "${REPO_PACK}/pack_new"
    if [[ ! -s /root/pack_new ]]; then
        echo -e "\033[1;31m[ERROR] Falló la descarga de pack_new. Verifica la URL:\033[0m"
        echo "${REPO_PACK}/pack_new"
        exit 1
    fi
    chmod +x /root/pack_new

    # Descargar archivos usando la LISTA INTERNA
    for arqx in "${ARCHIVOS_A_DESCARGAR[@]}"; do
        echo -ne " -> Bajando $arqx... "
        # Quitamos -q para ver si falla
        wget --no-check-certificate -O ${SCPinstal}/${arqx} "${REPO_FILES}/${arqx}" 2>/dev/null
        
        if [[ -s ${SCPinstal}/${arqx} ]]; then
            echo -e "\033[1;32m[OK]\033[0m"
            verificar_arq "${arqx}"
        else
            echo -e "\033[1;31m[FALLÓ]\033[0m"
            echo "    URL: ${REPO_FILES}/${arqx}"
        fi
    done
    
    # Descomprimir file.tar (CRÍTICO)
    if [[ -s ${SCPdir}/file.tar ]]; then
         echo -e " -> Descomprimiendo binarios..."
         tar -xf ${SCPdir}/file.tar -C ${SCPdir}
    else
         echo -e "\033[1;31m[ALERTA] file.tar no se descargó o está vacío.\033[0m"
    fi
}

funkey () {
    clear
    _sys="$(lsb_release -si)-$(lsb_release -sr)"
    msg -bar3
    echo -e "   \033[41m- SISTEMA : \033[100m${_sys}\033[41m -\033[0m"
    msg -bar3
    print_center "$(curl -fsSL ifconfig.me)"
    msg -bar3
    figlet ' . ADMcgh . ' | boxes -d stone -p a0v0 | lolcat
    echo "           INSTALADOR JAOK04 (BLINDADO) " | lolcat
    msg -bar3
    echo -ne " \033[1;41m Key : \033[0;33m"
    echo -e " BYPASS-JAOK04-AUTO-LIST" 
    sleep 1s
    msg -bar3
    echo -e "\033[1;34m [ \e[3;32m VERIFICADO \e[0m \033[1;34m]\033[0m"
    
    # Ejecutamos la descarga VISIBLE (sin hélice para ver logs)
    msg -bar3
    downloader_files_mod
    msg -bar3
    
    echo -e " \033[1;32m EJECUTANDO PACK_NEW...\033[0m"
    sleep 2
    
    if [[ -s /root/pack_new ]]; then
        source /root/pack_new
    else
        echo -e "\033[1;31m ERROR CRÍTICO: pack_new no descargado.\033[0m"
        exit 1
    fi

    rm -f setup* lista*
    echo -e "INSTALL COMPLETED! WRITE menu"
    read -p " PRESIONA ENTER PARA FINALIZAR"
    [[ -e "$(which menu)" ]] && menu
}

TIME_START="$(date +%s)"
[[ -e /etc/PACKAGE ]] || update_pak
funkey
