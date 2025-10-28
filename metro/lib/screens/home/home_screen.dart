import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/project_service.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../config/app_config.dart';
import '../auth/login_screen.dart';
import '../projects/projects_list_screen.dart';
import '../projects/project_detail_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _projectService = ProjectService();
  
  int _selectedIndex = 0;
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      UserModel? user = await _authService.getUserData(firebaseUser.uid);
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<Widget> pages = [
      _DashboardPage(currentUser: _currentUser),
      const ProjectsListScreen(),
      ProfileScreen(currentUser: _currentUser),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metro SP - Monitoramento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).pushNamed('/alerts');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction),
            label: 'Projetos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.errorColor,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }
}

class _DashboardPage extends StatelessWidget {
  final UserModel? currentUser;

  const _DashboardPage({this.currentUser});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.paddingNormal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saudação
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConfig.paddingNormal),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppConfig.primaryColor,
                    child: Text(
                      currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: AppConfig.textSizeXLarge,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConfig.paddingNormal),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${currentUser?.name ?? 'Usuário'}!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          currentUser?.role.toUpperCase() ?? 'VISUALIZADOR',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConfig.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConfig.paddingLarge),

          // Estatísticas Rápidas
          Text(
            'Visão Geral',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConfig.paddingNormal),
          
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.construction,
                  title: 'Projetos Ativos',
                  value: '0',
                  color: AppConfig.primaryColor,
                ),
              ),
              const SizedBox(width: AppConfig.paddingNormal),
              Expanded(
                child: _StatCard(
                  icon: Icons.camera_alt,
                  title: 'Imagens Hoje',
                  value: '0',
                  color: AppConfig.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConfig.paddingNormal),
          
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.warning,
                  title: 'Alertas Abertos',
                  value: '0',
                  color: AppConfig.warningColor,
                ),
              ),
              const SizedBox(width: AppConfig.paddingNormal),
              Expanded(
                child: _StatCard(
                  icon: Icons.analytics,
                  title: 'Análises',
                  value: '0',
                  color: AppConfig.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConfig.paddingLarge),

          // Ações Rápidas
          Text(
            'Ações Rápidas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConfig.paddingNormal),
          
          if (currentUser?.canCaptureImages ?? false) ...[
            _ActionButton(
              icon: Icons.camera_alt,
              label: 'Capturar Imagem',
              color: AppConfig.primaryColor,
              onTap: () {
                Navigator.of(context).pushNamed('/capture');
              },
            ),
            const SizedBox(height: AppConfig.paddingSmall),
          ],
          
          _ActionButton(
            icon: Icons.construction,
            label: 'Ver Todos os Projetos',
            color: AppConfig.secondaryColor,
            onTap: () {
              // Navegar para lista de projetos
            },
          ),
          const SizedBox(height: AppConfig.paddingSmall),
          
          _ActionButton(
            icon: Icons.photo_library,
            label: 'Galeria de Imagens',
            color: AppConfig.accentColor,
            onTap: () {
              Navigator.of(context).pushNamed('/gallery');
            },
          ),
          const SizedBox(height: AppConfig.paddingSmall),
          
          _ActionButton(
            icon: Icons.warning,
            label: 'Ver Alertas',
            color: AppConfig.warningColor,
            onTap: () {
              Navigator.of(context).pushNamed('/alerts');
            },
          ),
          const SizedBox(height: AppConfig.paddingSmall),
          
          _ActionButton(
            icon: Icons.psychology,
            label: 'Análises de IA',
            color: Colors.purple,
            onTap: () {
              Navigator.of(context).pushNamed('/analyses');
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.paddingNormal),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppConfig.paddingSmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

