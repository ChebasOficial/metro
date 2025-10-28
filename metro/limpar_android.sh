#!/bin/bash

echo "🧹 Limpeza Completa do Android - Metro SP"
echo "=========================================="
echo ""

# Ir para o diretório do projeto
cd "$(dirname "$0")"

echo "1️⃣ Limpando Flutter..."
flutter clean

echo ""
echo "2️⃣ Removendo cache do Flutter..."
rm -rf .dart_tool
rm -rf build
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies
rm -f pubspec.lock

echo ""
echo "3️⃣ Limpando Gradle..."
cd android
./gradlew clean
./gradlew cleanBuildCache

echo ""
echo "4️⃣ Removendo cache do Gradle local..."
rm -rf .gradle
rm -rf app/build
rm -rf build

echo ""
echo "5️⃣ Removendo cache global do Gradle..."
rm -rf ~/.gradle/caches/

echo ""
echo "6️⃣ Voltando ao diretório raiz..."
cd ..

echo ""
echo "7️⃣ Reinstalando dependências..."
flutter pub get

echo ""
echo "✅ LIMPEZA COMPLETA!"
echo ""
echo "Agora execute:"
echo "  flutter run"
echo ""

