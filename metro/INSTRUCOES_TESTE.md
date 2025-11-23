# 📋 Instruções de Teste - Metro SP

## 🎯 Objetivo

Este documento contém instruções para testar o aplicativo Metro SP com dados de demonstração completos.

## ✅ Verificações Necessárias

### 1. Inicialização do DemoDataService

O `DemoDataService` deve ser inicializado no `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar dados demo
  await DemoDataService().initialize();
  
  // Restante da inicialização...
}
```

### 2. Dados de Demonstração Incluídos

O app contém os seguintes dados demo nos assets:

#### Projetos (4 projetos)
- **Estação Sé** - Em andamento (75% concluído)
- **Linha 6 Laranja** - Em andamento (45% concluído)
- **Pátio Jabaquara** - Pausado (60% concluído)
- **Estação Vila Sônia** - Concluído (100%)

#### Imagens (4 imagens com análises)
- Fundação - Estação Sé
- Estrutura - Estação Sé
- Alvenaria - Linha 6 Laranja
- Acabamento - Linha 6 Laranja

#### Análises de IA (4 análises)
- Análise de fundação (sucesso)
- Análise de estrutura (com alerta de qualidade)
- Análise de alvenaria (com alerta de segurança)
- Análise de acabamento (sucesso)

#### Alertas (3 alertas)
- **Alta severidade**: Desvio na fundação (15cm) - Aberto
- **Média severidade**: Segregação no concreto - Em análise
- **Alta severidade**: Falta de EPI - Resolvido

### 3. Funcionalidades a Testar

#### Dashboard
- [ ] Mostra 4 projetos ativos (incluindo demo)
- [ ] Estatísticas corretas de imagens e análises
- [ ] Gráfico de progresso dos projetos
- [ ] Lista de alertas recentes

#### Lista de Projetos
- [ ] Exibe todos os 4 projetos demo
- [ ] Mostra status correto (em andamento, pausado, concluído)
- [ ] Percentual de progresso visível
- [ ] Ícones e cores corretos por status

#### Detalhes do Projeto
- [ ] Informações completas do projeto
- [ ] Galeria de imagens do projeto
- [ ] Lista de alertas do projeto
- [ ] Mapa com localização

#### Galeria de Imagens
- [ ] Exibe todas as 4 imagens demo
- [ ] Miniaturas carregam corretamente
- [ ] Metadados GPS visíveis
- [ ] Data/hora de captura corretas

#### Análises de IA
- [ ] Análises vinculadas às imagens
- [ ] Resultados detalhados visíveis
- [ ] Confiança da análise exibida
- [ ] Recomendações presentes

#### Alertas
- [ ] 3 alertas demo visíveis
- [ ] Severidade correta (alta, média)
- [ ] Status correto (aberto, em análise, resolvido)
- [ ] Detalhes completos do alerta

### 4. Modo Híbrido (Demo + Firebase)

O app deve funcionar em modo híbrido:

- **Sem conexão/login**: Mostra apenas dados demo
- **Com login**: Mostra dados demo + dados do usuário
- Dados demo não devem ser salvos no Firebase
- Dados demo devem ser somente leitura

### 5. Configuração da API Gemini

Para usar análise de IA em novas imagens:

1. Obter chave API do Google AI Studio: https://makersuite.google.com/app/apikey
2. Configurar no arquivo `lib/services/gemini_service.dart`:

```dart
static const String _apiKey = 'SUA_CHAVE_API_AQUI';
```

### 6. Testes Offline

Para testar modo offline:

1. Desabilitar conexão de rede no dispositivo
2. Abrir o app sem fazer login
3. Verificar se os 4 projetos demo aparecem
4. Navegar pelas telas e verificar funcionalidades
5. Todas as imagens demo devem carregar dos assets

## 🐛 Problemas Conhecidos e Soluções

### Problema: Dashboard mostra contagem errada

**Sintoma**: Dashboard mostra "3 Projetos Ativos" mas lista mostra apenas 1

**Causa**: DemoDataService não está sendo inicializado no main.dart

**Solução**: Adicionar inicialização no main.dart antes de runApp()

### Problema: Projetos demo não aparecem

**Sintoma**: Apenas projetos criados pelo usuário aparecem na lista

**Causa**: ProjectService não está combinando dados demo + Firebase

**Solução**: Verificar se ProjectService.getProjects() inclui DemoDataService().demoProjects

### Problema: Imagens demo não carregam

**Sintoma**: Miniaturas aparecem vazias ou com erro

**Causa**: Assets não foram incluídos no pubspec.yaml

**Solução**: Verificar se pubspec.yaml contém:
```yaml
assets:
  - assets/demo/data/
  - assets/demo/images/
```

### Problema: Alertas não aparecem

**Sintoma**: Nenhum alerta visível no dashboard ou detalhes do projeto

**Causa**: AlertService não está carregando alertas demo

**Solução**: Verificar se AlertService inclui DemoDataService().demoAlerts

## 📱 Fluxo de Teste Recomendado

1. **Primeiro acesso (offline)**
   - Abrir app sem login
   - Verificar 4 projetos demo na lista
   - Abrir cada projeto e verificar detalhes
   - Ver imagens e análises

2. **Criar conta e login**
   - Fazer cadastro/login
   - Verificar que projetos demo ainda aparecem
   - Criar novo projeto próprio
   - Verificar que novo projeto aparece junto com demos

3. **Testar captura de imagem**
   - Abrir um projeto próprio
   - Capturar nova imagem
   - Verificar se análise de IA funciona (requer API key)
   - Ver resultado da análise

4. **Testar alertas**
   - Ver alertas dos projetos demo
   - Verificar diferentes severidades
   - Testar filtros de status

5. **Testar modo escuro**
   - Alternar tema nas configurações
   - Verificar todas as telas

## 🎨 Dados Demo Detalhados

### Projeto 1: Estação Sé
- **Status**: Em andamento
- **Progresso**: 75%
- **Localização**: Praça da Sé, São Paulo
- **Imagens**: 2 (fundação, estrutura)
- **Alertas**: 2 (desvio BIM, problema qualidade)

### Projeto 2: Linha 6 Laranja
- **Status**: Em andamento
- **Progresso**: 45%
- **Localização**: Brasilândia, São Paulo
- **Imagens**: 2 (alvenaria, acabamento)
- **Alertas**: 1 (segurança - resolvido)

### Projeto 3: Pátio Jabaquara
- **Status**: Pausado
- **Progresso**: 60%
- **Localização**: Jabaquara, São Paulo
- **Imagens**: 0
- **Alertas**: 0

### Projeto 4: Estação Vila Sônia
- **Status**: Concluído
- **Progresso**: 100%
- **Localização**: Vila Sônia, São Paulo
- **Imagens**: 0
- **Alertas**: 0

## 🔧 Comandos Úteis

```bash
# Limpar build
flutter clean

# Obter dependências
flutter pub get

# Executar em modo debug
flutter run

# Executar em modo release
flutter run --release

# Verificar problemas
flutter doctor

# Ver logs
flutter logs
```

## 📞 Suporte

Para problemas ou dúvidas, verificar:
1. Console de debug do Flutter
2. Logs do DemoDataService (procurar por ✅ ou ❌)
3. Arquivo README.md do projeto
