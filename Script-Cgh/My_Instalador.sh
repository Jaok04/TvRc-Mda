#!/bin/bash

# ==============================================================
#   INSTALADOR OFICIAL JAOK04 - SISTEMA DE VALIDACIÓN V3
# ==============================================================

# --- CONFIGURACIÓN DEL SERVIDOR MAESTRO ---
IP_MAESTRO="162.243.72.91"
# Puerto 8888 configurado para Apache (Evita conflictos con Nginx/Panel)
URL_VALIDACION="http://${IP_MAESTRO}:8888/validar.php"

# --- TUS REPOSITORIOS (Asegúrate que estas URLs existan en tu GitHub) ---
REPO_FILES="https://raw.githubusercontent.com/Jaok04/TvRc-Mda/main/Script-Cgh/Lista_Archivos"
REPO_PACK="https://raw.githubusercontent.com/Jaok04/TvRc-Mda/main/Script-Cgh/pack_new-desofuscado"

SCPdir="/etc/adm-lite"
SCPinstal="$HOME/install"

# Lista de archivos que el script descargará
ARCHIVOS_A_DESCARGAR=(
"menu" "PDirect.py" "PGet.py" "POpen.py" "PPriv.py" "PPub.py"
"amd64_user.bin" "arm64_user.bin" "cabecalho" "file.tar"
"msg" "payloads" "shadowsocks.sh" "ultrahost" "v-local.log"
)

msg() {
    local color=$1
    local text=$2
    case $color in
        -bar) echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" ;;
        -verd) echo -e "\033[1;32m${text}\033[0m" ;;
        -verm) echo -e "\033[1;31m${text}\033[0m" ;;
        -ama)  echo -e "\033[1;33m${text}\033[0m" ;;
    esac
}

# Mover archivos a la ruta final y dar permisos
verificar_arq () {
    [[ ! -d ${SCPdir} ]] && mkdir -p ${SCPdir}
    mv -f ${SCPinstal}/$1 ${SCPdir}/$1 && chmod +x ${SCPdir}/$1
}

downloader_files_mod() {
    [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
    mkdir -p ${SCPinstal}
    
    msg -ama " [⚙️] Descargando componentes del sistema..."

    # 1. Descargar Pack de Configuración Final
    wget -qO /root/pack_new "${REPO_PACK}/pack_new"
    chmod +x /root/pack_new

    # 2. Descargar Archivos Base
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
    
    # 3. Descomprimir binarios si existen
    if [[ -f "${SCPdir}/file.tar" ]]; then
        tar -xf ${SCPdir}/file.tar -C ${SCPdir} &>/dev/null
    fi
}

funkey () {
    clear
    msg -bar
    echo -e "          \033[1;44m  SISTEMA DE INSTALACIÓN JAOK04  \033[0m"
    msg -bar
    echo -e " \033[1;33mVerificando estado del servidor maestro...\033[0m"
    
    # Solicitar Key
    echo -ne " \033[1;32mINGRESE SU LICENCIA (KEY): \033[0m"
    read user_key

    if [[ -z "$user_key" ]]; then
        msg -verm " [!] Error: La Key es obligatoria."
        exit 1
    fi

    # --- CONSULTA AL VALIDADOR PHP ---
    # Enviamos la Key y el servidor responde: AUTORIZADO, INVALIDA, EXPIRADA o IP-INCORRECTA
    respuesta=$(curl -s --connect-timeout 10 "${URL_VALIDACION}?key=${user_key}")

    if [[ "$respuesta" == "AUTORIZADO" ]]; then
        msg -bar
        msg -verd " [✔] LICENCIA VALIDADA EXITOSAMENTE"
        msg -bar
        
        # Iniciar descarga
        downloader_files_mod
        
        # Exportar IP para que pack_new sepa que la validación es real
        export IiP="$(curl -s ifconfig.me)"
        
        # Ejecutar el configurador final
        source /root/pack_new
    
    elif [[ "$respuesta" == "EXPIRADA" ]]; then
        msg -verm " [!] ERROR: Esta licencia ha caducado."
        exit 1
    elif [[ "$respuesta" == "IP-INCORRECTA" ]]; then
        msg -verm " [!] ERROR: Esta Key ya está vinculada a otro servidor."
        exit 1
    elif [[ "$respuesta" == "INVALIDA" ]]; then
        msg -verm " [!] ERROR: Key no encontrada o incorrecta."
        exit 1
    else
        msg -verm " [!] ERROR: No se pudo conectar con el servidor de licencias."
        echo " Detalle: $respuesta"
        exit 1
    fi
}

# Ejecutar el proceso
funkey
