#!/bin/bash
# INSTALADOR DE BOT JAOK04
# Sin Dropbox - Sin Backdoors

# TUS RUTAS (Actualizadas a Control_bot sin extensión)
REPO="https://raw.githubusercontent.com/Jaok04/TvRc-Mda/main/Script-Cgh/Bot_Files"
IP_CONTROL="https://raw.githubusercontent.com/Jaok04/TvRc-Mda/main/Script-Cgh/Bot_Files/Control_bot"

# Instalación de paquetes
apt update
apt install -y jq screen apache2 bc curl wget

# Crear directorios
mkdir -p /etc/jaok-bot
cd /etc/jaok-bot

# 1. VERIFICAR CONTROL IP (Tu requerimiento)
MY_IP=$(curl -s ifconfig.me)
# Descargamos el archivo y buscamos la IP dentro
if curl -s "$IP_CONTROL" | grep -q "$MY_IP"; then
    echo "✅ IP AUTORIZADA POR EL REPO DE JAOK04"
else
    echo "❌ ERROR: Tu IP ($MY_IP) no está en el archivo Control_bot"
    exit 1
fi

# 2. DESCARGAR ARCHIVOS LIMPIOS
echo "Descargando ShellBot..."
wget -O ShellBot.sh "$REPO/ShellBot.sh"
echo "Descargando Motor del Bot..."
wget -O bot_jaok.sh "$REPO/bot_jaok.sh"

chmod +x bot_jaok.sh

# 3. CONFIGURAR TOKEN
echo ""
read -p "Ingresa tu TOKEN de Telegram (BotFather): " token
read -p "Ingresa tu ID de Usuario (Para ser Admin): " admin_id

# Inyectar credenciales en el script
sed -i "s|TOKEN=\"\"|TOKEN=\"$token\"|g" bot_jaok.sh
sed -i "s|ADMIN_ID=\"\"|ADMIN_ID=\"$admin_id\"|g" bot_jaok.sh

# 4. INICIAR EN SEGUNDO PLANO (Screen)
screen -dmS jaokbot ./bot_jaok.sh

echo ""
echo "🤖 BOT INICIADO CORRETAMENTE"
echo "Usa: screen -r jaokbot (para ver la consola)"
