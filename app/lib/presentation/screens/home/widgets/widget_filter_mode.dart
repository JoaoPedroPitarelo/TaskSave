import 'package:task_save/core/enums/filtering_task_mode_enum.dart';
import 'package:task_save/domain/models/category_vo.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:task_save/presentation/common/hex_to_color.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetFilterMode extends StatelessWidget {
  final FilteringTaskModeEnum filterMode;
  final CategoryVo? category;

  const WidgetFilterMode({
    required this.filterMode,
    this.category,
    super.key
  });

  Icon getIconForMode() {
    switch (filterMode) {
      case FilteringTaskModeEnum.all:
        return const Icon(Icons.filter_none_rounded, size: 30, color: Colors.white);
      case FilteringTaskModeEnum.today:
        return const Icon(Icons.today_rounded, size: 30, color: Colors.white);
      case FilteringTaskModeEnum.nextWeek:
        return const Icon(Icons.calendar_today_rounded, size: 30, color: Colors.white);
      case FilteringTaskModeEnum.nextMonth:
        return const Icon(Icons.calendar_month_rounded, size: 30, color: Colors.white);
      case FilteringTaskModeEnum.overdue:
        return const Icon(Icons.warning_rounded, size: 30, color: Colors.white);
      case FilteringTaskModeEnum.category:
        return category!.description != "Default"
          ? Icon(Icons.dashboard_rounded, size: 30, color: hexToColor(category!.color))
          : const Icon(Icons.close_rounded, size: 35, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {

    String getTitleForMode() {
      switch (filterMode) {
        case FilteringTaskModeEnum.all:
          return AppLocalizations.of(context)!.allTasks;
        case FilteringTaskModeEnum.today:
          return AppLocalizations.of(context)!.taskToday;
        case FilteringTaskModeEnum.nextWeek:
          return AppLocalizations.of(context)!.taskWeek;
        case FilteringTaskModeEnum.nextMonth:
          return AppLocalizations.of(context)!.taskMonth;
        case FilteringTaskModeEnum.overdue:
          return AppLocalizations.of(context)!.taskLate;
        case FilteringTaskModeEnum.category:
          return category!.description != "Default"
            ? category!.description
            : AppLocalizations.of(context)!.withoutCategory;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          getIconForMode(),
          const SizedBox(width: 10),
          Text(
            getTitleForMode(),
            style: GoogleFonts.schibstedGrotesk(
              fontWeight: FontWeight.normal,
              fontSize: 22,
              color: Colors.white
            )
          ),
        ],
      ),
    );
  }
}
