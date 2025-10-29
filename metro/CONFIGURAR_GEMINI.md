# 🤖 Como Configurar o Gemini AI

## 📋 Passo a Passo

### 1️⃣ Obter API Key do Google AI Studio

1. Acesse: **https://makersuite.google.com/app/apikey**
2. Faça login com sua conta Google
3. Clique em **"Create API Key"**
4. Escolha um projeto do Google Cloud (ou crie um novo)
5. Copie a API Key gerada (exemplo: `AIzaSyD...`)

---

### 2️⃣ Adicionar a API Key no Projeto

1. Abra o arquivo:
   ```
   metro/lib/services/gemini_service.dart
   ```

2. Localize a linha 14:
   ```dart
   static const String _apiKey = 'YOUR_GEMINI_API_KEY';
   ```

3. Substitua `YOUR_GEMINI_API_KEY` pela sua chave real:
   ```dart
   static const String _apiKey = 'AIzaSyD...sua-chave-aqui...';
   ```

4. Salve o arquivo

---

### 3️⃣ Testar a Configuração

1. Execute o app:
   ```bash
   flutter run
   ```

2. Capture uma imagem

3. Vá em **"Análises"** para ver o resultado

---

### 4️⃣ Como Funciona

Quando você captura uma imagem:

1. ✅ Imagem é salva no Firestore
2. ✅ Se **"Análise Automática"** estiver ativada (Configurações)
3. ✅ Imagem é enviada para o Gemini AI
4. ✅ IA analisa e retorna:
   - Problemas detectados
   - Riscos de segurança
   - Sugestões de melhoria
   - Estimativa de progresso
5. ✅ Resultado é salvo em `analyses`
6. ✅ Se houver problema crítico, cria um alerta

---

### 5️⃣ Ativar Análise Automática

1. Vá em **Perfil** → **Configurações**
2. Ative **"Análise Automática"**
3. Agora toda imagem capturada será analisada automaticamente

---

### ⚠️ Importante

- A API do Gemini tem **limite gratuito** de requisições
- Após o limite, pode ser cobrado
- Verifique os limites em: https://ai.google.dev/pricing

---

### 🔒 Segurança

**NÃO compartilhe sua API Key!**

Para produção, use variáveis de ambiente:

1. Crie arquivo `.env`:
   ```
   GEMINI_API_KEY=sua-chave-aqui
   ```

2. Adicione ao `.gitignore`:
   ```
   .env
   ```

3. Use pacote `flutter_dotenv` para ler a chave

---

### 📊 O Que a IA Analisa

**Em imagens de obras:**
- ✅ Problemas estruturais
- ✅ Falta de equipamentos de segurança
- ✅ Desvios do projeto
- ✅ Progresso da construção
- ✅ Qualidade dos materiais
- ✅ Organização do canteiro

**Exemplo de Análise:**
```
Problemas Detectados:
- Falta de sinalização de segurança
- Materiais desorganizados
- Possível acúmulo de água

Recomendações:
- Instalar placas de segurança
- Organizar área de materiais
- Verificar drenagem
```

---

### 🆘 Problemas Comuns

**Erro: "API key not valid"**
- Verifique se copiou a chave completa
- Certifique-se de que a API está ativada no Google Cloud

**Erro: "Quota exceeded"**
- Você atingiu o limite gratuito
- Aguarde o reset ou configure billing

**Análise não aparece:**
- Verifique se "Análise Automática" está ativada
- Veja os logs do terminal para erros

---

Pronto! Agora o Gemini AI está configurado! 🚀
