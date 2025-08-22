#!/bin/bash

# Script para iniciar el sistema completo
echo "🍽️ Iniciando Sistema de Platos - Residencia Universitaria"

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado. Por favor instálalo desde https://nodejs.org/"
    exit 1
fi

echo "📦 Instalando dependencias del backend..."
cd backend
npm install
if [ $? -ne 0 ]; then
    echo "❌ Error instalando dependencias del backend"
    exit 1
fi

echo "📦 Instalando dependencias del frontend..."
cd ../frontend
npm install
if [ $? -ne 0 ]; then
    echo "❌ Error instalando dependencias del frontend"
    exit 1
fi

echo "🚀 Iniciando backend en puerto 3000..."
cd ../backend
npm run start:dev &
BACKEND_PID=$!

echo "⏳ Esperando a que el backend inicie..."
sleep 5

echo "🎨 Iniciando frontend en puerto 5173..."
cd ../frontend
npm run dev &
FRONTEND_PID=$!

echo ""
echo "✅ ¡Sistema iniciado correctamente!"
echo "🔗 Frontend: http://localhost:5173"
echo "🔗 Backend API: http://localhost:3000"
echo ""
echo "Para detener el sistema, presiona Ctrl+C"

# Función para limpiar procesos al salir
cleanup() {
    echo ""
    echo "🛑 Deteniendo servicios..."
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    exit 0
}

# Capturar señal de interrupción
trap cleanup SIGINT

# Mantener el script corriendo
wait
