import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SilverTraderApp());
}

class SilverTraderApp extends StatelessWidget {
  const SilverTraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silver Trader Albion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
      home: const OrderFormScreen(),
    );
  }
}

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _characterController = TextEditingController();
  final _silverController = TextEditingController();
  final _testPhoneController = TextEditingController(
    text: '5584996066735',
  ); // SEU NÚMERO PARA TESTES

  String _server = 'América';
  DateTime _deliveryDate = DateTime.now();
  bool _isLoading = false;
  bool _testMode = false;

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final message = '''
✅ *NOVO PEDIDO DE PRATA - ALBION ONLINE* ✅

▪ *Personagem:* ${_characterController.text}
▪ *Servidor:* $_server
▪ *Quantidade:* ${_silverController.text}m
▪ *Valor Total:* R\$ ${int.parse(_silverController.text) * 2}
▪ *Data de Entrega:* ${_deliveryDate.day}/${_deliveryDate.month}/${_deliveryDate.year}

ℹ️ *INSTRUÇÕES:*
1. Efetue o PIX para a chave: (SUA_CHAVE_PIX)
2. Envie o comprovante por aqui
3. Aguarde a confirmação

⏳ *Entrega em até 30 minutos após confirmação*
      ''';

      final phoneNumber =
          _testMode ? _testPhoneController.text : '558499606635';
      final whatsappUrl =
          'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

      if (!await launchUrl(Uri.parse(whatsappUrl))) {
        throw Exception('Não foi possível abrir o WhatsApp');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido enviado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _deliveryDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Silver Trader Albion'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Modo Teste'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SwitchListTile(
                            title: const Text('Ativar Modo Teste'),
                            value: _testMode,
                            onChanged:
                                (value) => setState(() => _testMode = value),
                          ),
                          if (_testMode) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _testPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Seu número para teste',
                                hintText: '55DDDNUMERO',
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width > 600 ? 32 : 16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            size: 50,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pedido de Prata Albion',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _characterController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Personagem',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Digite o nome do personagem'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _server,
                    items:
                        ['América', 'Europa'].map((server) {
                          return DropdownMenuItem(
                            value: server,
                            child: Text(server),
                          );
                        }).toList(),
                    onChanged: (value) => setState(() => _server = value!),
                    decoration: const InputDecoration(
                      labelText: 'Servidor',
                      prefixIcon: Icon(Icons.public),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _silverController,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade (em milhões)',
                      prefixIcon: Icon(Icons.monetization_on),
                      suffixText: 'milhões',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Digite a quantidade';
                      if (int.tryParse(value) == null) return 'Número inválido';
                      if (int.parse(value) < 10) return 'Mínimo 10 milhões';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _selectDate(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(
                            'Entrega: ${_deliveryDate.day}/${_deliveryDate.month}/${_deliveryDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'RESUMO DO PEDIDO',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow(
                            'Personagem:',
                            _characterController.text,
                          ),
                          _buildSummaryRow('Servidor:', _server),
                          _buildSummaryRow(
                            'Quantidade:',
                            '${_silverController.text.isEmpty ? '0' : _silverController.text}m',
                          ),
                          _buildSummaryRow('Preço:', 'R\$ 2,00 por 1m'),
                          const Divider(height: 24),
                          _buildSummaryRow(
                            'TOTAL:',
                            'R\$ ${_silverController.text.isEmpty ? '0,00' : (int.tryParse(_silverController.text) ?? 0 * 2).toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green[700],
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'ENVIAR PEDIDO VIA WHATSAPP',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                  if (_testMode) ...[
                    const SizedBox(height: 16),
                    const Card(
                      color: Colors.amber,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'MODO TESTE ATIVO - Mensagens serão enviadas para seu número de teste',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : null,
              fontSize: isTotal ? 16 : null,
            ),
          ),
        ],
      ),
    );
  }
}
