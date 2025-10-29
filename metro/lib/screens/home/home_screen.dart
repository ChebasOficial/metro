import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../profile/profile_screen.dart';
import '../../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _DashboardPage(),
      const _ProjectsPage(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metro SP - Monitoramento de Obras'),
        backgroundColor: AppConfig.primaryColor,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              MyApp.of(context)?.toggleTheme();
            },
            tooltip: 'Alternar tema',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
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
}

// Página temporária de projetos
class _ProjectsPage extends StatelessWidget {
  const _ProjectsPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Projetos', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/projects'),
            child: const Text('Ver Todos os Projetos'),
          ),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatefulWidget {
  const _DashboardPage();

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  int _activeProjects = 0;
  int _imagesToday = 0;
  int _openAlerts = 0;
  int _totalAnalyses = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarrega as estatísticas sempre que a tela se torna visível
    if (ModalRoute.of(context)?.isCurrent == true) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    print('==========================================');
    print('=== CARREGANDO ESTATÍSTICAS DO DASHBOARD ===');
    print('==========================================');
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ ERRO: Usuário não está logado!');
        return;
      }
      
      print('✅ Usuário logado: ${currentUser.email}');
      print('✅ UID: ${currentUser.uid}');
      
      // 1. Contar projetos ativos
      print('\n--- BUSCANDO PROJETOS ---');
      final projectsSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      
      print('Total de projetos encontrados: ${projectsSnapshot.docs.length}');
      
      int activeProjects = 0;
      for (var doc in projectsSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? '';
        final name = data['name'] ?? 'Sem nome';
        print('  Projeto: $name - Status: $status');
        if (status == 'em_andamento') {
          activeProjects++;
        }
      }
      print('Projetos ativos (em_andamento): $activeProjects');
      
      // 2. Contar imagens de hoje
      print('\n--- BUSCANDO IMAGENS DE HOJE ---');
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      print('Início do dia: $startOfDay');
      print('Agora: $now');
      
      final imagesSnapshot = await FirebaseFirestore.instance
          .collection('image_records')
          .get();
      
      print('Total de imagens no banco: ${imagesSnapshot.docs.length}');
      
      int imagesToday = 0;
      for (var doc in imagesSnapshot.docs) {
        final data = doc.data();
        final captureDate = (data['captureDate'] as Timestamp?)?.toDate();
        if (captureDate != null) {
          print('  Imagem: ${doc.id} - Data: $captureDate');
          if (captureDate.isAfter(startOfDay)) {
            imagesToday++;
            print('    ✅ É de hoje!');
          }
        }
      }
      print('Imagens capturadas hoje: $imagesToday');
      
      // 3. Contar alertas abertos
      print('\n--- BUSCANDO ALERTAS ABERTOS ---');
      final alertsSnapshot = await FirebaseFirestore.instance
          .collection('alerts')
          .where('status', isEqualTo: 'open')
          .get();
      print('Alertas abertos: ${alertsSnapshot.docs.length}');
      
      // 4. Contar análises
      print('\n--- BUSCANDO ANÁLISES ---');
      final analysesSnapshot = await FirebaseFirestore.instance
          .collection('analyses')
          .get();
      print('Total de análises: ${analysesSnapshot.docs.length}');
      
      print('\n==========================================');
      print('=== RESUMO DAS ESTATÍSTICAS ===');
      print('Projetos Ativos: $activeProjects');
      print('Imagens Hoje: $imagesToday');
      print('Alertas Abertos: ${alertsSnapshot.docs.length}');
      print('Análises: ${analysesSnapshot.docs.length}');
      print('==========================================\n');
      
      setState(() {
        _activeProjects = activeProjects;
        _imagesToday = imagesToday;
        _openAlerts = alertsSnapshot.docs.length;
        _totalAnalyses = analysesSnapshot.docs.length;
        _isLoading = false;
      });
      
      print('✅ Estado atualizado com sucesso!');
      
    } catch (e, stackTrace) {
      print('\n❌ ERRO AO CARREGAR ESTATÍSTICAS:');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visão Geral',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard(
                icon: Icons.construction,
                value: _activeProjects.toString(),
                label: 'Projetos Ativos',
                color: Colors.blue,
              ),
              _buildStatCard(
                icon: Icons.photo_camera,
                value: _imagesToday.toString(),
                label: 'Imagens Hoje',
                color: Colors.green,
              ),
              _buildStatCard(
                icon: Icons.warning,
                value: _openAlerts.toString(),
                label: 'Alertas Abertos',
                color: Colors.orange,
              ),
              _buildStatCard(
                icon: Icons.analytics,
                value: _totalAnalyses.toString(),
                label: 'Análises',
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            'Ações',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2,
            children: [
              _ActionButton(
                icon: Icons.camera_alt,
                label: 'Capturar',
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/capture'),
              ),
              _ActionButton(
                icon: Icons.photo_library,
                label: 'Galeria',
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, '/gallery'),
              ),
              _ActionButton(
                icon: Icons.warning_amber,
                label: 'Alertas',
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, '/alerts'),
              ),
              _ActionButton(
                icon: Icons.bar_chart,
                label: 'Análises',
                color: Colors.purple,
                onTap: () => Navigator.pushNamed(context, '/analyses'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
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
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

