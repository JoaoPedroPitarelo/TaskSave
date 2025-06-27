import "package:app/core/themes/app_global_colors.dart";
import "package:app/l10n/app_localizations.dart";
import "package:flutter/material.dart";


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  Widget build(BuildContext context) {
    final appColors = AppGlobalColors.of(context);
    final theme = Theme.of(context);

    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(170),
            child: AppBar(
              backgroundColor: const Color.fromARGB(255, 12, 43, 170),
              elevation: 0.2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                )
              ),
              flexibleSpace: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Entrada")
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SearchAnchor(
                              builder: (BuildContext context,
                                SearchController controller) {
                                  return SearchBar(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                                      minHeight: MediaQuery.of(context).size.height * 0.061
                                    ),
                                    backgroundColor: WidgetStatePropertyAll(Colors.black38),
                                    elevation: WidgetStatePropertyAll(2.0),
                                    controller: controller,
                                    padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16.0)),
                                    onTap: () {},
                                    // TODO implementar mecanismo de pesquisa
                                    onChanged: (_) {
                                      controller.openView();
                                    },
                                    leading: const Icon(Icons.search),
                                    hintText: AppLocalizations.of(context)!
                                        .searchForTasks,
                                  );
                              },
                                suggestionsBuilder: (BuildContext context, SearchController controller) {
                                  return List<ListTile>.generate(5, (int index) {
                                    final String item = index.toString();
                                    return ListTile(
                                      title: Text('Suggestion $index'),
                                      onTap: () {
                                        setState(() {
                                          controller.closeView(item);
                                        }
                                      );
                                    },
                                  );
                                }
                              );
                            }
                          )
                        ],
                      )
                    ],
                  ),
              )
            ),
          ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
      
          ],
        )
      ),

      // Menu lateral
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 12, 43, 170),
        child: Padding(
          padding: const EdgeInsets.only(top: 45),
          child: Column(
            children: <Widget>[
              // Cabeçalho
              Column(
                children: [
                  SizedBox(
                    height: 60,
                    child: Image.asset('assets/images/tasksave_logo_light.png')
                  ),
                  SizedBox(
                    width: 250,
                    child: Divider(
                      thickness: 1.2,
                      endIndent: 0.5,
                    ),
                  ),
                ]
              ),
              // Opções
              Expanded(
                child: ListView(
                  children: [
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.calendar_today,
                      text: AppLocalizations.of(context)!.taskToday,
                      count: 4,
                      onTap: () {
                        // TODO implementar o método que irá filtrar as tarefas por dia
                        Navigator.pop(context); 
                        // Ação para "Hoje"
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.calendar_month,
                      text: AppLocalizations.of(context)!.taskWeek,
                      count: 4,
                      onTap: () {
                        // TODO implementar o método que irá filtrar as tarefas por semana
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.calendar_view_month,
                      text: AppLocalizations.of(context)!.taskMonth,
                      count: 0,
                      onTap: () {
                        // TODO implementar o método que irá filtrar as tarefas por mês
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.error_outline,
                      text: AppLocalizations.of(context)!.taskLate,
                      count: 3,
                      onTap: () {
                        // TODO implementar o método que irá filtrar as tarefas atrasadas
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(
                      child: Divider(
                      thickness: 1.2,
                      endIndent: 0.5,
                      ),
                    ),
                    // Categorias
                    TextButton(
                onPressed: () {
                  // TODO fazer a tela de configurações e adicionar a navegação aqui
                },
                child: Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 20.0),
                child: Row(
                  children: [
                    Icon(Icons.category_outlined, color: Colors.white, size: 28),
                    SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.taskCategory,
                            style: theme.textTheme.bodyMedium
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.add_outlined, color: Colors.white, size: 24),
                    )
                  ],
                ),
              )
              )
                  ],
                )
              ),
              TextButton(
                onPressed: () {
                  // TODO fazer a tela de configurações e adicionar a navegação aqui
                },
                child: Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 20.0),
                child: Row(
                  children: [
                    Icon(Icons.settings_sharp, color: Colors.white, size: 28),
                    SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.settings,
                      style: theme.textTheme.bodyMedium
                    ),
                  ],
                ),
              )
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO fazer a tela de formulário para adicionar novas tarefas
        },
        elevation: 3,
        child: Icon(
          Icons.add_outlined, 
          size: 30, 
          color: Colors.white,
        ),
      ),
    );
  }

  // Função auxiliar para construir os itens do Drawer
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    int? count,
    bool showPlusIcon = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 28),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
          if (showPlusIcon) ...[
            const Spacer(),
            const Icon(Icons.add, color: Colors.white, size: 24),
          ],
        ],
      ),
      onTap: onTap,
    );
  }  
}
