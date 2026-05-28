abstract class AppStrings {
  // App
  static const String appName = 'Koins';

  // Auth
  static const String login = 'Entrar';
  static const String register = 'Cadastrar';
  static const String email = 'E-mail';
  static const String password = 'Senha';
  static const String name = 'Nome';
  static const String welcomeBack = 'Bem-vindo de volta!';
  static const String createAccount = 'Crie sua conta';

  // Dashboard
  static const String balance = 'Saldo atual';
  static const String income = 'Receitas';
  static const String expenses = 'Despesas';
  static const String greeting = 'Olá';

  // Transactions
  static const String addTransaction = 'Adicionar transação';
  static const String editTransaction = 'Editar transação';
  static const String title = 'Título';
  static const String amount = 'Valor';
  static const String date = 'Data';
  static const String category = 'Categoria';
  static const String type = 'Tipo';
  static const String incomeType = 'Receita';
  static const String expenseType = 'Despesa';
  static const String recentTransactions = 'Transações recentes';
  static const String noTransactions = 'Nenhuma transação encontrada';
  static const String addFirstTransaction = 'Adicione sua primeira transação!';
  static const String selectDate = 'Selecione uma data';
  static const String viewAll = 'Ver todas';

  // Actions
  static const String save = 'Salvar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Excluir';
  static const String edit = 'Editar';
  static const String confirmDelete = 'Confirmar exclusão';
  static const String confirmDeleteMessage =
      'Tem certeza que deseja excluir esta transação?';
  static const String yes = 'Sim';
  static const String no = 'Não';

  // Navigation
  static const String dashboard = 'Início';
  static const String analytics = 'Análise';
  static const String profile = 'Perfil';
  static const String currency = 'Moedas';

  // Auth feedback
  static const String logout = 'Sair';
  static const String logoutConfirm = 'Deseja realmente sair?';
  static const String loginSuccess = 'Login realizado com sucesso!';
  static const String registerSuccess = 'Cadastro realizado com sucesso!';
  static const String invalidCredentials = 'E-mail ou senha inválidos';
  static const String emailAlreadyExists = 'Este e-mail já está cadastrado';

  // General feedback
  static const String success = 'Sucesso';
  static const String error = 'Erro';
  static const String transactionAdded = 'Transação adicionada com sucesso!';
  static const String transactionUpdated =
      'Transação atualizada com sucesso!';
  static const String transactionDeleted =
      'Transação excluída com sucesso!';

  // Currency
  static const String currencyRates = 'Cotações em tempo real';
  static const String dollar = 'Dólar';
  static const String euro = 'Euro';
  static const String bitcoin = 'Bitcoin';
  static const String convert = 'Converter';
  static const String buyPrice = 'Compra';
  static const String sellPrice = 'Venda';
  static const String variation = 'Variação';
  static const String lastUpdated = 'Última atualização';

  // Analytics
  static const String financialAnalysis = 'Análise financeira';
  static const String expensesByCategory = 'Despesas por categoria';
  static const String incomeVsExpenses = 'Receitas vs Despesas';

  // Profile
  static const String myProfile = 'Meu perfil';
  static const String memberSince = 'Membro desde';
  static const String totalTransactions = 'Total de transações';

  // Categories
  static const String allCategories = 'Todas';
  static const String food = 'Alimentação';
  static const String transport = 'Transporte';
  static const String leisure = 'Lazer';
  static const String health = 'Saúde';
  static const String education = 'Educação';
  static const String salary = 'Salário';
  static const String other = 'Outros';
  static const String housing = 'Moradia';

  // Validation
  static const String fieldRequired = 'Este campo é obrigatório';
  static const String invalidEmail = 'E-mail inválido';
  static const String weakPassword =
      'A senha deve ter pelo menos 6 caracteres';
  static const String invalidAmount = 'Valor inválido';
  static const String amountMustBePositive =
      'O valor deve ser maior que zero';
}
