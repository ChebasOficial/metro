# Metro SP - Monitoramento de Obras

Aplicativo Flutter para monitoramento automatizado de obras do Metrô de São Paulo, utilizando visão computacional, inteligência artificial e integração com BIM.

## 🎯 Funcionalidades

- ✅ Autenticação de usuários com Firebase Auth
- ✅ Gerenciamento de projetos/obras
- ✅ Captura de imagens do canteiro de obras
- ✅ Organização cronológica de registros visuais
- ✅ Análise automática com Gemini AI
- ✅ Comparação com modelo BIM (IFC)
- ✅ Sistema de alertas e desvios
- ✅ Estimativa automática de progresso
- ✅ Interface multiplataforma (Web, Desktop, Mobile)

## 🛠️ Tecnologias Utilizadas

### Frontend
- **Flutter** (Dart) - Framework multiplataforma
- **Provider** - Gerenciamento de estado
- **Google Maps Flutter** - Visualização de mapas

### Backend & Serviços
- **Firebase Authentication** - Autenticação de usuários
- **Cloud Firestore** - Banco de dados NoSQL
- **Firebase Storage** - Armazenamento de imagens
- **Firebase Cloud Functions** - Processamento serverless
- **Google Gemini AI** - Análise de imagens com IA

## 📋 Pré-requisitos

- Flutter SDK (>=3.5.0)
- Dart SDK
- Firebase CLI
- Conta Google Cloud (para Gemini AI)

## 🚀 Configuração do Projeto

### 1. Instale as dependências

\`\`\`bash
flutter pub get
\`\`\`

### 2. Configure o Firebase

1. Crie um projeto no Firebase Console
2. Execute: \`flutterfire configure\`
3. Configure Firestore, Storage e Authentication

### 3. Configure o Gemini AI

Adicione sua API Key em \`lib/services/gemini_service.dart\`

## 🏃 Executando

\`\`\`bash
flutter run
\`\`\`

## 📁 Estrutura

\`\`\`
lib/
├── config/       # Configurações
├── models/       # Modelos de dados
├── screens/      # Telas
├── services/     # Serviços
├── widgets/      # Widgets
└── utils/        # Utilitários
\`\`\`

## 👥 Roles

- **Admin**: Acesso total
- **Engenheiro**: Gerenciamento de projetos
- **Fiscal**: Captura e alertas
- **Visualizador**: Apenas visualização

