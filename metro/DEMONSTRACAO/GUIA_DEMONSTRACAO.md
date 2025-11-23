# 🎯 Guia Completo de Demonstração - App Metro SP

Este guia mostra como usar os dados de demonstração para testar todas as funcionalidades do aplicativo Metro SP.

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Instalação](#instalação)
3. [Importação de Dados](#importação-de-dados)
4. [Funcionalidades Demonstradas](#funcionalidades-demonstradas)
5. [Estrutura dos Dados](#estrutura-dos-dados)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

Esta demonstração contém dados reais de exemplo que mostram o app Metro SP em ação, incluindo:

- **4 projetos** de obras do Metrô de São Paulo
- **4 imagens** de diferentes fases de construção
- **4 análises de IA** geradas pelo Gemini
- **Dados completos** com metadados, geolocalização e BIM

---

## 🚀 Instalação

### **Pré-requisitos**

- Node.js 16+ instalado
- Conta no Firebase
- Projeto Firebase configurado
- App Metro SP instalado

### **Passo 1: Baixar os Dados**

Extraia o arquivo `demo_metro_sp.zip`:

```bash
unzip demo_metro_sp.zip
cd demo_metro_sp
```

### **Passo 2: Instalar Dependências**

```bash
npm install firebase-admin
```

### **Passo 3: Configurar Firebase**

1. Acesse o [Console do Firebase](https://console.firebase.google.com/)
2. Selecione seu projeto
3. Vá em **Configurações do Projeto** > **Contas de Serviço**
4. Clique em **Gerar nova chave privada**
5. Salve o arquivo como `serviceAccountKey.json` no diretório `demo_metro_sp`

---

## 📥 Importação de Dados

### **Opção 1: Importação Automática (Recomendado)**

Execute o script de importação:

```bash
node import_to_firestore.js
```

O script irá:
- Ler os dados de `bin/demo_data_complete.json`
- Criar as coleções no Firestore
- Importar todos os documentos
- Converter datas para Timestamps

### **Opção 2: Importação Manual**

Se preferir importar manualmente:

1. **Acesse o Firestore:**
   - Vá para o [Console do Firebase](https://console.firebase.google.com/)
   - Selecione **Firestore Database**

2. **Crie as Coleções:**
   - `projects`
   - `image_records`
   - `analyses`

3. **Adicione os Documentos:**
   - Para cada coleção, adicione os documentos dos arquivos em `/data`
   - Use o ID especificado no campo `id` de cada documento

---

## ✨ Funcionalidades Demonstradas

### **1. Dashboard**

Após importar os dados, o dashboard mostrará:

- **4 projetos** no total
- **2 projetos em andamento**
- **1 projeto pausado**
- **1 projeto concluído**
- **4 imagens** capturadas
- **4 análises** de IA

### **2. Projetos**

Você poderá ver e interagir com:

#### **Estação Sé - Linha 1 Azul**
- Status: Em Andamento
- Localização: Praça da Sé, São Paulo
- 2 imagens capturadas (fundação e estrutura)
- Progresso: 35-40%

#### **Linha 6 - Laranja**
- Status: Em Andamento
- Localização: Av. Inajar de Souza, Brasilândia
- 2 imagens capturadas (alvenaria e acabamento)
- Progresso: 55-90%

#### **Pátio Jabaquara**
- Status: Pausado
- Localização: Jabaquara, São Paulo
- Sem imagens

#### **Estação Vila Sônia**
- Status: Concluído
- Localização: Vila Sônia, São Paulo
- Sem imagens

### **3. Galeria de Imagens**

4 imagens de obras reais:

1. **Fundação** - Estação Sé
   - Grua tower crane
   - Pilares de concreto
   - Fase inicial da obra

2. **Estrutura** - Estação Sé
   - Vigas e pilares
   - Trabalhadores com EPIs
   - Fase intermediária

3. **Alvenaria** - Linha 6
   - Paredes em construção
   - Assentamento de blocos
   - Fase avançada

4. **Acabamento** - Linha 6
   - Instalações finais
   - Obra quase concluída
   - Fase final

### **4. Análises de IA**

Cada imagem possui uma análise completa gerada pelo Gemini:

- **Elementos Detectados:**
  - Pilares, vigas, lajes
  - Equipamentos (gruas, escoramentos)
  - Trabalhadores com EPIs

- **Estimativa de Progresso:**
  - Imagem 1: 17.5%
  - Imagem 2: 37.5%
  - Imagem 3: 57.5%
  - Imagem 4: 87.5%

- **Problemas Identificados:**
  - Desvios de alinhamento
  - Recomendações de manutenção
  - Verificações necessárias

- **Comparação com BIM:**
  - Conformidade com projeto
  - Desvios críticos, moderados e menores

### **5. Funcionalidades Interativas**

Você poderá testar:

- ✅ **Ver detalhes** de projetos e imagens
- ⏸️ **Pausar** projeto (Estação Sé ou Linha 6)
- ✅ **Concluir** projeto (Pátio Jabaquara)
- ❌ **Excluir** projeto (qualquer um)
- 🗑️ **Deletar** imagem (qualquer uma)
- 🔄 **Reprocessar** análise (se houver erro)
- 📍 **Ver localização** no mapa (imagens com GPS)

---

## 📊 Estrutura dos Dados

### **Projetos (`projects`)**

```json
{
  "id": "proj_001_estacao_se",
  "name": "Estação Sé - Linha 1 Azul",
  "description": "Reforma e modernização...",
  "location": "Praça da Sé, s/n - Sé, São Paulo - SP",
  "startDate": Timestamp,
  "expectedEndDate": Timestamp,
  "status": "em_andamento",
  "responsibleEngineers": ["Eng. Carlos Silva", "Eng. Maria Santos"],
  "bimData": {...},
  "userId": "user_teste_001",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### **Registros de Imagens (`image_records`)**

```json
{
  "id": "img_001_fundacao_se",
  "projectId": "proj_001_estacao_se",
  "capturePointId": "cp_se_fundacao_01",
  "imageUrl": "data:image/jpeg;base64,...",
  "thumbnailUrl": "data:image/jpeg;base64,...",
  "imageBase64": "...",
  "captureDate": Timestamp,
  "capturedBy": "user_teste_001",
  "capturedByName": "teste",
  "latitude": -23.5505,
  "longitude": -46.6333,
  "constructionPhase": "Fundação",
  "metadata": {...},
  "analysisStatus": "completed",
  "analysisId": "analysis_001",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### **Análises (`analyses`)**

```json
{
  "id": "analysis_001",
  "imageRecordId": "img_001_fundacao_se",
  "projectId": "proj_001_estacao_se",
  "analysisDate": Timestamp,
  "status": "completed",
  "geminiResponse": {...},
  "detectedElements": [...],
  "identifiedIssues": [...],
  "progressEstimate": 17.5,
  "comparisonWithBIM": "...",
  "deviations": {...},
  "createdAt": Timestamp
}
```

---

## 🔧 Troubleshooting

### **Erro: "Cannot find module 'firebase-admin'"**

**Solução:**
```bash
npm install firebase-admin
```

### **Erro: "ENOENT: no such file or directory, open 'serviceAccountKey.json'"**

**Solução:**
1. Baixe a chave de serviço do Firebase
2. Salve como `serviceAccountKey.json` no diretório `demo_metro_sp`

### **Erro: "Permission denied"**

**Solução:**
- Verifique se a conta de serviço tem permissões de **Editor** ou **Proprietário** no projeto Firebase

### **Imagens não aparecem no app**

**Solução:**
- Verifique se o campo `imageBase64` está preenchido
- Confirme que o app está lendo de `imageBase64` e não de `imageUrl` (URL externa)

### **Análises não aparecem**

**Solução:**
- Verifique se o `analysisId` em `image_records` corresponde ao `id` em `analyses`
- Confirme que o status da análise é `"completed"`

---

## 📝 Notas Importantes

- **Usuário:** Todos os dados estão associados ao `userId`: `user_teste_001`. Faça login com este usuário para ver os dados.
- **Geolocalização:** As coordenadas são reais e correspondem às localizações dos projetos em São Paulo.
- **Imagens:** As imagens são de obras reais de construção civil, mas não necessariamente do Metrô de São Paulo.
- **Análises:** As análises foram geradas manualmente para demonstração, mas seguem o formato esperado do Gemini.

---

## 🎉 Conclusão

Com esta demonstração, você pode explorar todas as funcionalidades do app Metro SP:

- ✅ Gerenciar projetos
- ✅ Capturar e visualizar imagens
- ✅ Ver análises de IA
- ✅ Pausar, concluir e excluir projetos
- ✅ Deletar e reprocessar imagens
- ✅ Ver localização no mapa
- ✅ Acompanhar progresso da obra

Aproveite a demonstração! 🚀
