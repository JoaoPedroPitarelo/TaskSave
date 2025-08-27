import "dart:async";
import "package:task_save/core/enums/filtering_task_mode_enum.dart";
import "package:task_save/core/themes/app_global_colors.dart";
import "package:task_save/core/utils/translateFailureKey.dart";
import 'package:task_save/core/events/category_events.dart';
import "package:task_save/core/events/task_events.dart";
import "package:task_save/domain/models/category_vo.dart";
import "package:task_save/domain/models/task_vo.dart";
import "package:task_save/l10n/app_localizations.dart";
import "package:task_save/presentation/common/error_snackbar.dart";
import "package:task_save/presentation/common/sucess_snackbar.dart";
import "package:task_save/presentation/common/task_widget.dart";
import "package:task_save/presentation/screens/category_form/category_form_screen.dart";
import "package:task_save/presentation/screens/home/category_viewmodel.dart";
import "package:task_save/presentation/screens/home/task_viewmodel.dart";
import "package:task_save/presentation/screens/home/widgets/show_custom_about_dialog.dart";
import "package:task_save/presentation/screens/home/widgets/show_export_pdf.dart";
import "package:task_save/presentation/screens/home/widgets/widget_filter_mode.dart";
import "package:task_save/presentation/screens/settings/settings_screen.dart";
import "package:task_save/presentation/screens/home/widgets/category_item.dart";
import "package:task_save/presentation/screens/task_form/task_form_screen.dart";
import "package:task_save/services/events/category_event_service.dart";
import "package:task_save/services/events/task_event_service.dart";
import "package:flutter/material.dart";
import "package:flutter_speed_dial/flutter_speed_dial.dart";
import "package:google_fonts/google_fonts.dart";
import "package:provider/provider.dart";
import "dart:io";
import "package:file_picker/file_picker.dart";
import "package:task_save/presentation/screens/home/widgets/build_drawer_item.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _categorySubscription;
  StreamSubscription? _taskSubscription;
  final _categoryEventService = CategoryEventService();
  final _taskEventService = TaskEventService();

  final searchController = TextEditingController();

  late AppLocalizations _localizations;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      _localizations = AppLocalizations.of(context)!;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadCategories();
        loadTasks();

        _categorySubscription =
            _categoryEventService.onCategoryChanged.listen((event) {
          if (event is CategoryPrepareDeletionEvent) {
            _showUndoSnackBarCategory(event.category, event.originalIndex);
          }

          if (event is CategoryDeletionEvent) {
            if (!event.success) {
              _showErrorSnackBar(
                  translateFailureKey(_localizations, event.failureKey!));
              return;
            }
            loadCategories();
            loadTasks();
          }

          if (event is CategoriesChangedEvent) {
            loadCategories();

            if (event.isCreating) {
              _showSuccessSnackBar(_localizations.categoryCreated);
              return;
            }

            if (!event.isCreating) {
              _showSuccessSnackBar(_localizations.categoryModified);
              return;
            }
          }

          if (event is CategoryReorderEvent) {
            loadCategories();

            if (!event.success) {
              _showErrorSnackBar(
                  translateFailureKey(_localizations, event.failureKey!));
              return;
            }
          }
        });

        _taskSubscription = _taskEventService.onTaskChanged.listen((event) {
          if (event is GetTasksEvent) {
            if (!event.success) {
              _showErrorSnackBar(
                  translateFailureKey(_localizations, event.failureKey!));
              return;
            }

            if (event.success) {
              loadTasks();
            }
          }

          if (event is TaskDeletionEvent) {
            _showUndoSnackBarTask(event.task, event.originalIndex);
          }

          if (event is TaskUpdateEvent) {
            if (!event.success) {
              _showErrorSnackBar(
                  translateFailureKey(_localizations, event.failureKey!));
              return;
            }
          }

          if (event is SubtaskCreationEvent) {
            if (event.success) {
              loadTasks();
              return;
            }
          }

          if (event is TaskExportPDFEvent) {
            if (!event.success) {
              _showErrorSnackBar(
                  translateFailureKey(_localizations, event.failureKey!));
              return;
            }
            _savePdfFile(event.file!);
          }
        });
      });
    }
  }

  void loadCategories() async {
    await context.read<CategoryViewmodel>().getCategories();
  }

  void loadTasks() async {
    await context.read<TaskViewmodel>().getTasks();
    if (mounted) {
      await context
          .read<TaskViewmodel>()
          .scheduleNotifications(context.read<TaskViewmodel>().tasks, context);
    }
  }

  void _showUndoSnackBarCategory(CategoryVo category, int originalIndex) {
    final categoryViewmodel = context.read<CategoryViewmodel>();

    ScaffoldMessenger.of(context)
        .showSnackBar(
          showErrorSnackBar(
            "${AppLocalizations.of(context)!.category} ${category.description} ${AppLocalizations.of(context)!.deleted}",
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.undo,
              textColor: const Color.fromARGB(255, 245, 175, 175),
              onPressed: () {
                categoryViewmodel.undoDeletionCategory(category, originalIndex);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        )
        .closed
        .then((reason) {
      if (reason != SnackBarClosedReason.action) {
        categoryViewmodel.confirmDeletionCategory(category, originalIndex);
      }
    });
  }

  void _showUndoSnackBarTask(TaskVo task, int originalIndex) {
    final taskViewmodel = context.read<TaskViewmodel>();

    ScaffoldMessenger.of(context)
        .showSnackBar(
          showErrorSnackBar(
            "${AppLocalizations.of(context)!.task} ${task.title} ${AppLocalizations.of(context)!.deleted}",
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.undo,
              textColor: Colors.white,
              onPressed: () {
                taskViewmodel.undoDeletionTask(task, originalIndex);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        )
        .closed
        .then((reason) {
      if (reason != SnackBarClosedReason.action) {
        taskViewmodel.confirmTaskDeletion(task, originalIndex);
      }
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(showSuccessSnackBar(message));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(showErrorSnackBar(message));
  }

  Future<void> _savePdfFile(File file) async {
    final pdfBytes = await file.readAsBytes();
    final result = await FilePicker.platform.saveFile(
        dialogTitle: _localizations.exportToPdf,
        fileName: "task_save_export.pdf",
        type: FileType.custom,
        allowedExtensions: ["pdf"],
        bytes: pdfBytes);

    if (result != null) {
      _showSuccessSnackBar("Exportado com sucesso!");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _categorySubscription?.cancel();
    _taskSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppGlobalColors.of(context);
    final theme = Theme.of(context);

    final taskViewmodel = context.watch<TaskViewmodel>();
    final categoryViewmodel = context.watch<CategoryViewmodel>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170),
        child: AppBar(
          elevation: 8,
          shadowColor: Colors.black45,
          iconTheme: const IconThemeData(color: Colors.white, size: 30),
          leading: Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu_rounded),
            );
          }),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8),
          )),
          actions: [
            PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                color: theme.appBarTheme.backgroundColor,
                onSelected: (value) {
                  if (value == "export") {
                    showExportTasksDialog(context);
                  }
                  if (value == "about") {
                    showCustomAboutDialog(context);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: "export",
                        child: Row(
                          spacing: 10,
                          children: [
                            const Icon(Icons.file_copy_rounded, size: 25),
                            Text(
                              AppLocalizations.of(context)!.exportToPdf,
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: "about",
                        child: Row(
                          spacing: 10,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 25),
                            Text(
                              AppLocalizations.of(context)!.about,
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    ])
          ],
          flexibleSpace: SafeArea(
            child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 45),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      WidgetFilterMode(
                          filterMode: taskViewmodel.filterMode,
                          category: categoryViewmodel.selectedCategory)
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SearchBar(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                          minHeight:
                              MediaQuery.of(context).size.height * 0.061),
                      shape: const WidgetStatePropertyAll<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                      ),
                      textStyle: const WidgetStatePropertyAll(
                          TextStyle(color: Colors.white70)),
                      backgroundColor:
                          const WidgetStatePropertyAll(Colors.black38),
                      elevation: const WidgetStatePropertyAll(2.0),
                      controller: searchController,
                      autoFocus: false,
                      padding: const WidgetStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 16.0)),
                      onChanged: (query) {
                        taskViewmodel.searchTask(query);
                      },
                      leading: const Icon(Icons.search, color: Colors.white70),
                      hintText: AppLocalizations.of(context)!.searchForTasks,
                    )
                  ],
                )
              ],
            ),
          )),
        ),
      ),
      body: taskViewmodel.tasks.isNotEmpty
          ? RefreshIndicator(
              onRefresh: () async {
                loadTasks();
                loadCategories();
              },
              child: ReorderableListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                itemCount: taskViewmodel.filteredTasks.length,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(50, 12, 43, 170),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10, offset: const Offset(0, 2))
                          ]),
                      child: child,
                    ),
                  );
                },
                itemBuilder: (context, i) {
                  TaskVo task = taskViewmodel.filteredTasks[i];
                  return TaskWidget(
                    key: ValueKey(task.id),
                    task: task,
                    rightDismissedCallback: () =>
                        taskViewmodel.prepareTaskForDeletion(task),
                    leftDismissedCallback: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => TaskFormScreen(task: task))),
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  taskViewmodel.reorderTask(oldIndex, newIndex);
                },
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                loadTasks();
                loadCategories();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 80.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              "assets/images/no_tasks_stay_safe.png",
                              width: MediaQuery.of(context).size.width * 0.79,
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                  color: appColors.welcomeScreenCardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3))
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 5),
                                child: Column(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.staySafe,
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 32,
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.noHaveTasks,
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 32,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
      // Menu lateral
      drawer: Drawer(
        backgroundColor: theme.appBarTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 45),
          child: Column(
            children: <Widget>[
              // Cabeçalho
              Column(children: [
                SizedBox(
                    height: 60,
                    child: Image.asset('assets/images/tasksave_logo_light.png')),
                const SizedBox(
                  width: 250,
                  child: Divider(
                    thickness: 1.2,
                    endIndent: 0.5,
                    color: Colors.white,
                  ),
                ),
              ]),
              // Opções
              Expanded(
                  child: ListView(
                children: [
                  buildDrawerItem(
                    context: context,
                    icon: const Icon(
                      Icons.filter_none_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    text: AppLocalizations.of(context)!.allTasks,
                    count: taskViewmodel.countAllTasks,
                    onTap: () {
                      taskViewmodel.clearAllFiltersForTasks();
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 5),
                  buildDrawerItem(
                    context: context,
                    icon: const Icon(
                      Icons.today_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                    text: AppLocalizations.of(context)!.taskToday,
                    count: taskViewmodel.countTodayTasks,
                    onTap: () {
                      taskViewmodel.filterTasks(FilteringTaskModeEnum.today);
                      Navigator.pop(context);
                    },
                  ),
                  buildDrawerItem(
                    context: context,
                    icon: const Icon(
                      Icons.calendar_today_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                    text: AppLocalizations.of(context)!.taskWeek,
                    count: taskViewmodel.countNextWeekTasks,
                    onTap: () {
                      taskViewmodel.filterTasks(FilteringTaskModeEnum.nextWeek);
                      Navigator.pop(context);
                    },
                  ),
                  buildDrawerItem(
                    context: context,
                    icon: const Icon(
                      Icons.calendar_month_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                    text: AppLocalizations.of(context)!.taskMonth,
                    count: taskViewmodel.countNextMonthTasks,
                    onTap: () {
                      taskViewmodel
                          .filterTasks(FilteringTaskModeEnum.nextMonth);
                      Navigator.pop(context);
                    },
                  ),
                  buildDrawerItem(
                    context: context,
                    icon: const Icon(
                      Icons.warning_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                    text: AppLocalizations.of(context)!.taskLate,
                    count: taskViewmodel.countOverdueTasks,
                    onTap: () {
                      taskViewmodel.filterTasks(FilteringTaskModeEnum.overdue);
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
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryViewmodel.categories.length,
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
                                    offset: Offset(0, 3))
                              ]),
                          child: child,
                        ),
                      );
                    },
                    itemBuilder: (context, i) {
                      CategoryVo category = categoryViewmodel.categories[i];
                      return CategoryItem(
                        key: ValueKey(category.id),
                        category: category,
                        index: i,
                        onTap: () {
                          categoryViewmodel.selectCategory(category);
                          taskViewmodel.filterTasks(FilteringTaskModeEnum.category);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                    onReorder: (int oldIndex, int newIndex) {
                      categoryViewmodel.reorderCategory(oldIndex, newIndex);
                    },
                  ),
                ],
              )),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ConfigurationScreen()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 20.0),
                    child: Row(
                      children: [
                        const Icon(Icons.settings_rounded,
                            color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.settings,
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: theme.appBarTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        icon: Icons.add_rounded,
        activeIcon: Icons.close_rounded,
        childrenButtonSize: Size(60, 60),
        childMargin: EdgeInsets.all(20),
        iconTheme: IconThemeData(size: 30),
        foregroundColor: Colors.white,
        spacing: 20,
        elevation: 2,
        children: [
          SpeedDialChild(
            elevation: 2,
              backgroundColor: theme.appBarTheme.backgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.dashboard_customize_rounded, color: Colors.white, size: 30),
              label: AppLocalizations.of(context)!.addCategory,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CategoryFormScreen()));
              }),
          SpeedDialChild(
              elevation: 2,
              backgroundColor: theme.appBarTheme.backgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add_task_rounded,
                  color: Colors.white, size: 30),
              label: AppLocalizations.of(context)!.addTask,
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => TaskFormScreen()));
              }),
        ],
      ),
    );
  }
}
