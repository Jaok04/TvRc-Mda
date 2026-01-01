#!/bin/bash
# ==========================================
#   BOT TELEGRAM JAOK04 (CLEAN VERSION)
#   Generador de Keys Remoto
# ==========================================

# --- CONFIGURACIÓN ---
# Estas variables se llenan automáticamente con el instalador (setup)
# NO LAS CAMBIES AQUÍ MANUALMENTE
TOKEN=""
ADMIN_ID=""

# Rutas del Sistema
DIR_KEYS="/var/www/html/jaok-keys"
# Detectamos la IP automáticamente para enviarte el enlace correcto
MY_IP=$(curl -s ifconfig.me)
URL_BASE_KEYS="http://$MY_IP/jaok-keys"

# Importamos la librería ShellBot (Debe estar en la misma carpeta)
if [[ -e "ShellBot.sh" ]]; then
    source ./ShellBot.sh
else
    echo "❌ Error: ShellBot.sh no encontrado."
    exit 1
fi

# Inicializar Bot
ShellBot.init --token "$TOKEN" --monitor --flush --return map
ShellBot.username

# --- FUNCIONES ---

# 1. Validar que solo TÚ (el Admin) puedas usar el bot
validar_admin() {
    local id_user=${message_from_id[$id]}
    if [[ "$id_user" != "$ADMIN_ID" ]]; then
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
        --text "⛔ ACCESO DENEGADO. Tu ID ($id_user) no está autorizado."
        return 1
    fi
    return 0
}

# 2. Generar la Key y el Archivo
generar_key() {
    local dias=$1
    # IP Temporal (El cliente la validará al instalar)
    local cliente_ip="ESPERANDO-INSTALACION"
    
    # Crear Key Aleatoria (16 Caracteres)
    local key=$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 16 | head -n 1)
    
    # Calcular fecha de vencimiento
    local fecha_exp=$(date -d "+$dias days" +'%Y-%m-%d')
    
    # CREAR EL ARCHIVO EN EL SERVIDOR
    # Si la carpeta no existe, la creamos
    [[ ! -d "$DIR_KEYS" ]] && mkdir -p "$DIR_KEYS"
    
    # Escribimos el archivo: IP|FECHA
    echo "$cliente_ip|$fecha_exp" > "$DIR_KEYS/$key"
    
    # Enviar respuesta bonita a Telegram
    local msj="✅ <b>LICENCIA GENERADA CON ÉXITO</b>\n"
    msj+="━━━━━━━━━━━━━━━━━━\n"
    msj+="🔑 <b>Key:</b> <code>$key</code>\n"
    msj+="📅 <b>Duración:</b> $dias Días\n"
    msj+="📆 <b>Vence:</b> $fecha_exp\n"
    msj+="🔗 <b>URL:</b> $URL_BASE_KEYS/$key\n"
    msj+="━━━━━━━━━━━━━━━━━━\n"
    msj+="<i>Entrégale esta Key a tu cliente. Se activará automáticamente cuando la use.</i>"
    
    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
        --text "$msj" --parse_mode html
}

# 3. Listar Keys Activas
listar_keys() {
    local lista=""
    local count=0
    
    for f in $DIR_KEYS/*; do
        if [[ -f "$f" && "$(basename "$f")" != ".htaccess" ]]; then
            local fname=$(basename "$f")
            local content=$(cat "$f")
            local exp=$(echo "$content" | cut -d'|' -f2)
            lista+="🔹 <code>$fname</code> ($exp)\n"
            ((count++))
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        lista="📭 No hay licencias activas."
    else
        lista="📂 <b>LICENCIAS ACTIVAS ($count):</b>\n\n$lista"
    fi
    
    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
        --text "$lista" --parse_mode html
}

# 4. Eliminar Key
eliminar_key() {
    local key_borrar=$1
    if [[ -e "$DIR_KEYS/$key_borrar" ]]; then
        rm "$DIR_KEYS/$key_borrar"
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "🗑️ Key <b>$key_borrar</b> eliminada correctamente." --parse_mode html
    else
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "⚠️ Esa Key no existe."
    fi
}

# 5. Menú Principal
menu_bot() {
    local msg="🤖 <b>PANEL DE CONTROL JAOK04</b>\n\nBienvenido al generador de licencias privado.\nSeleccione una opción:"
    
    # Definir teclado
    local keyboard='[
        [{"text":"🔑 Generar 7 Dias","callback_data":"/gen 7"},{"text":"🔑 Generar 15 Dias","callback_data":"/gen 15"}],
        [{"text":"🔑 Generar 30 Dias","callback_data":"/gen 30"},{"text":"📋 Ver Lista Keys","callback_data":"/list"}],
        [{"text":"❌ Eliminar una Key","callback_data":"/ask_del"}]
    ]'
    
    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
        --text "$msg" --reply_markup "{\"inline_keyboard\":$keyboard}" --parse_mode html
}

# --- BUCLE PRINCIPAL (ESCUCHA CONSTANTE) ---
echo "🤖 Bot Iniciado y Escuchando..."

while :; do
    ShellBot.getUpdates --limit 100 --offset "$offset" --timeout 30
    
    for id in $(ShellBot.ListUpdates); do
        (
            # Verificamos si es Admin antes de hacer nada
            validar_admin || exit
            
            # --- MANEJO DE COMANDOS (/start, /menu) ---
            if [[ ${message_entities_type[$id]} == bot_command ]]; then
                case ${message_text[$id]} in
                    /start|/menu) 
                        menu_bot 
                        ;;
                    /id) 
                        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "🆔 Tu ID: ${message_from_id[$id]}" 
                        ;;
                esac
            
            # --- MANEJO DE TEXTO (Para borrar keys) ---
            elif [[ ${message_text[$id]} == "borrar "* ]]; then
                 # Si el usuario escribe "borrar XXXXXX"
                 local k_del=$(echo ${message_text[$id]} | awk '{print $2}')
                 eliminar_key "$k_del"

            # --- MANEJO DE BOTONES (CALLBACKS) ---
            elif [[ -n ${callback_query_data[$id]} ]]; then
                cmd=$(echo ${callback_query_data[$id]} | awk '{print $1}')
                arg=$(echo ${callback_query_data[$id]} | awk '{print $2}')
                
                case $cmd in
                    /gen) 
                        # Generamos Key según los días (arg)
                        generar_key "$arg"
                        ;;
                    /list)
                        listar_keys
                        ;;
                    /ask_del)
                        ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
                        --text "⚠️ Para eliminar, escribe:\n<code>borrar LA_KEY</code>" --parse_mode html
                        ;;
                esac
            fi
        ) &
    done
done
