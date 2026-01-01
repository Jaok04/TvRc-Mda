#!/bin/bash

# ==============================================================
#   INSTALADOR JAOK04 - CLIENTE (VALIDACIÓN PUERTO 8888)
# ==============================================================

# --- CONFIGURACIÓN DEL SERVIDOR MAESTRO ---
IP_MAESTRO="162.243.72.91"
# Apuntamos al puerto 8888 donde configuramos Apache
URL_VALIDACION="http://${IP_MAESTRO}:8888/validar.php"

# --- TUS REPOSITORIOS (Archivos del Script) ---
REPO_FILES="https://raw.githubusercontent.com/Jaok04/TvRc-Mda/main/Script-Cgh/Lista_Archivos"
REPO_PACK="https://raw.githubusercontent.com/Jaok04/TvRc-Mda/main/Script-Cgh/pack_new-desofuscado"

SCPdir="/etc/adm-lite"
SCPinstal="$HOME/install"

# Lista de archivos interna (Versión Blindada)
ARCHIVOS_A_DESCARGAR=(
"menu" "PDirect.py" "PGet.py" "POpen.py" "PPriv.py" "PPub.py"
"amd64_user.bin" "arm64_user.bin" "cabecalho" "file.tar"
"menu_credito" "msg" "payloads" "shadowsocks.sh" "ultrahost" "v-local.log"
)

msg() {
    local color=$1
    local text=$2
    case $color in
        -bar3) echo -e "\033[1;33m------------------------------------------------\033[0m" ;;
        -verd) echo -e "\033[1;32m${text}\033[0m" ;;
        -verm) echo -e "\033[1;31m${text}\033[0m" ;;
    esac
}

verificar_arq () {
    [[ ! -d ${SCPdir} ]] && mkdir -p ${SCPdir}
    mv -f ${SCPinstal}/$1 ${SCPdir}/$1 && chmod +x ${SCPdir}/$1
}

downloader_files_mod() {
    [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
    mkdir -p ${SCPinstal}
    
    echo -e " \033[1;33m[DEBUG] Iniciando descarga de componentes...\033[0m"

    # Descargar Pack Principal
    wget -O /root/pack_new "${REPO_PACK}/pack_new"
    chmod +x /root/pack_new

    # Descargar Archivos de la Lista
    for arqx in "${ARCHIVOS_A_DESCARGAR[@]}"; do
        echo -ne " -> Bajando $arqx... "
        wget --no-check-certificate -O ${SCPinstal}/${arqx} "${REPO_FILES}/${arqx}" &>/dev/null
        if [[ -s ${SCPinstal}/${arqx} ]]; then
            echo -e "\033[1;32m[OK]\033[0m"
            verificar_arq "${arqx}"
        else
            echo -e "\033[1;31m[FALLÓ]\033[0m"
        fi
    done
    
    # Descompresión de binarios
    tar -xf ${SCPdir}/file.tar -C ${SCPdir} &>/dev/null
}

funkey () {
    clear
    msg -bar3
    echo -e "          \033[1;41m  INSTALADOR OFICIAL JAOK04  \033[0m"
    msg -bar3
    echo -ne " \033[1;32mINGRESE SU KEY DE INSTALACIÓN: \033[0m"
    read -p "" user_key

    if [[ -z "$user_key" ]]; then
        msg -verm " [!] La Key no puede estar vacía."
        exit 1
    fi

    # CONSULTA AL PORTERO (validar.php en puerto 8888)
    echo -e " \033[1;33m[Verificando licencia en servidor maestro...]\033[0m"
    respuesta=$(curl -s --connect-timeout 10 "${URL_VALIDACION}?key=${user_key}")

    if [[ "$respuesta" == "AUTORIZADO" ]]; then
        msg -bar3
        msg -verd " [✔] LICENCIA VALIDADA Y BLOQUEADA A ESTA IP"
        msg -bar3
        
        downloader_files_mod
        
        export IiP="$(curl -s ifconfig.me)"
        source /root/pack_new
    
    elif [[ "$respuesta" == "EXPIRADA" ]]; then
        msg -verm " [!] ERROR: La Key ha vencido. Contacte a JAOK04."
        exit 1
    elif [[ "$respuesta" == "IP-INCORRECTA" ]]; then
        msg -verm " [!] ERROR: Esta Key ya está asociada a otra IP."
        exit 1
    elif [[ "$respuesta" == "INVALIDA" ]]; then
        msg -verm " [!] ERROR: Key no encontrada en la base de datos."
        exit 1
    else
        msg -verm " [!] ERROR: Servidor de licencias fuera de línea."
        echo " Respuesta: $respuesta"
        exit 1
    fi
}

# Inicio del proceso
funkey
