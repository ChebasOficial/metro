# Documentação Técnica - Metro SP Monitoramento de Obras

## Visão Geral do Projeto

O aplicativo Metro SP é uma plataforma digital multiplataforma desenvolvida em Flutter para monitoramento automatizado de obras do Metrô de São Paulo. O sistema utiliza visão computacional através da API do Google Gemini AI para análise de imagens e comparação com modelos BIM em formato IFC.

## Arquitetura do Sistema

### Stack Tecnológico

#### Frontend
- **Flutter 3.5+** - Framework multiplataforma (Web, Desktop, Mobile)
- **Dart** - Linguagem de programação
- **Provider** - Gerenciamento de estado
- **Material Design 3** - Design system

#### Backend e Serviços
- **Firebase Authentication** - Autenticação de usuários
- **Cloud Firestore** - Banco de dados NoSQL em tempo real
- **Firebase Storage** - Armazenamento de imagens e arquivos
- **Firebase Cloud Functions** - Processamento serverless (a implementar)
- **Google Gemini AI** - Análise de imagens com inteligência artificial

### Fluxo de Dados

1. **Captura de Imagem**
   - Usuário captura imagem via câmera do dispositivo
   - Imagem é comprimida e otimizada
   - Metadados (localização, data, ponto de captura) são coletados

2. **Upload e Armazenamento**
   - Imagem é enviada para Firebase Storage
   - Registro é criado no Firestore com status "pending"
   - URL da imagem é armazenada no registro

3. **Processamento com IA**
   - Cloud Function é acionada (trigger automático)
   - Imagem é enviada para Gemini AI API
   - Análise retorna elementos detectados, problemas e estimativa de progresso

4. **Armazenamento de Resultados**
   - Análise é salva no Firestore
   - Registro de imagem é atualizado com status "completed"
   - Alertas são criados automaticamente se problemas forem detectados

5. **Visualização**
   - Usuário acessa galeria cronológica
   - Visualiza análises e comparações
   - Recebe notificações de alertas críticos

## Estrutura de Dados (Firestore)

### Coleção: users
```json
{
  "id": "string",
  "email": "string",
  "name": "string",
  "phone": "string?",
  "role": "admin|engenheiro|fiscal|visualizador",
  "assignedProjects": ["projectId1", "projectId2"],
  "photoUrl": "string?",
  "isActive": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "lastLoginAt": "timestamp?"
}
```

### Coleção: projects
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "location": "string",
  "startDate": "timestamp",
  "expectedEndDate": "timestamp?",
  "status": "em_andamento|pausado|concluido",
  "responsibleEngineers": ["userId1", "userId2"],
  "bimData": "object?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Coleção: capture_points
```json
{
  "id": "string",
  "projectId": "string",
  "name": "string",
  "description": "string",
  "latitude": "number",
  "longitude": "number",
  "referenceImage": "string?",
  "bimReference": "object?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Coleção: image_records
```json
{
  "id": "string",
  "projectId": "string",
  "capturePointId": "string",
  "imageUrl": "string",
  "thumbnailUrl": "string",
  "captureDate": "timestamp",
  "capturedBy": "string",
  "capturedByName": "string",
  "latitude": "number?",
  "longitude": "number?",
  "constructionPhase": "string?",
  "metadata": "object?",
  "analysisStatus": "pending|processing|completed|failed",
  "analysisId": "string?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Coleção: analyses
```json
{
  "id": "string",
  "imageRecordId": "string",
  "projectId": "string",
  "analysisDate": "timestamp",
  "status": "completed|failed",
  "geminiResponse": "object",
  "detectedElements": [
    {
      "type": "string",
      "description": "string",
      "confidence": "number",
      "boundingBox": "object?"
    }
  ],
  "identifiedIssues": ["string"],
  "progressEstimate": "number?",
  "comparisonWithBIM": "string?",
  "deviations": "object?",
  "createdAt": "timestamp"
}
```

### Coleção: alerts
```json
{
  "id": "string",
  "projectId": "string",
  "imageRecordId": "string?",
  "analysisId": "string?",
  "type": "desvio|atraso|seguranca|qualidade",
  "severity": "baixa|media|alta|critica",
  "title": "string",
  "description": "string",
  "status": "aberto|em_analise|resolvido|ignorado",
  "assignedTo": "string?",
  "detectedAt": "timestamp",
  "resolvedAt": "timestamp?",
  "resolution": "string?",
  "affectedAreas": ["string"],
  "metadata": "object?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Modelos de Dados (Dart)

Todos os modelos estão implementados em `lib/models/`:

- `user_model.dart` - Usuários do sistema
- `project_model.dart` - Projetos/Obras
- `capture_point_model.dart` - Pontos de captura
- `image_record_model.dart` - Registros de imagens
- `analysis_model.dart` - Análises de IA
- `alert_model.dart` - Alertas e desvios

Cada modelo possui:
- Construtor com parâmetros nomeados
- `fromFirestore()` - Conversão de DocumentSnapshot
- `toFirestore()` - Conversão para Map
- `copyWith()` - Criação de cópias com modificações

## Serviços (Services)

### AuthService (`lib/services/auth_service.dart`)

Gerencia autenticação e perfil de usuários:

- `signInWithEmailAndPassword()` - Login
- `registerWithEmailAndPassword()` - Registro
- `signOut()` - Logout
- `resetPassword()` - Recuperação de senha
- `getUserData()` - Buscar dados do usuário
- `updateUserProfile()` - Atualizar perfil

### ProjectService (`lib/services/project_service.dart`)

Gerencia projetos/obras:

- `createProject()` - Criar projeto
- `updateProject()` - Atualizar projeto
- `deleteProject()` - Deletar projeto
- `getProject()` - Buscar projeto por ID
- `getAllProjects()` - Stream de todos os projetos
- `getProjectsByStatus()` - Filtrar por status
- `getProjectsByEngineer()` - Projetos de um engenheiro
- `searchProjects()` - Busca por nome/localização

### ImageService (`lib/services/image_service.dart`)

Gerencia captura e armazenamento de imagens:

- `captureImage()` - Capturar da câmera
- `pickImage()` - Selecionar da galeria
- `uploadImage()` - Upload para Firebase Storage
- `createImageRecord()` - Criar registro no Firestore
- `updateImageRecord()` - Atualizar registro
- `deleteImageRecord()` - Deletar imagem e registro
- `getProjectImages()` - Stream de imagens do projeto
- `getCapturePointImages()` - Imagens de um ponto
- `getImagesByDateRange()` - Filtrar por período
- `getProjectImageStats()` - Estatísticas de imagens

### GeminiService (`lib/services/gemini_service.dart`)

Integração com Google Gemini AI:

- `analyzeConstructionImage()` - Analisar imagem de obra
- `compareImages()` - Comparar duas imagens (progresso temporal)
- `getAnalysis()` - Buscar análise por ID
- `getProjectAnalyses()` - Stream de análises do projeto

**Importante:** A API Key do Gemini deve ser configurada antes do uso.

### AlertService (`lib/services/alert_service.dart`)

Gerencia alertas e desvios:

- `createAlert()` - Criar alerta
- `updateAlert()` - Atualizar alerta
- `deleteAlert()` - Deletar alerta
- `getProjectAlerts()` - Stream de alertas do projeto
- `getAlertsByStatus()` - Filtrar por status
- `getAlertsBySeverity()` - Filtrar por severidade
- `assignAlert()` - Atribuir a usuário
- `resolveAlert()` - Resolver alerta
- `dismissAlert()` - Ignorar alerta
- `getProjectAlertStats()` - Estatísticas de alertas
- `createAlertFromAnalysis()` - Criar alerta automático

## Telas (Screens)

### Autenticação
- `LoginScreen` - Login com email/senha
- `RegisterScreen` - Cadastro de novos usuários

### Principal
- `HomeScreen` - Dashboard com navegação por tabs
- `_DashboardPage` - Visão geral e estatísticas

### Projetos
- `ProjectsListScreen` - Lista de projetos com filtros
- `ProjectDetailScreen` - Detalhes e ações do projeto
- `CreateProjectScreen` - Criação de novo projeto

### Perfil
- `ProfileScreen` - Visualização e edição de perfil

## Configuração (Config)

### AppConfig (`lib/config/app_config.dart`)

Centraliza todas as configurações visuais e constantes:

- Cores do tema (primária, secundária, status, severidade)
- Tamanhos de texto
- Espaçamentos
- Border radius
- Temas claro e escuro
- Funções utilitárias (getStatusColor, getSeverityColor, etc.)

## Sistema de Permissões (Roles)

### Admin
- Acesso total ao sistema
- Gerenciar usuários e permissões
- Criar, editar e deletar projetos
- Visualizar todos os dados

### Engenheiro
- Gerenciar projetos atribuídos
- Capturar e analisar imagens
- Criar e resolver alertas
- Exportar relatórios

### Fiscal
- Capturar imagens
- Visualizar análises
- Gerenciar alertas
- Acesso limitado a projetos atribuídos

### Visualizador (Padrão)
- Apenas visualização
- Não pode capturar imagens
- Não pode criar ou editar dados
- Acesso somente leitura

## Integração com BIM (IFC)

O sistema está preparado para integração com arquivos IFC (Industry Foundation Classes):

1. **Upload de Arquivo IFC**
   - Arquivo é armazenado no Firebase Storage
   - Referência é salva no projeto

2. **Parsing de IFC**
   - Utilizar biblioteca específica para Flutter
   - Extrair elementos estruturais
   - Mapear coordenadas e geometrias

3. **Comparação com Imagens**
   - Gemini AI analisa imagem
   - Sistema compara elementos detectados com modelo BIM
   - Identifica desvios e inconsistências

**Nota:** A implementação completa do parsing IFC requer biblioteca adicional (a ser definida).

## Firebase Cloud Functions (A Implementar)

### Função: onImageUpload

Trigger automático quando imagem é enviada:

```javascript
exports.onImageUpload = functions.storage.object().onFinalize(async (object) => {
  // 1. Obter metadados da imagem
  // 2. Baixar imagem
  // 3. Enviar para Gemini AI
  // 4. Processar resposta
  // 5. Salvar análise no Firestore
  // 6. Criar alertas se necessário
  // 7. Atualizar status da imagem
});
```

### Função: analyzeImage

Chamada manual para análise:

```javascript
exports.analyzeImage = functions.https.onCall(async (data, context) => {
  // Verificar autenticação
  // Processar imagem com Gemini AI
  // Retornar resultado
});
```

### Função: compareWithBIM

Comparação com modelo BIM:

```javascript
exports.compareWithBIM = functions.https.onCall(async (data, context) => {
  // Carregar modelo BIM
  // Comparar com análise da imagem
  // Identificar desvios
  // Retornar resultado
});
```

## Segurança

### Regras do Firestore

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
    
    function hasRole(role) {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }
    
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId) || hasRole('admin');
    }
    
    match /projects/{projectId} {
      allow read: if isAuthenticated();
      allow create: if hasRole('admin') || hasRole('engenheiro');
      allow update, delete: if hasRole('admin');
    }
    
    match /image_records/{recordId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
                      (hasRole('admin') || hasRole('engenheiro') || hasRole('fiscal'));
      allow update, delete: if hasRole('admin') || hasRole('engenheiro');
    }
    
    match /analyses/{analysisId} {
      allow read: if isAuthenticated();
      allow write: if hasRole('admin') || hasRole('engenheiro');
    }
    
    match /alerts/{alertId} {
      allow read: if isAuthenticated();
      allow write: if hasRole('admin') || hasRole('engenheiro') || hasRole('fiscal');
    }
  }
}
```

### Regras do Storage

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    function isAuthenticated() {
      return request.auth != null;
    }
    
    match /projects/{projectId}/{allPaths=**} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
  }
}
```

## Próximos Passos de Desenvolvimento

### Curto Prazo
1. Implementar Firebase Cloud Functions
2. Adicionar tela de captura de imagens
3. Implementar galeria cronológica
4. Adicionar visualização de análises
5. Implementar sistema de notificações

### Médio Prazo
1. Integração completa com arquivos IFC
2. Comparação temporal de imagens
3. Exportação de relatórios em PDF
4. Dashboard com gráficos e estatísticas
5. Suporte offline com sincronização

### Longo Prazo
1. Machine Learning on-device
2. Realidade aumentada para sobreposição BIM
3. Integração com drones
4. API pública para integrações
5. Versão web completa

## Testes

### Testes Unitários
- Testar modelos de dados
- Testar serviços isoladamente
- Testar utilitários e helpers

### Testes de Integração
- Testar fluxos completos
- Testar integração com Firebase
- Testar integração com Gemini AI

### Testes de Widget
- Testar componentes visuais
- Testar navegação
- Testar formulários

## Deployment

### Mobile (Android/iOS)
1. Configurar assinatura de aplicativo
2. Gerar builds de produção
3. Publicar nas lojas (Google Play / App Store)

### Web
1. Build de produção: `flutter build web`
2. Deploy no Firebase Hosting
3. Configurar domínio customizado

### Desktop
1. Build para plataforma específica
2. Criar instaladores
3. Distribuir via site ou lojas

## Manutenção e Monitoramento

- Firebase Analytics - Métricas de uso
- Firebase Crashlytics - Relatórios de erros
- Firebase Performance - Monitoramento de performance
- Logs estruturados no Cloud Functions

## Contato e Suporte

Para dúvidas técnicas ou suporte, consulte a documentação do Firebase e Flutter, ou entre em contato com a equipe de desenvolvimento.

