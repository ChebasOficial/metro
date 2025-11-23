# 🚇 Demonstração Completa - App Metro SP

Este diretório contém uma demonstração completa do aplicativo Metro SP, com dados de exemplo, imagens e arquivos binários para mostrar todas as funcionalidades do app em ação.

---

## 📂 Estrutura de Arquivos

```
/demo_metro_sp
├── 📂 bin/                     # Arquivos binários e dados completos
│   ├── 📄 demo_data_complete.json  (20 MB) - Todos os dados em um único arquivo
│   ├── 📄 projects.bin.json
│   ├── 📄 image_records.bin.json
│   └── 📄 analyses.bin.json
├── 📂 data/                    # Dados de exemplo em formato JSON
│   ├── 📄 projects.json
│   ├── 📄 image_records.json
│   └── 📄 analyses.json
├── 📂 images/                   # Imagens de obras para demonstração
│   ├── 🖼️ obra1_fundacao.jpg
│   ├── 🖼️ obra2_estrutura.jpg
│   ├── 🖼️ obra3_alvenaria.jpg
│   └── 🖼️ obra4_acabamento.jpg
│   ├── 📄 obra1_fundacao.b64
│   ├── 📄 obra2_estrutura.b64
│   ├── 📄 obra3_alvenaria.b64
│   └── 📄 obra4_acabamento.b64
├── 🐍 generate_demo_data.py    # Script para gerar os dados
└── 📖 README.md                  # Este arquivo
```

---

## 📊 Conteúdo dos Dados

### **Projetos (`projects.json`)**

- **4 projetos** de exemplo:
  - 1️⃣ **Estação Sé - Linha 1 Azul** (em andamento)
  - 2️⃣ **Linha 6 - Laranja** (em andamento)
  - 3️⃣ **Pátio Jabaquara** (pausado)
  - 4️⃣ **Estação Vila Sônia** (concluído)

### **Registros de Imagens (`image_records.json`)**

- **4 imagens** de obras, uma para cada fase:
  - 🖼️ **Fundação** (Estação Sé)
  - 🖼️ **Estrutura** (Estação Sé)
  - 🖼️ **Alvenaria** (Linha 6)
  - 🖼️ **Acabamento** (Linha 6)
- Inclui metadados como geolocalização, fase da obra, e notas.

### **Análises de IA (`analyses.json`)**

- **4 análises** geradas pelo Gemini, uma para cada imagem:
  - Detecção de elementos (pilares, vigas, etc.)
  - Identificação de problemas
  - Estimativa de progresso
  - Comparação com modelo BIM

---

## 🚀 Como Usar

### **1. Importar para o Firebase**

Para usar estes dados no app, você pode importá-los para o seu projeto do Firebase:

1. **Acesse o Firestore:**
   - Vá para o seu projeto no [console do Firebase](https://console.firebase.google.com/).
   - Selecione "Firestore Database".

2. **Crie as Coleções:**
   - `projects`
   - `image_records`
   - `analyses`

3. **Importe os Dados:**
   - Para cada coleção, importe os dados dos arquivos JSON correspondentes em `/data`.
   - **Atenção:** Você precisará de um script para converter os JSONs para o formato de importação do Firestore.

### **2. Usar no App**

- Após importar os dados, o app Metro SP irá carregar e exibir todos os projetos, imagens e análises automaticamente.
- Você poderá testar todas as funcionalidades:
  - Ver detalhes dos projetos
  - Navegar pela galeria de imagens
  - Ver análises de IA
  - Pausar, concluir e excluir projetos
  - Deletar e reprocessar imagens

---

## 🤖 Geração dos Dados

Os dados foram gerados pelo script `generate_demo_data.py`, que:

1. 📸 Carrega as imagens de `/images`.
2. 🔄 Converte para base64.
3. 📄 Lê os templates JSON de `/data`.
4. ✍️ Insere o base64 nas imagens.
5. 💾 Salva os arquivos completos em `/bin`.

Para executar o script:

```bash
cd /home/ubuntu/demo_metro_sp
python3 generate_demo_data.py
```

---

## 📝 Notas

- **Tamanho dos Dados:** O arquivo `demo_data_complete.json` tem **20 MB** devido às imagens em base64.
- **Formato:** Os dados estão em formato JSON para facilitar a leitura e importação.
- **Usuário:** Todos os dados estão associados ao `userId`: `user_teste_001`.

Esta demonstração oferece uma visão completa e realista de como o app Metro SP funciona com dados reais. Explore os arquivos para entender a estrutura e o conteúdo de cada coleção.
