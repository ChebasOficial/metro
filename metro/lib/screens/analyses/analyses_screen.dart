import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../services/gemini_service.dart';
import '../../models/analysis_model.dart';

class AnalysesScreen extends StatefulWidget {
  const AnalysesScreen({super.key});

  @override
  State<AnalysesScreen> createState() => _AnalysesScreenState();
}

class _AnalysesScreenState extends State<AnalysesScreen> {
  final _geminiService = GeminiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análises de IA'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<AnalysisModel>>(
        stream: _geminiService.getAllAnalyses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          }

          final analyses = snapshot.data ?? [];

          if (analyses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppConfig.paddingNormal),
                  Text(
                    'Nenhuma análise encontrada',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: AppConfig.paddingSmall),
                  Text(
                    'As análises aparecerão aqui após o processamento',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConfig.paddingNormal),
            itemCount: analyses.length,
            itemBuilder: (context, index) {
              return _AnalysisCard(analysis: analyses[index]);
            },
          );
        },
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final AnalysisModel analysis;

  const _AnalysisCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConfig.paddingNormal),
      child: ExpansionTile(
        leading: _buildStatusIcon(),
        title: Text(
          'Análise #${analysis.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _formatDate(analysis.analysisDate),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConfig.paddingNormal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resposta da Gemini
                if (analysis.geminiResponse.isNotEmpty) ...[
                  const Text(
                    'Resposta da IA:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    analysis.geminiResponse['rawResponse'] ?? 'Sem resposta',
                    style: TextStyle(color: Colors.grey[700]),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConfig.paddingNormal),
                ],

                // Elementos detectados
                if (analysis.detectedElements.isNotEmpty) ...[
                  const Text(
                    'Elementos Detectados:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...analysis.detectedElements.map((element) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${element.type}: ${element.description} (${(element.confidence * 100).toStringAsFixed(0)}%)',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: AppConfig.paddingNormal),
                ],

                // Problemas identificados
                if (analysis.identifiedIssues.isNotEmpty) ...[
                  const Text(
                    'Problemas Identificados:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...analysis.identifiedIssues.map((issue) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                issue,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: AppConfig.paddingNormal),
                ],

                // Estimativa de progresso
                if (analysis.progressEstimate != null) ...[
                  Row(
                    children: [
                      const Text(
                        'Progresso Estimado: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${analysis.progressEstimate!.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConfig.paddingNormal),
                ],

                // Comparação com BIM
                if (analysis.comparisonWithBIM != null && analysis.comparisonWithBIM!.isNotEmpty) ...[
                  const Text(
                    'Comparação com BIM:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    analysis.comparisonWithBIM!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (analysis.identifiedIssues.isNotEmpty) {
      return const Icon(Icons.warning, color: Colors.red);
    } else if (analysis.status == 'completed') {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else {
      return const Icon(Icons.error, color: Colors.orange);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

