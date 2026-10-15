
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Contadores das metas
  int aguaConsumida = 0;
  final int aguaMeta = 2000;

  int passosDados = 0;
  final int passosMeta = 10000;

  int _indiceAba = 0;

  void adicionarAgua(int quantidade) {
    setState(() {
      aguaConsumida += quantidade;
    });
  }

  void adicionarPassos(int quantidade) {
    setState(() {
      passosDados += quantidade;
    });
  }

  double calcularProgresso(int atual, int meta) {
    return (atual / meta).clamp(0.0, 1.0).toDouble();
  }

  int calcularPorcentagem(int atual, int meta) {
    return (calcularProgresso(atual, meta) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quarta-feira, 16 de setembro',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Boa noite 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 24),

              // Card de água
              _cardMeta(
                titulo: '💧 ÁGUA',
                cor: Colors.blue,
                valor: '$aguaConsumida ml',
                descricao: 'Meta: $aguaMeta ml',
                progresso: calcularProgresso(
                  aguaConsumida,
                  aguaMeta,
                ),
                porcentagem: calcularPorcentagem(
                  aguaConsumida,
                  aguaMeta,
                ),
                botoes: [
                  _botaoIncremento(
                    '+150 ml',
                    () => adicionarAgua(150),
                    Colors.blue,
                  ),
                  _botaoIncremento(
                    '+250 ml',
                    () => adicionarAgua(250),
                    Colors.blue,
                  ),
                  _botaoIncremento(
                    '+350 ml',
                    () => adicionarAgua(350),
                    Colors.blue,
                  ),
                  _botaoIncremento(
                    '+500 ml',
                    () => adicionarAgua(500),
                    Colors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Card de passos
              _cardMeta(
                titulo: '👟 PASSOS',
                cor: Colors.green,
                valor: '$passosDados',
                descricao: 'Meta: $passosMeta passos',
                progresso: calcularProgresso(
                  passosDados,
                  passosMeta,
                ),
                porcentagem: calcularPorcentagem(
                  passosDados,
                  passosMeta,
                ),
                botoes: [
                  _botaoIncremento(
                    '+500',
                    () => adicionarPassos(500),
                    Colors.green,
                  ),
                  _botaoIncremento(
                    '+1k',
                    () => adicionarPassos(1000),
                    Colors.green,
                  ),
                  _botaoIncremento(
                    '+2k',
                    () => adicionarPassos(2000),
                    Colors.green,
                  ),
                  _botaoIncremento(
                    '+5k',
                    () => adicionarPassos(5000),
                    Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (aguaConsumida >= aguaMeta)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Incrível! Meta de água atingida hoje.',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (passosDados >= passosMeta) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Parabéns! Meta de passos atingida.',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAba,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            _indiceAba = index;
          });

          if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'A tela de histórico ainda precisa ser implementada.',
                ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Histórico',
          ),
        ],
      ),
    );
  }

  Widget _cardMeta({
    required String titulo,
    required Color cor,
    required String valor,
    required String descricao,
    required double progresso,
    required int porcentagem,
    required List<Widget> botoes,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        color: cor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      valor,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      descricao,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: progresso,
                      strokeWidth: 6,
                      backgroundColor: cor.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(cor),
                    ),
                  ),
                  Text(
                    '$porcentagem%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: botoes,
          ),
        ],
      ),
    );
  }

  Widget _botaoIncremento(
    String texto,
    VoidCallback aoClicar,
    Color cor,
  ) {
    return ElevatedButton(
      onPressed: aoClicar,
      style: ElevatedButton.styleFrom(
        backgroundColor: cor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
