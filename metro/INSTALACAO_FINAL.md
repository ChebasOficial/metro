# Instalação Final - Metro SP App

## ✅ Todas as Correções Aplicadas

Este ZIP contém o projeto completo com TODAS as correções:

- ✅ Android NDK 27.0.12077973
- ✅ minSdk 23 (Android 6.0+)
- ✅ compileSdk 35
- ✅ targetSdk 35
- ✅ Firebase configurado
- ✅ Sem Firebase Storage (100% gratuito)
- ✅ Main.dart funcional com splash screen
- ✅ Tratamento de erros
- ✅ Multidex habilitado

---

## 🚀 Instalação Rápida

### 1. Extrair o Projeto

```bash
# Extraia o ZIP
unzip metro_sp_app_completo.zip

# Entre no diretório
cd metro
```

### 2. Limpar Cache (IMPORTANTE!)

**macOS/Linux:**
```bash
# Deletar cache global do Gradle
rm -rf ~/.gradle/caches/
rm -rf ~/.android/build-cache

# Limpar projeto
flutter clean
flutter pub get
```

**Windows:**
```cmd
# Deletar cache global do Gradle
rmdir /s /q %USERPROFILE%\.gradle\caches
rmdir /s /q %USERPROFILE%\.android\build-cache

# Limpar projeto
flutter clean
flutter pub get
```

### 3. Configurar Firebase Console

Acesse: https://console.firebase.google.com/project/metro-31d1d

#### 3.1 Authentication
1. Menu → **Authentication**
2. **"Começar"**
3. Aba **"Sign-in method"**
4. Ativar **"Email/Password"**
5. **"Salvar"**

#### 3.2 Firestore Database
1. Menu → **Firestore Database**
2. **"Criar banco de dados"**
3. Modo: **"Teste"**
4. Localização: **"southamerica-east1"**
5. **"Ativar"**

#### 3.3 Regras do Firestore
1. Aba **"Regras"**
2. Cole este código:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }
    
    match /projects/{projectId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
    
    match /capture_points/{pointId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
    
    match /images/{imageId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
      allow delete: if isAuthenticated();
    }
    
    match /image_records/{recordId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
    
    match /analyses/{analysisId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
    
    match /alerts/{alertId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
  }
}
```

3. **"Publicar"**

### 4. Configurar API Key do Gemini

1. Acesse: https://makersuite.google.com/app/apikey
2. Crie uma API Key
3. Abra: `lib/services/gemini_service.dart`
4. Linha 12: Substitua `'YOUR_GEMINI_API_KEY'` pela sua chave

### 5. Executar

```bash
flutter run
```

---

## 📱 Resultado Esperado

1. **Splash Screen** azul com logo
2. **Tela de Login** com campos de email e senha
3. **Botão "Cadastre-se"** funcionando

---

## 🐛 Se Ainda Crashar

### Solução 1: Reconfigurar Firebase

```bash
# Instalar FlutterFire CLI (se não tiver)
dart pub global activate flutterfire_cli
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Reconfigurar
flutterfire configure
# Responda "no" quando perguntar sobre firebase.json
# Selecione o projeto metro-31d1d
# Marque: android, ios, web

# Limpar e executar
flutter clean
flutter pub get
flutter run
```

### Solução 2: Verificar Configurações

Execute:
```bash
cat android/app/build.gradle.kts | grep -E "compileSdk|minSdk|targetSdk|ndkVersion"
```

**Deve mostrar:**
```
compileSdk = 35
ndkVersion = "27.0.12077973"
minSdk = 23
targetSdk = 35
```

Se mostrar valores diferentes, edite manualmente o arquivo.

### Solução 3: Recrear Projeto Android

```bash
cd metro
rm -rf android
flutter create --platforms=android .
```

Depois copie de volta o `build.gradle.kts` correto.

---

## ✅ Checklist Final

- [ ] Extraí o ZIP
- [ ] Deletei `~/.gradle/caches/`
- [ ] Executei `flutter clean`
- [ ] Executei `flutter pub get`
- [ ] Configurei Authentication no Firebase Console
- [ ] Criei Firestore Database no Firebase Console
- [ ] Configurei Regras do Firestore
- [ ] Configurei API Key do Gemini
- [ ] Executei `flutter run`

---

## 📊 Funcionalidades

### Implementadas:
- ✅ Autenticação (Login/Registro)
- ✅ Estrutura de projetos
- ✅ Serviços Firebase
- ✅ Integração Gemini AI
- ✅ Armazenamento de imagens (Base64)

### Para Implementar:
- ⏳ Telas de projetos completas
- ⏳ Captura de imagens
- ⏳ Análise de imagens
- ⏳ Dashboard com estatísticas
- ⏳ Sistema de alertas

---

## 🎯 Estrutura do Projeto

```
metro/
├── lib/
│   ├── config/
│   │   └── app_config.dart          ✅ Configurações e temas
│   ├── models/                      ✅ Modelos de dados
│   ├── services/                    ✅ Serviços (Auth, Firebase, Gemini)
│   ├── screens/
│   │   ├── auth/                    ✅ Login e Registro
│   │   ├── home/                    ✅ Dashboard
│   │   ├── projects/                ⏳ Gerenciamento de projetos
│   │   └── profile/                 ⏳ Perfil do usuário
│   ├── firebase_options.dart        ✅ Configuração Firebase
│   └── main.dart                    ✅ Entrada do app
├── android/                         ✅ Configuração Android corrigida
└── pubspec.yaml                     ✅ Dependências

✅ = Implementado
⏳ = Estrutura criada, precisa implementar lógica
```

---

## 📞 Suporte

Se o app ainda crashar após seguir todos os passos:

1. Execute: `flutter doctor -v`
2. Copie a saída completa
3. Execute: `cat android/app/build.gradle.kts`
4. Copie o conteúdo
5. Me envie ambos

---

## 🎉 Sucesso!

Se você ver a tela de login, parabéns! O app está funcionando.

Próximos passos:
1. Criar uma conta
2. Fazer login
3. Explorar o dashboard
4. Começar a implementar as funcionalidades restantes

**Projeto 100% gratuito e pronto para desenvolvimento!** 🚀

