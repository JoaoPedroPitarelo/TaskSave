import "dart:async";
import "package:app/core/themes/app_global_colors.dart";
import "package:app/core/utils/translateFailureKey.dart";
import 'package:app/domain/events/category_events.dart';
import "package:app/domain/models/category_vo.dart";
import "package:app/l10n/app_localizations.dart";
import "package:app/presentation/common/error_snackbar.dart";
import "package:app/presentation/common/sucess_snackbar.dart";
import "package:app/presentation/screens/categoryForm/category_form_screen.dart";
import "package:app/presentation/screens/configuration/configuration_screen.dart";
import "package:app/presentation/screens/home/home_viewmodel.dart";
import "package:app/presentation/screens/home/widgets/category_item.dart";
import "package:app/services/events/category_event_service.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:provider/provider.dart";
import 'package:app/presentation/screens/home/widgets/build_drawer_item.dart';
import 'package:app/presentation/common/hex_to_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _deletionSubscription;
  final _categoryEventService = CategoryEventService();

  void loadCategories() async {
    await context.read<HomeViewmodel>().getCategories();
  }

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCategories();

      _deletionSubscription = _categoryEventService.onCategoryChanged.listen( (event) {
        if (event is CategoryDeletionEvent) {
          _showUndoSnackbar(event.category, event.originalIndex);
        }

        if (event is CategoriesChangedEvent) {
          loadCategories();

          if (event.isCreating) {
            _showSuccessSnackbar(AppLocalizations.of(context)!.categoryCreated);
            return;
          }

          if (!event.isCreating) {
            _showSuccessSnackbar(AppLocalizations.of(context)!.categoryModified);
            return;
          }
        }

        if (event is CategoryReorderEvent) {
          loadCategories();

          if (!event.success) {
            _showErrorSnackbar(translateFailureKey(context, event.failureKey!));
            return;
          }
        }
      });
    });
  }

  void _showUndoSnackbar(CategoryVo category, int originalIndex) {
    final homeViewmodel = context.read<HomeViewmodel>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${AppLocalizations.of(context)!.category} ${category.description} ${AppLocalizations.of(context)!.deleted}",
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 2,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.undo,
          textColor: Colors.white,
          onPressed: () {
            homeViewmodel.undoDeletionCategory(category, originalIndex);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        showCloseIcon: false,
      ),
    ).closed.then((reason) {
      if (reason != SnackBarClosedReason.action) {
        homeViewmodel.confirmDeletionCategory(category, originalIndex);
      }
    });
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      showSuccessSnackbar(message)
    );
  }
  
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      showErrorSnackbar(message)
    );
  }

  @override
  void dispose() {
    super.dispose();
    _deletionSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppGlobalColors.of(context);
    final theme = Theme.of(context);

    final homeViewmodel = context.watch<HomeViewmodel>();

    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(170),
            child: AppBar(
              backgroundColor: const Color.fromARGB(255, 12, 43, 170),
              elevation: 12,
              shadowColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white, size: 30),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                )
              ),
              flexibleSpace: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (homeViewmodel.selectedCategory != null)
                               Padding(
                                 padding: const EdgeInsets.only(bottom: 10),
                                 child: Row(
                                   children: [
                                     Icon(
                                       Icons.dashboard_customize_outlined,
                                       color: hexToColor(homeViewmodel.selectedCategory!.color),
                                       size: 30,
                                     ),
                                     const SizedBox(width: 10),
                                     Text(
                                       homeViewmodel.selectedCategory!.description,
                                       style: GoogleFonts.schibstedGrotesk(
                                         fontWeight: FontWeight.normal,
                                         fontSize: 22,
                                         color: Colors.white
                                       )
                                     ),
                                   ],
                                 ),
                               )
                              else
                                const SizedBox(height: 28)
                            ],
                          ),
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
                                    textStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.white)),
                                    backgroundColor: const WidgetStatePropertyAll(Colors.black38),
                                    elevation: const WidgetStatePropertyAll(2.0),
                                    controller: controller,
                                    padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16.0)),
                                    onTap: () {},
                                    onChanged: (_) {
                                      // TODO implementar mecanismo de pesquisa
                                    },
                                    leading: const Icon(Icons.search, color: Colors.white,),
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

      body: const Center(
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
                  const SizedBox(
                    width: 250,
                    child: Divider(
                      thickness: 1.2,
                      endIndent: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ]
              ),
              // Opções
              Expanded(
                child: ListView(
                  children: [
                    buildDrawerItem(
                      context: context,
                      icon: Icons.all_inbox,
                      text: AppLocalizations.of(context)!.allTasks,
                      count: 0,
                      onTap: () {
                        // TODO implementar o método que irá limpar todos os filtros
                        Navigator.pop(context);

                      },
                    ),
                    const SizedBox(height: 5),
                    buildDrawerItem(
                      context: context,
                      icon: Icons.calendar_today,
                      text: AppLocalizations.of(context)!.taskToday,
                      count: 0,
                      onTap: () {
                        // TODO implementar o método que irá filtrar as tarefas por dia
                        Navigator.pop(context);
                        // Ação para "Hoje"
                      },
                    ),
                    buildDrawerItem(
                      context: context,
                      icon: Icons.calendar_month,
                      text: AppLocalizations.of(context)!.taskWeek,
                      count: 0,
                      onTap: () {
                        // TODO implementar o método que irá filtrar as tarefas por semana
                        Navigator.pop(context);
                      },
                    ),
                    buildDrawerItem(
                      context: context,
                      icon: Icons.calendar_view_month,
                      text: AppLocalizations.of(context)!.taskMonth,
                      count: 0,
                      onTap: () {
                        // TODO implementar o método que irá filtrar as tarefas por mês
                        Navigator.pop(context);
                      },
                    ),
                    buildDrawerItem(
                      context: context,
                      icon: Icons.error_outline,
                      text: AppLocalizations.of(context)!.taskLate,
                      count: 0,
                      onTap: () {
                        // TODO implementar o método que irá filtrar as tarefas atrasadas
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(
                      child: Divider(
                      thickness: 1.2,
                      endIndent: 0.5,
                      color: Colors.white,
                      ),
                    ),
                    // Categorias
                    TextButton(
                      onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>  CategoryFormScreen(),
                          )
                        );
                      },
                      child: Padding(
                      padding: const EdgeInsets.only(left: 5.0, bottom: 20.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.dashboard_customize_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.taskCategory,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 11),
                            child: Icon(Icons.add, color: Colors.greenAccent, size: 28),
                          )
                        ],
                      ),
                     )
                    ),
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: homeViewmodel.categories.length,
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 12, 43, 170),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 5,
                                  offset: Offset(0, 3)
                                )
                              ]
                            ),
                            child: child,
                          ),
                        );
                      },
                      itemBuilder: (context, i) {
                        CategoryVo category = homeViewmodel.categories[i];
                        return CategoryItem(
                          key: ValueKey(category.id),
                          category: category,
                          index: i,
                          onTap: () {
                            homeViewmodel.selectCategory(category);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                      onReorder: (int oldIndex, int newIndex) {
                        homeViewmodel.reorderCategories(oldIndex, newIndex);
                      },

                    ),
                  ],
                )
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ConfigurationScreen())
                  );
                },
                child: Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 20.0),
                child: Row(
                  children: [
                    const Icon(Icons.settings_sharp, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.settings,
                      style: theme.textTheme.bodySmall
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
        child: const Icon(
          Icons.add_outlined,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}