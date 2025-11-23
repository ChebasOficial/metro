#!/bin/bash

echo "🧹 Limpando cache completo do Flutter..."

cd metro

# 1. Limpar build do Flutter
echo "1️⃣ Limpando flutter clean..."
flutter clean

# 2. Remover arquivos de cache
echo "2️⃣ Removendo .dart_tool..."
rm -rf .dart_tool

echo "3️⃣ Removendo pubspec.lock..."
rm -f pubspec.lock

echo "4️⃣ Removendo build folders..."
rm -rf build
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

# 3. Reinstalar dependências
echo "5️⃣ Instalando dependências..."
flutter pub get

echo ""
echo "✅ LIMPEZA COMPLETA!"
echo ""
echo "Agora:"
echo "1. Feche COMPLETAMENTE o VS Code ou Android Studio"
echo "2. Abra novamente"
echo "3. Execute: flutter run"
echo ""

