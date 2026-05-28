Você é um desenvolvedor sênior Flutter/Dart e vai criar um aplicativo mobile de controle financeiro completo, funcional e visualmente bem-acabado, seguindo rigorosamente os requisitos abaixo.

OBJETIVO GERAL
Criar um app Flutter de finanças pessoais com arquitetura MVVM, estado reativo, persistência local em SQLite, autenticação com cadastro/login, CRUD de transações e interface moderna, minimalista e light, com destaques verdes inspirados em apps financeiros modernos como o PicPay, sem copiar marca, identidade visual ou telas proprietárias.

CONTEXTO DE DESENVOLVIMENTO
- O projeto será desenvolvido no Visual Studio Code via GitHub Codespaces.
- O app precisa rodar de forma funcional no browser/emulador web e também estar pronto para geração de APK.
- O código deve estar limpo, organizado, escalável e fácil de avaliar academicamente.

REQUISITOS FUNCIONAIS OBRIGATÓRIOS
1. Autenticação
- Criar tela de Login.
- Criar tela de Cadastro.
- Permitir alternância visual entre Login e Cadastro na mesma área da autenticação, com transição fluida.
- Cadastro deve pedir no mínimo: nome, e-mail e senha.
- Login deve pedir e-mail e senha.
- Validar todos os campos.
- Salvar usuários no SQLite.
- Fazer autenticação local real comparando e-mail e senha com os dados salvos no banco.

2. Tela Principal / Dashboard
- Exibir saldo atual calculado automaticamente.
- Exibir total de receitas.
- Exibir total de despesas.
- Exibir histórico resumido das transações recentes.
- Permitir adicionar receita e despesa.
- O saldo deve atualizar em tempo real sempre que uma transação for criada, editada ou removida.

3. Tela de Resultados e Análise
- Criar uma terceira tela dedicada à análise financeira.
- Nessa tela, exibir a lista completa das movimentações e/ou um resumo visual de análise.
- Preferência por gráficos simples e claros, como:
  - gráfico de barras,
  - gráfico de pizza,
  - barras de progresso,
  - indicadores de orçamento.
- A tela deve permitir análise do comportamento financeiro do usuário de forma visual.

4. Operações CRUD
- O usuário deve conseguir:
  - criar transações,
  - listar transações,
  - editar transações,
  - excluir transações.
- Cada transação precisa conter, no mínimo:
  - título,
  - valor,
  - data,
  - tipo (entrada/saída),
  - opcionalmente categoria.
- As ações de adicionar/editar/remover devem ocorrer sem necessidade de troca de rota, preferencialmente via BottomSheet, Dialog ou formulário expansível.

5. Validações
- Usar GlobalKey<FormState>.
- Usar TextFormField com validators.
- Validar:
  - campos vazios,
  - e-mail em formato inválido,
  - senha fraca ou vazia,
  - valor numérico inválido,
  - valor menor ou igual a zero,
  - data ausente ou inválida.
- Exibir feedback visual claro de erro abaixo dos campos.
- Exibir feedback de sucesso quando ações forem concluídas.

6. Persistência local
- Usar SQLite com o pacote sqflite.
- Os dados de usuário e transações não podem ser perdidos ao fechar o app.
- Criar camadas separadas para acesso ao banco, sem misturar SQL com a UI.

7. Estado
- Usar Riverpod para gerenciamento de estado reativo entre telas.
- Se necessário, usar providers, notifier, state notifier, async notifier ou equivalente do Riverpod.
- O estado do usuário autenticado e das transações deve ser centralizado e reativo.

8. Navegação
- Implementar rotas nomeadas e navegação clara entre as 3 telas.
- A navegação entre Login, Cadastro, Dashboard e Análise deve funcionar perfeitamente.
- Após autenticação bem-sucedida, ir para a tela principal.

ARQUITETURA E REGRAS DE CÓDIGO
- Seguir MVVM de forma real e clara.
- Separar o projeto em:
  - models
  - views
  - viewmodels
  - services
  - repositories
  - data/local
  - widgets
  - routes
  - utils
- Não misturar lógica de banco, lógica de validação e interface na mesma camada.
- A View deve conter apenas composição visual e eventos de UI.
- O ViewModel deve conter a lógica de negócio, chamadas aos repositórios e estado da tela.
- O Model deve conter as entidades e conversões de dados.
- O Repository deve ser a ponte entre ViewModel e fonte de dados.
- O Data Source local deve concentrar SQLite.
- O código precisa ser modular e fácil de manter.

ESTRUTURA SUGERIDA DO PROJETO
lib/
  main.dart
  app.dart
  routes/
    app_routes.dart
  core/
    theme/
    constants/
    utils/
    validators/
  data/
    local/
      app_database.dart
      tables/
    repositories/
  models/
    user_model.dart
    transaction_model.dart
  viewmodels/
    auth_viewmodel.dart
    dashboard_viewmodel.dart
    transactions_viewmodel.dart
    analytics_viewmodel.dart
  views/
    auth/
      login_view.dart
      register_view.dart
    dashboard/
      dashboard_view.dart
    analytics/
      analytics_view.dart
  widgets/
    custom_text_field.dart
    summary_card.dart
    transaction_tile.dart
    empty_state.dart
    primary_button.dart

REQUISITOS DE UI/UX
- Interface bonita, minimalista, moderna e limpa.
- Tema light obrigatório.
- Usar verde como cor de destaque principal, remetendo a dinheiro, crescimento e finanças.
- Visual inspirado em apps financeiros modernos, com:
  - cards arredondados,
  - espaçamento confortável,
  - tipografia clara,
  - ícones simples,
  - sombras suaves,
  - botões consistentes,
  - microinterações sutis.
- Material Design deve ser respeitado.
- A experiência deve parecer profissional, fluida e agradável.
- Feedback visual de carregamento, sucesso e erro deve existir.
- Usar skeleton loading ou placeholders se houver carregamento assíncrono.
- Usar animações leves de transição entre telas e componentes.

LÓGICA FINANCEIRA
- O saldo deve ser calculado assim:
  saldo = soma(receitas) - soma(despesas)
- Receitas devem aumentar o saldo.
- Despesas devem reduzir o saldo.
- A lista de transações recentes deve mostrar os itens mais novos primeiro.
- O Dashboard deve atualizar automaticamente quando uma transação mudar.

BANCO DE DADOS
- Usar SQLite via sqflite.
- Persistir:
  - usuários,
  - transações.
- Criar tabelas bem definidas e com chaves primárias.
- Cada transação deve estar vinculada ao usuário autenticado, se fizer sentido no desenho do app.
- Implementar métodos para inserir, buscar, atualizar e remover registros.
- Não usar dados mockados como solução final; o app deve ser funcional de verdade.

VALIDAÇÃO DE AUTENTICAÇÃO
- Cadastro:
  - nome obrigatório,
  - e-mail obrigatório e válido,
  - senha obrigatória com tamanho mínimo.
- Login:
  - e-mail obrigatório e válido,
  - senha obrigatória.
- Se o usuário errar os dados, mostrar mensagem clara na interface.
- Se o cadastro já existir, impedir duplicidade de e-mail.
- Se login estiver correto, autenticar e ir para a home.

REQUISITOS TÉCNICOS
- Usar Flutter com Dart null safety.
- Usar Riverpod.
- Usar sqflite.
- Usar package path para acesso ao banco.
- Usar intl para formatação de moeda e data.
- Para gráficos, se necessário, usar uma biblioteca simples e confiável, como fl_chart.
- O código deve compilar sem erros.
- Não deixar imports desnecessários.
- Não deixar arquivos inúteis, código morto ou placeholders finais como TODO.
- Comentários só quando ajudarem muito na leitura.

REGRAS IMPORTANTES DE IMPLEMENTAÇÃO
- Criar classes e nomes consistentes e em inglês.
- Usar nomes claros para variáveis, métodos e arquivos.
- Não criar lógica duplicada.
- Tratar erros com try/catch nas camadas de acesso a dados.
- Retornar mensagens úteis quando algo falhar.
- Evitar hardcode de strings repetidas: centralizar textos importantes, se possível.
- Evitar setState como solução principal para estado global; usar Riverpod.
- Não usar arquitetura bagunçada ou improvisada.
- Não criar uma UI genérica e sem capricho.

TELAS OBRIGATÓRIAS E COMPORTAMENTO

1. Login/Register
- Tela inicial do app.
- Alternância visual entre entrar e cadastrar.
- Formulários separados ou alternáveis.
- Botões bem destacados.
- Texto auxiliar para orientar o usuário.
- Acesso ao dashboard após autenticação.

2. Dashboard
- Exibir:
  - saldo atual,
  - receitas,
  - despesas,
  - lista resumida de transações,
  - botão de adicionar transação.
- Deve ser a tela principal após login.
- Deve ter navegação para a tela de análise.
- Deve permitir exclusão/edição rápida de transações.

3. Análise / Resultados
- Exibir a visão completa dos dados.
- Mostrar gráficos ou resumo analítico.
- Permitir filtro por tipo de transação, se possível.
- Mostrar total por período ou por categoria, se implementado.
- A UI deve continuar limpa e leve.

ENTREGA ESPERADA
Quero que você gere o projeto completo com:
- estrutura de pastas correta,
- código organizado em MVVM,
- autenticação local funcional,
- CRUD de transações funcional,
- persistência SQLite real,
- estado com Riverpod,
- navegação entre as telas,
- validações de formulário,
- interface moderna e bonita,
- tema light com verde como destaque,
- pronto para execução no Codespaces e adaptação para APK.

CRITÉRIOS DE QUALIDADE
Antes de finalizar, verifique se:
- o app compila,
- as rotas funcionam,
- o login e cadastro funcionam,
- as transações salvam e carregam do SQLite,
- o saldo muda corretamente,
- as validações impedem entradas inválidas,
- a UI está consistente e bonita,
- a estrutura MVVM foi respeitada,
- o estado está reativo e centralizado,
- não há dependências desnecessárias.

IMPORTANTE
Se houver alguma decisão técnica ambígua, priorize sempre:
1. funcionalidade,
2. organização da arquitetura,
3. experiência do usuário,
4. manutenção futura.
Não simplifique demais. Não deixe nada essencial de fora.