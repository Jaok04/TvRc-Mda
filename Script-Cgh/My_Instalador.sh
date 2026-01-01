#!/bin/bash
# ==============================================================
#   INSTALADOR OFICIAL JAOK04 - CRÉDITOS DINÁMICOS V3
# ==============================================================

IP_MAESTRO="162.243.72.91"
URL_VALIDACION="http://${IP_MAESTRO}:8888/validar.php"

# RUTAS DE TU GITHUB
REPO_FILES="https://raw.githubusercontent.com/Jaok04/TvRc-Mda/main/Script-Cgh/Lista_Archivos"
REPO_PACK="https://raw.githubusercontent.com/Jaok04/TvRc-Mda/main/Script-Cgh/pack_new-desofuscado"

SCPdir="/etc/adm-lite"
SCPinstal="$HOME/install"

# Lista completa de tus archivos necesarios
ARCHIVOS_A_DESCARGAR=(
"menu" "PDirect.py" "PGet.py" "POpen.py" "PPriv.py" "PPub.py"
"amd64_user.bin" "arm64_user.bin" "cabecalho" "file.tar"
"msg" "payloads" "shadowsocks.sh" "ultrahost" "v-local.log"
)

verificar_arq () {
    [[ ! -d ${SCPdir} ]] && mkdir -p ${SCPdir}
    mv -f ${SCPinstal}/$1 ${SCPdir}/$1 && chmod +x ${SCPdir}/$1
}

downloader_files_mod() {
    [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
    mkdir -p ${SCPinstal}
    
    echo -e "\033[1;33m [⚙️] Descargando componentes del sistema...\033[0m"

    # 1. Descargar Pack de Configuración Final
    wget -qO /root/pack_new "${REPO_PACK}/pack_new"
    chmod +x /root/pack_new

    # 2. Descargar cada archivo de la lista
    for arqx in "${ARCHIVOS_A_DESCARGAR[@]}"; do
        echo -ne "  > Descargando $arqx... "
        wget --no-check-certificate -qO ${SCPinstal}/${arqx} "${REPO_FILES}/${arqx}"
        if [[ -s ${SCPinstal}/${arqx} ]]; then
            echo -e "\033[1;32m[OK]\033[0m"
            verificar_arq "${arqx}"
        else
            echo -e "\033[1;31m[FALLO]\033[0m"
        fi
    done
    
    # 3. Descomprimir binarios
    if [[ -f "${SCPdir}/file.tar" ]]; then
        tar -xf ${SCPdir}/file.tar -C ${SCPdir} &>/dev/null
    fi
}

funkey () {
    clear
    echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "          \033[1;44m  SISTEMA DE INSTALACIÓN JAOK04  \033[0m"
    echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    
    echo -ne "\033[1;32m INGRESE SU LICENCIA (KEY): \033[0m"
    read user_key

    if [[ -z "$user_key" ]]; then
        echo -e "\033[1;31m [!] Error: La Key es obligatoria.\033[0m"
        exit 1
    fi

    # CONSULTA AL VALIDADOR PHP
    respuesta=$(curl -s --connect-timeout 10 "${URL_VALIDACION}?key=${user_key}")

    # Separamos la respuesta: ESTADO|VENDEDOR
    status=$(echo "$respuesta" | cut -d'|' -f1)
    vendedor=$(echo "$respuesta" | cut -d'|' -f2)

    if [[ "$status" == "AUTORIZADO" ]]; then
        echo -e "\n\033[1;32m [✔] LICENCIA ACEPTADA POR: $vendedor \033[0m"
        echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        
        # EXPORTAMOS VARIABLES PARA EL PACK_NEW
        export BY_USER="$vendedor"
        export IiP="$(curl -s ifconfig.me)"
        
        # Iniciamos la descarga de archivos
        downloader_files_mod
        
        # Ejecutamos el configurador final
        source /root/pack_new
    else
        echo -e "\n\033[1;31m [!] ERROR: $status \033[0m"
        exit 1
    fi
}

funkey
