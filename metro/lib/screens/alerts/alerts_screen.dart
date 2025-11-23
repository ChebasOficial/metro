import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../services/alert_service.dart';
import '../../models/alert_model.dart';

class AlertsScreen extends StatefulWidget {
  final String? projectId;
  final String? projectName;
  
  const AlertsScreen({super.key, this.projectId, this.projectName});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final _alertService = AlertService();
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName != null 
            ? 'Alertas - ${widget.projectName}' 
            : 'Alertas'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(AppConfig.paddingNormal),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos', 'all'),
                  const SizedBox(width: AppConfig.paddingSmall),
                  _buildFilterChip('Crítico', 'critical'),
                  const SizedBox(width: AppConfig.paddingSmall),
                  _buildFilterChip('Alto', 'high'),
                  const SizedBox(width: AppConfig.paddingSmall),
                  _buildFilterChip('Médio', 'medium'),
                  const SizedBox(width: AppConfig.paddingSmall),
                  _buildFilterChip('Baixo', 'low'),
                ],
              ),
            ),
          ),

          // Lista de alertas
          Expanded(
            child: StreamBuilder<List<AlertModel>>(
              stream: widget.projectId != null
                  ? _alertService.getProjectAlerts(widget.projectId!)
                  : _alertService.getAllAlerts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro: ${snapshot.error}'),
                  );
                }

                // Aplicar filtro de severidade em memória
                var alerts = snapshot.data ?? [];
                if (_selectedFilter != 'all') {
                  alerts = alerts.where((alert) {
                    final severity = alert.severity.toLowerCase();
                    switch (_selectedFilter) {
                      case 'critical':
                        return severity == 'crítica' || severity == 'critical';
                      case 'high':
                        return severity == 'alta' || severity == 'high';
                      case 'medium':
                        return severity == 'média' || severity == 'media' || severity == 'medium';
                      case 'low':
                        return severity == 'baixa' || severity == 'low';
                      default:
                        return true;
                    }
                  }).toList();
                }

                if (alerts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: Colors.green[300],
                        ),
                        const SizedBox(height: AppConfig.paddingNormal),
                        Text(
                          'Nenhum alerta encontrado',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: AppConfig.paddingSmall),
                        Text(
                          'Tudo está funcionando bem!',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppConfig.paddingNormal),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    return _AlertCard(alert: alerts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _selectedFilter = value);
      },
      selectedColor: AppConfig.primaryColor.withOpacity(0.2),
      checkmarkColor: AppConfig.primaryColor,
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;

  const _AlertCard({required this.alert});

  Color _getSeverityColor() {
    switch (alert.severity) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon() {
    switch (alert.severity) {
      case 'critical':
        return Icons.error;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.notifications;
      default:
        return Icons.circle;
    }
  }

  String _getSeverityLabel() {
    switch (alert.severity) {
      case 'critical':
        return 'CRÍTICO';
      case 'high':
        return 'ALTO';
      case 'medium':
        return 'MÉDIO';
      case 'low':
        return 'BAIXO';
      default:
        return alert.severity.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConfig.paddingNormal),
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.paddingNormal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getSeverityColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getSeverityIcon(),
                    color: _getSeverityColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConfig.paddingNormal),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getSeverityLabel(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConfig.paddingNormal),
            Text(
              alert.description,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: AppConfig.paddingSmall),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(alert.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours} horas';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}

