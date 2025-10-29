# Metro SP - Aplicativo de Monitoramento de Obras

## 🎯 Versão Corrigida - Outubro 2025

Esta versão contém todas as correções aplicadas de forma limpa e sem erros de compilação.

## ✅ Correções Implementadas

### 1. **Filtro de Projetos por Usuário**
- Adicionado campo `userId` ao `ProjectModel`
- Projetos agora são filtrados por usuário logado
- Cada usuário vê apenas seus próprios projetos

### 2. **Atualização Automática do Dashboard**
- Dashboard atualiza automaticamente ao retornar de outras telas
- Estatísticas sempre mostram dados em tempo real
- Implementado usando `didChangeDependencies()`

### 3. **Nome do Usuário Correto**
- Campo "Capturado por" agora mostra o nome do email (ex: "teste" para teste@gmail.com)
- Corrigido em `image_service.dart` usando `email.split('@').first`

### 4. **Análise Automática com IA**
- Após capturar uma imagem, a análise com Gemini AI é executada automaticamente
- Feedback visual em 3 etapas:
  - ✅ "Imagem enviada com sucesso!"
  - 🤖 "Processando análise de IA..."
  - ✅ "Análise concluída!"
- Pode ser desativada nas Configurações

### 5. **Botão de Configurações**
- Acessível através do Perfil
- Permite ativar/desativar análise automática
- Permite alternar tema escuro/claro

## 🔧 Configuração Necessária

### **IMPORTANTE: Configurar Chave da API do Gemini**

Para que a análise automática funcione, você precisa configurar sua chave da API do Google Gemini:

1. **Obter a chave da API:**
   - Acesse: https://makersuite.google.com/app/apikey
   - Faça login com sua conta Google
   - Clique em "Create API Key"
   - Copie a chave gerada

2. **Configurar no app:**
   - Abra o arquivo: `lib/services/gemini_service.dart`
   - Na linha 12, substitua:
     ```dart
     static const String _apiKey = 'YOUR_GEMINI_API_KEY';
     ```
     Por:
     ```dart
     static const String _apiKey = 'SUA_CHAVE_AQUI';
     ```

3. **Salvar e executar o app**

## 🚀 Como Executar

```bash
# 1. Instalar dependências
flutter pub get

# 2. Executar no emulador/dispositivo
flutter run

# 3. Ou gerar APK para Android
flutter build apk --release
```

## 📱 Credenciais de Teste

- **Email:** teste@gmail.com
- **Senha:** (a senha que você configurou no Firebase)

## 🎨 Funcionalidades

- ✅ Autenticação com Firebase
- ✅ Criar, listar e deletar projetos
- ✅ Capturar imagens da câmera ou galeria
- ✅ Análise automática com IA (Gemini)
- ✅ Dashboard com estatísticas em tempo real
- ✅ Galeria de imagens com opção de deletar
- ✅ Tema escuro/claro
- ✅ Configurações personalizáveis
- ✅ Filtro de dados por usuário

## 📂 Estrutura de Dados no Firestore

### Coleções:
- `users` - Dados dos usuários
- `projects` - Projetos (com campo `userId`)
- `images` - Imagens em Base64
- `image_records` - Registros de imagens (com `capturedByName`)
- `analyses` - Análises geradas pela IA
- `alerts` - Alertas detectados

## 🔍 Verificação de Erros

Todos os erros de compilação foram corrigidos:
- ❌ Parâmetros duplicados `capturedByName` - **CORRIGIDO**
- ❌ Método `analyzeImage()` inexistente - **CORRIGIDO** (agora usa `analyzeConstructionImage()`)
- ❌ Projetos não filtrados por usuário - **CORRIGIDO**
- ❌ Nome do usuário vazio - **CORRIGIDO**

## 📝 Notas Importantes

1. **Firebase:** Certifique-se de que o Firebase está configurado corretamente
2. **Gemini API:** A análise automática só funciona com a chave da API configurada
3. **Permissões:** No Android, permita acesso à câmera e armazenamento
4. **Internet:** O app requer conexão com a internet para funcionar

## 🆘 Suporte

Se encontrar problemas:
1. Verifique se a chave da API do Gemini está configurada
2. Verifique se o Firebase está configurado corretamente
3. Execute `flutter clean && flutter pub get`
4. Verifique os logs com `flutter run -v`

---

**Desenvolvido para Metro SP - Sistema de Monitoramento de Obras com IA**

