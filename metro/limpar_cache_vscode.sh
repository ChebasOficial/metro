#!/bin/bash

echo "🧹 Limpando cache do VS Code e Flutter..."

# Limpar cache do Flutter
echo "1️⃣ Limpando cache do Flutter..."
flutter clean

# Remover arquivos de análise do Dart
echo "2️⃣ Removendo arquivos de análise..."
rm -rf .dart_tool/
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

# Reinstalar dependências
echo "3️⃣ Reinstalando dependências..."
flutter pub get

echo "✅ Cache limpo! Agora:"
echo "   1. Feche o VS Code completamente"
echo "   2. Reabra o projeto"
echo "   3. Os erros devem desaparecer"

