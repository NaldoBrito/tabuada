import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo Educativo Infantil',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'ComicSans',
      ),
      home: ConfiguracaoJogo(),
    );
  }
}

class ConfiguracaoJogo extends StatefulWidget {
  @override
  _ConfiguracaoJogoState createState() => _ConfiguracaoJogoState();
}

class _ConfiguracaoJogoState extends State<ConfiguracaoJogo> {
  final TextEditingController _pontosController = TextEditingController(text: '20');
  final TextEditingController _tempoController = TextEditingController(text: '15');
  final TextEditingController _recompensaController = TextEditingController(text: 'Brinquedo');

  void _iniciarJogo() {
    final pontosParaGanhar = int.tryParse(_pontosController.text) ?? 20;
    final tempoPorResposta = int.tryParse(_tempoController.text) ?? 15;
    final recompensa = _recompensaController.text.isNotEmpty ? _recompensaController.text : 'Brinquedo';

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => JogoEducativo(pontosParaGanhar: pontosParaGanhar, tempoPorResposta: tempoPorResposta, recompensa: recompensa),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuração do Jogo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pontosController,
              decoration: InputDecoration(
                labelText: 'Pontos para ganhar',
                labelStyle: TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 15),
            TextField(
              controller: _tempoController,
              decoration: InputDecoration(
                labelText: 'Tempo por resposta (segundos)',
                labelStyle: TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 15),
            TextField(
              controller: _recompensaController,
              decoration: InputDecoration(
                labelText: 'Recompensa',
                labelStyle: TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _iniciarJogo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text('Iniciar Jogo'),
            ),
          ],
        ),
      ),
    );
  }
}

class JogoEducativo extends StatefulWidget {
  final int pontosParaGanhar;
  final int tempoPorResposta;
  final String recompensa;

  JogoEducativo({required this.pontosParaGanhar, required this.tempoPorResposta, required this.recompensa});

  @override
  _JogoEducativoState createState() => _JogoEducativoState();
}

class _JogoEducativoState extends State<JogoEducativo> {
  int pontos = 10;
  int num1 = 0;
  int num2 = 0;
  String operacao = '*';
  int respostaCorreta = 0;
  int? respostaUsuario;
  Timer? _timer;
  late int _tempoRestante;
  int perguntasCorretas = 0;
  int perguntasErradas = 0;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    gerarPergunta();
    iniciarTemporizador();
  }

  void gerarPergunta() {
    Random random = Random();
    num1 = random.nextInt(10) + 1;
    num2 = random.nextInt(10) + 1;

    if (random.nextBool()) {
      operacao = '*';
      respostaCorreta = num1 * num2;
    } else {
      operacao = '/';
      respostaCorreta = num1;
      num1 = num1 * num2;
    }
  }

  void iniciarTemporizador() {
    _tempoRestante = widget.tempoPorResposta;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_tempoRestante > 0) {
          _tempoRestante--;
        } else {
          perderPonto();
        }
      });
    });
  }

  void verificarResposta() {
    setState(() {
      if (respostaUsuario != null && respostaUsuario == respostaCorreta) {
        perguntasCorretas++;
        ganharPonto();
        _mostrarAnimacaoAcerto();
      } else {
        perguntasErradas++;
        perderPonto();
        _mostrarAnimacaoErro();
      }
      _controller.clear();
      respostaUsuario = null;
    });
  }

  void ganharPonto() {
    setState(() {
      pontos++;
      if (pontos >= widget.pontosParaGanhar) {
        mostrarMensagemFinal('Parabéns! Você ganhou! Você ganhou: ${widget.recompensa}\nAcertos: $perguntasCorretas\nErros: $perguntasErradas');
      } else {
        gerarPergunta();
        iniciarTemporizador();
      }
    });
  }

  void perderPonto() {
    setState(() {
      pontos--;
      if (pontos <= 0) {
        mostrarMensagemFinal('Você perdeu. Tente novamente!\nAcertos: $perguntasCorretas\nErros: $perguntasErradas');
      } else {
        gerarPergunta();
        iniciarTemporizador();
      }
    });
  }

  void mostrarMensagemFinal(String mensagem) {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mensagem),
        actions: [
          TextButton(
            child: Text('Reiniciar'),
            onPressed: () {
              Navigator.of(context).pop();
              reiniciarJogo();
            },
          )
        ],
      ),
    );
  }

  void reiniciarJogo() {
    setState(() {
      pontos = 10;
      perguntasCorretas = 0;
      perguntasErradas = 0;
      gerarPergunta();
      iniciarTemporizador();
    });
  }

  void _mostrarAnimacaoAcerto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Correto!', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  void _mostrarAnimacaoErro() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Errado!', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jogo Educativo Infantil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Pontuação: $pontos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 10),
            Stack(
              children: [
                LinearProgressIndicator(
                  value: _tempoRestante / widget.tempoPorResposta,
                  backgroundColor: Colors.redAccent,
                  color: Colors.greenAccent,
                  minHeight: 20,
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('$_tempoRestante segundos restantes', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Quanto é: $num1 $operacao $num2 ?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                respostaUsuario = int.tryParse(value);
              },
              decoration: InputDecoration(
                labelText: 'Sua resposta',
                labelStyle: TextStyle(fontSize: 20, color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text('Confirmar', style: TextStyle(fontSize: 18)),
              onPressed: verificarResposta,
            )
          ],
        ),
      ),
    );
  }
}
