# Solução Definitiva para Erros do Android

## 🎯 Problema

O erro persiste porque o **cache do Gradle** no seu computador ainda está usando as configurações antigas (minSdk 21 e NDK 26).

---

## ✅ Solução: Limpeza Completa

### Opção 1: Script Automático (Recomendado)

Incluí scripts de limpeza automática no projeto:

**macOS/Linux:**
```bash
cd metro
./limpar_android.sh
```

**Windows:**
```cmd
cd metro
limpar_android.bat
```

### Opção 2: Manual (Passo a Passo)

Execute estes comandos **na ordem**:

```bash
# 1. Ir para o projeto
cd metro

# 2. Limpar Flutter
flutter clean

# 3. Remover cache do Flutter
rm -rf .dart_tool
rm -rf build
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies
rm -f pubspec.lock

# 4. Limpar Gradle
cd android
./gradlew clean
./gradlew cleanBuildCache

# 5. Remover cache local do Gradle
rm -rf .gradle
rm -rf app/build
rm -rf build

# 6. Remover cache GLOBAL do Gradle (IMPORTANTE!)
rm -rf ~/.gradle/caches/

# 7. Voltar e reinstalar
cd ..
flutter pub get

# 8. Executar
flutter run
```

---

## 🔍 Verificar se as Mudanças Estão Aplicadas

Antes de executar, verifique se o arquivo está correto:

```bash
cat android/app/build.gradle.kts | grep -A 5 "android {"
```

**Deve mostrar:**
```kotlin
android {
    namespace = "com.pii.metro"
    compileSdk = 35
    ndkVersion = "27.0.12077973"
```

**E também:**
```bash
cat android/app/build.gradle.kts | grep -A 5 "defaultConfig {"
```

**Deve mostrar:**
```kotlin
defaultConfig {
    applicationId = "com.pii.metro"
    minSdk = 23
    targetSdk = 35
```

---

## ⚠️ Se AINDA Não Funcionar

### Última Solução: Deletar Cache Global Manualmente

**macOS/Linux:**
```bash
# Fechar Android Studio e VS Code
# Depois executar:
rm -rf ~/.gradle
rm -rf ~/.android/build-cache
```

**Windows:**
```cmd
# Fechar Android Studio e VS Code
# Depois executar no CMD como Administrador:
rmdir /s /q %USERPROFILE%\.gradle
rmdir /s /q %USERPROFILE%\.android\build-cache
```

Depois:
```bash
cd metro
flutter clean
flutter pub get
flutter run
```

---

## 🐛 Troubleshooting

### Erro: "gradlew: command not found"

**macOS/Linux:**
```bash
cd android
chmod +x gradlew
./gradlew clean
cd ..
```

### Erro: "Permission denied"

```bash
chmod +x android/gradlew
```

### Erro: "SDK location not found"

Crie o arquivo `android/local.properties`:

**macOS:**
```bash
echo "sdk.dir=/Users/SEU_USUARIO/Library/Android/sdk" > android/local.properties
```

**Linux:**
```bash
echo "sdk.dir=/home/SEU_USUARIO/Android/Sdk" > android/local.properties
```

**Windows:**
```cmd
echo sdk.dir=C:\\Users\\SEU_USUARIO\\AppData\\Local\\Android\\Sdk > android\local.properties
```

---

## 📋 Checklist Completo

- [ ] Extraí o novo ZIP
- [ ] Deletei a pasta antiga completamente
- [ ] Executei `flutter clean`
- [ ] Removi `.dart_tool`
- [ ] Removi `pubspec.lock`
- [ ] Executei `cd android && ./gradlew clean`
- [ ] Removi `android/.gradle`
- [ ] Removi `~/.gradle/caches/` (IMPORTANTE!)
- [ ] Executei `flutter pub get`
- [ ] Verifiquei que `minSdk = 23` está no build.gradle.kts
- [ ] Verifiquei que `ndkVersion = "27.0.12077973"` está no build.gradle.kts
- [ ] Executei `flutter run`

---

## 🎯 Por Que o Erro Persiste?

O Gradle mantém um **cache global** em `~/.gradle/caches/` que armazena:
- Configurações antigas do projeto
- Versões antigas das bibliotecas
- Metadados de build

Mesmo após `flutter clean`, esse cache permanece. Por isso é essencial deletá-lo!

---

## ✅ Verificação Final

Após a limpeza completa, o build deve funcionar. Se você ver:

```
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

**Sucesso!** 🎉

---

## 📞 Se Nada Funcionar

Como última alternativa, recrie o projeto Android:

```bash
cd metro
rm -rf android
flutter create --platforms=android .
```

Depois copie de volta o `build.gradle.kts` correto que está no ZIP.

---

## 🎓 Resumo

O problema é **cache do Gradle**, não o código. A solução é:

1. ✅ Limpar Flutter (`flutter clean`)
2. ✅ Limpar Gradle local (`./gradlew clean`)
3. ✅ **Deletar cache global** (`rm -rf ~/.gradle/caches/`)
4. ✅ Reinstalar (`flutter pub get`)
5. ✅ Executar (`flutter run`)

**Execute o script `limpar_android.sh` (ou `.bat`) que faz tudo isso automaticamente!**

