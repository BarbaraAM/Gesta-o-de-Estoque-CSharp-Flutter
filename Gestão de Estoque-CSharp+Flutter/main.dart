import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() {
  runApp(MyApp());
  HttpOverrides.global = MyHttpOverrides();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Confiar em todos os certificados durante o desenvolvimento
        return true;
      };
  }
}

class Produto {
  final int Iproduto;
  final String Nproduto;
  final int Qntproduto;
  final double Vlrproduto;

  Produto({
    required this.Iproduto,
    required this.Nproduto,
    required this.Qntproduto,
    required this.Vlrproduto,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Estoque",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: EstoqueTab(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CadastroProdutoScreen(),
            ),
          );
        },
        tooltip: 'Cadastrar Produto',
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class EstoqueTab extends StatefulWidget {
  @override
  _EstoqueTabState createState() => _EstoqueTabState();
}

class _EstoqueTabState extends State<EstoqueTab> {
  List<Produto> produtos = [];

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  Future<void> carregarProdutos() async {
    final response =
        await http.get(Uri.parse("https://localhost:7147/api/Values"));

    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);

//verifica se produtos é uma lista
      if (jsonData['produtos'] is List) {
        setState(() {
          produtos = jsonData['produtos'].map<Produto>((item) {
            return Produto(
              Iproduto: item['iproduto'] ?? 0,
              Nproduto: item['nproduto'] ?? '',
              Qntproduto: (item['qntproduto'] ?? 0).toInt(),
              //se for inteiro converte para double
              Vlrproduto: (item['vlrproduto'] is int)
                  ? item['vlrproduto'].toDouble()
                  : item['vlrproduto'] ?? 0.0,
            );
          }).toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: ListView.builder(
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    final produto = produtos[index];
                    return ListTile(
                      title: Text(produto.Nproduto),
                      subtitle: Text(
                          'ID: ${produto.Iproduto} | Quantidade: ${produto.Qntproduto} | Valor: ${produto.Vlrproduto}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditarProdutoScreen(produto: produto),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              int idDoProduto = produtos[index].Iproduto;

                              try {
                                //excluir o produto pelo id
                                final response = await http.delete(Uri.parse(
                                    "https://localhost:7147/api/Values/$idDoProduto"));

                                if (response.statusCode == 200) {
                                  print("Produto excluído com sucesso");
                                  carregarProdutos();
                                } else {
                                  print(
                                      "Erro ao excluir produto: ${response.statusCode}");
                                }
                              } catch (error) {
                                print("Erro inesperado: $error");
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class CadastroProdutoScreen extends StatelessWidget {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();
  final TextEditingController valorController = TextEditingController();

//trim é para retirar espaços em branco
  Future<void> cadastrarProduto() async {
    final String idText = idController.text.trim();
    final String nome = nomeController.text.trim();
    final String quantidadeText = quantidadeController.text.trim();
    final String valorText = valorController.text.trim();

    if (idText.isEmpty ||
        nome.isEmpty ||
        quantidadeText.isEmpty ||
        valorText.isEmpty) {
      // printa se o campo nao for preenchido 
      print("Preencha todos os campos antes de cadastrar o produto.");
      return;
    }

    final int id = int.tryParse(idText) ?? 0;
    final double quantidade = double.tryParse(quantidadeText) ?? 0.0;
    final double valor = double.tryParse(valorText) ?? 0.0;

    final response = await http.post(
      Uri.parse("https://localhost:7147/api/Values"),
      headers: {
        "Content-Type": "application/json",
      },
      body: '''
        {
          "iproduto": $id,
          "nproduto": "$nome",
          "qntproduto": $quantidade,
          "vlrproduto": $valor
        }
      ''',
    );

    if (response.statusCode == 200) {
      print("Produto cadastrado com sucesso");
    } else {
      print("Falha no cadastro do produto");
    }
  }

  @override
  Widget build(BuildContext context) {
    HomeScreen home = HomeScreen();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Cadastrar Produto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: idController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'ID'),
              ),
              TextFormField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextFormField(
                controller: quantidadeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantidade'),
              ),
              TextFormField(
                controller: valorController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Valor'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  cadastrarProduto();
                },
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}



class EditarProdutoScreen extends StatefulWidget {
  final Produto produto;

  EditarProdutoScreen({required this.produto});

  @override
  _EditarProdutoScreenState createState() => _EditarProdutoScreenState();
}

class _EditarProdutoScreenState extends State<EditarProdutoScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();
  final TextEditingController valorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //controladores que gerenciam a exibição dos valores existentes do
    // produto que estará no texfield
    nomeController.text = widget.produto.Nproduto;
    quantidadeController.text = widget.produto.Qntproduto.toString();
    valorController.text = widget.produto.Vlrproduto.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Editar Produto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextFormField(
                controller: quantidadeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantidade'),
              ),
              TextFormField(
                controller: valorController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Valor'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // solicitação de edição à API
                  editarProduto();
                },
                child: Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // enviar a solicitação de edição à API
  Future<void> editarProduto() async {
    int idDoProduto = widget.produto.Iproduto;
    String nome = nomeController.text.trim();
    double quantidade =
        double.tryParse(quantidadeController.text.trim()) ?? 0.0;
    double valor = double.tryParse(valorController.text.trim()) ?? 0.0;

    try {
      final response = await http.put(
        Uri.parse("https://localhost:7147/api/Values/$idDoProduto"),
        headers: {
          "Content-Type": "application/json",
        },
        body: '''
          {
            "nproduto": "$nome",
            "qntproduto": $quantidade,
            "vlrproduto": $valor
          }
        ''',
      );

      if (response.statusCode == 200) {
        print("Produto editado com sucesso");
        // _EstoqueTabState().carregarProdutos();
      } else {
        print("Erro ao editar produto: ${response.statusCode}");
      }
    } catch (error) {
      print("Erro inesperado: $error");
    }
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login(BuildContext context) {
    //  e-mail e senha pré setado
    const String expectedEmail = 'adm';
    const String expectedPassword = 'adm';

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Verifica se o e-mail e a senha correspondem
    if (email == expectedEmail && password == expectedPassword) {
      // Navega para a HomeScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      // Exibe uma mensagem de erro
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erro de Login'),
            content: Text('E-mail ou senha incorretos.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Senha',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Entrar'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
