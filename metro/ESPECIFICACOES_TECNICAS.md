### 3.3. Tecnologias e Ferramentas

- **Linguagem de Programação e Framework de Desenvolvimento:** Dart com Flutter para o desenvolvimento de uma aplicação multiplataforma (web, desktop e mobile).

- **Inteligência Artificial:** Google Gemini AI para processamento e análise de imagens, detecção de objetos e integração com as funcionalidades de visão computacional.

- **BIM:** Autodesk Revit com exportação de modelos em formato IFC (Industry Foundation Classes) para integração com o sistema.

- **Varredura 3D:** Dispositivos móveis com sensores LiDAR ou câmeras de profundidade (depth cameras) para a captura da realidade do canteiro de obras.

- **Banco de Dados:** Firebase (Firestore para dados estruturados e Firebase Storage para armazenamento de imagens) para o gerenciamento de dados, metadados e arquivos de imagem, oferecendo integração nativa com Flutter e sincronização em tempo real.

### Metodologia Proposta

- **Revisão Bibliográfica Sistematizada:** Análise de artigos, dissertações e patentes relacionados à aplicação de visão computacional, BIM, e inteligência artificial na construção civil, com foco em monitoramento de obras. A revisão incluirá também estudos sobre o uso de Flutter em aplicações de engenharia e a utilização de APIs de IA, como a do Google Gemini, para análise de imagens no setor.

- **Proposta de Arquitetura do Sistema:** Definição dos componentes do sistema, incluindo:
  - **Interface de Usuário:** Desenvolvida em Flutter para garantir uma experiência de usuário consistente em múltiplas plataformas (web, desktop e mobile).
  - **Módulo de Captura de Imagens:** Integrado ao aplicativo mobile para permitir a captura de imagens do canteiro de obras.
  - **Módulo de Processamento e Análise:** Firebase Cloud Functions (serverless) que recebe as imagens capturadas do Firebase Storage e as envia para a API do Google Gemini AI para processamento. Este módulo será responsável por interpretar os resultados da IA e correlacioná-los com os dados do projeto armazenados no Firestore.
  - **Integração com Plataforma BIM:** O sistema irá consumir os dados do modelo BIM através da leitura e parsing de arquivos IFC utilizando bibliotecas específicas no Flutter, permitindo comparar o que foi planejado com o que foi executado, com base na análise das imagens.

- **Desenvolvimento do Módulo de Análise de Imagens com Gemini AI:** Em vez de desenvolver e treinar modelos de deep learning do zero, a abordagem será a de utilizar a API do Google Gemini AI. As imagens capturadas serão enviadas para a API, que será utilizada para tarefas como detecção de objetos (identificação de elementos estruturais, equipamentos, etc.), classificação de cenas e extração de informações relevantes para o monitoramento da obra.

- **Integração com Plataforma BIM:** A integração será realizada através do parsing de arquivos IFC diretamente no aplicativo Flutter. O sistema irá carregar os dados do modelo BIM e sobrepô-los ou compará-los com as informações extraídas das imagens pela Gemini AI, permitindo a identificação de desvios e o acompanhamento do progresso da construção.

- **Validação por Simulação ou Estudo de Caso:** A solução será validada através da sua aplicação em um ambiente de simulação ou em uma obra real. Serão avaliados o desempenho do sistema na detecção de elementos e na comparação com o modelo BIM, a usabilidade da interface desenvolvida em Flutter e o impacto da ferramenta na gestão e fiscalização da obra.

