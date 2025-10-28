# Guia de Início Rápido - Metro SP App

## 🚀 Começando em 5 Passos

### 1. Instalar Dependências

```bash
cd metro
flutter pub get
```

### 2. Configurar Firebase

**Opção A: Usar FlutterFire CLI (Recomendado)**

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Login no Firebase
firebase login

# Configurar projeto
flutterfire configure
```

**Opção B: Configuração Manual**

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Crie um novo projeto
3. Adicione apps Android, iOS e Web
4. Baixe os arquivos de configuração
5. Coloque nos locais corretos:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`

### 3. Habilitar Serviços no Firebase

No Firebase Console, habilite:

- ✅ **Authentication** → Email/Password
- ✅ **Firestore Database** → Modo de teste (depois configure regras)
- ✅ **Storage** → Modo de teste (depois configure regras)

### 4. Configurar Gemini AI

1. Acesse [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Gere uma API Key
3. Abra `lib/services/gemini_service.dart`
4. Substitua `YOUR_GEMINI_API_KEY` pela sua chave

```dart
static const String _apiKey = 'SUA_CHAVE_AQUI';
```

### 5. Executar o App

```bash
# Mobile
flutter run

# Web
flutter run -d chrome

# Desktop
flutter run -d windows  # ou macos, linux
```

## 📱 Primeiro Acesso

1. **Criar Conta**
   - Clique em "Não tem conta? Cadastre-se"
   - Preencha nome, email e senha
   - Sua conta será criada com role "Visualizador"

2. **Criar Primeiro Projeto**
   - Vá para aba "Projetos"
   - Clique no botão "Novo Projeto"
   - Preencha os dados básicos
   - Salve

3. **Explorar o Dashboard**
   - Visualize estatísticas
   - Acesse projetos
   - Navegue pelas funcionalidades

## ⚙️ Configurações Importantes

### Regras de Segurança do Firestore

No Firebase Console → Firestore → Regras:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Regras de Segurança do Storage

No Firebase Console → Storage → Regras:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🔧 Solução de Problemas

### Erro: "Firebase not initialized"

```bash
flutter clean
flutter pub get
flutterfire configure
```

### Erro: "API key not valid"

Verifique se a API key do Gemini está correta em `gemini_service.dart`

### Erro de Build Android

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Erro de Build iOS

```bash
cd ios
pod install
cd ..
flutter clean
flutter run
```

## 📚 Recursos Adicionais

- **Documentação Técnica Completa**: `DOCUMENTACAO_TECNICA.md`
- **README do Projeto**: `metro/README.md`
- **Documentação Flutter**: https://docs.flutter.dev
- **Documentação Firebase**: https://firebase.google.com/docs
- **Documentação Gemini AI**: https://ai.google.dev/docs

## 🆘 Suporte

Se encontrar problemas:

1. Verifique a documentação técnica
2. Consulte os logs de erro
3. Verifique as configurações do Firebase
4. Teste em um dispositivo diferente

## ✅ Checklist de Configuração

- [ ] Flutter instalado e funcionando
- [ ] Projeto Firebase criado
- [ ] FlutterFire configurado
- [ ] Authentication habilitado
- [ ] Firestore criado
- [ ] Storage configurado
- [ ] Gemini API Key configurada
- [ ] Dependências instaladas (`flutter pub get`)
- [ ] App executando sem erros

## 🎯 Próximos Passos

Após configurar o básico:

1. Configure permissões de usuários (roles)
2. Implemente Firebase Cloud Functions
3. Adicione pontos de captura nos projetos
4. Teste a captura e análise de imagens
5. Configure notificações
6. Personalize o tema e cores

---

**Pronto!** Seu aplicativo está configurado e pronto para uso. 🎉

