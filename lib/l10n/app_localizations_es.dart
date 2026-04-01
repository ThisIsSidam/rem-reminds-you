// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get retry => 'reintentar';

  @override
  String get somethingWentWrong => '¡Algo salió mal!';

  @override
  String get homeTitle => 'Recordatorios';

  @override
  String get homeSectionOverdue => 'Vencidos';

  @override
  String get homeSectionToday => 'Hoy';

  @override
  String get homeSectionTomorrow => 'Mañana';

  @override
  String get homeSectionLater => 'Más tarde';

  @override
  String get homeSectionNoRush => 'Sin prisa';

  @override
  String get emptyReminders => '¡No tienes ningún recordatorio!';

  @override
  String get setReminder => 'Establecer recordatorio';

  @override
  String get actionResume => 'Reanudar';

  @override
  String get actionPause => 'Pausar';

  @override
  String get actionTapToUndo => 'Toca para deshacer';

  @override
  String get actionDeleted => 'eliminado';

  @override
  String get actionPostponed => 'pospuesto.';

  @override
  String get actionMovedNextOccurrence => 'movido a la próxima ocurrencia.';

  @override
  String get dragZoneOverdue => '¡Algo salió mal!';

  @override
  String get dragZoneToday => 'Establecer para hoy';

  @override
  String get dragZoneTomorrow => 'Establecer para mañana';

  @override
  String get dragZoneLater => 'Programar para más tarde';

  @override
  String get dragZoneNoRush => 'Guardar en Sin prisa';

  @override
  String get permissionNotificationTitle => 'Permiso de notificaciones';

  @override
  String get permissionRequired => ' (Requerido)';

  @override
  String get permissionNotificationDescription =>
      'Nos encantaría recordarte tus tareas, pero no podemos hacerlo sin las notificaciones.';

  @override
  String get permissionAlarmTitle => 'Permiso de alarma';

  @override
  String get permissionAlarmDescription =>
      'Para asegurarnos de que los recordatorios suenen a tiempo, necesitamos acceso al sistema de alarmas de tu dispositivo.';

  @override
  String get permissionBatteryTitle => 'Permiso de batería';

  @override
  String get permissionRecommended => ' (Recomendado)';

  @override
  String get permissionBatteryDescription =>
      'Tu dispositivo puede restringir las notificaciones para ahorrar batería. Permite el uso ilimitado de batería para recibir recordatorios a tiempo.';

  @override
  String get permissionAllow => 'Permitir permiso';

  @override
  String get permissionSetUnrestricted => 'Establecer como ilimitado';

  @override
  String get permissionContinue => 'Continuar';

  @override
  String get permissionContinueToApp => 'Continuar a la app';

  @override
  String get sheetTitle => 'Título';

  @override
  String get sheetEnterTitleError => '¡Ingresa un título!';

  @override
  String get sheetPastTimeError => '¡No puedo recordarte en el pasado!';

  @override
  String get sheetSave => 'Guardar';

  @override
  String get sheetForAll => 'Para todos';

  @override
  String get sheetPostpone => 'Posponer';

  @override
  String get sheetRecurringDialogTitle => 'Recordatorio recurrente';

  @override
  String get sheetRecurringDialogContent =>
      'Este es un recordatorio recurrente. ¿Realmente quieres eliminarlo?';

  @override
  String get sheetCancel => 'Cancelar';

  @override
  String get sheetConfirm => 'Sí';

  @override
  String sheetAgo(String duration) {
    return 'hace $duration';
  }

  @override
  String sheetIn(String duration) {
    return 'en $duration';
  }

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsResetDialogTitle =>
      '¿Restablecer configuración a valores predeterminados?';

  @override
  String get settingsNo => 'No';

  @override
  String get settingsYes => 'Sí';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsTextScale => 'Escala de texto';

  @override
  String get settingsPostponeDuration => 'Duración de posposición';

  @override
  String get settings15Min => '15 min';

  @override
  String get settings30Min => '30 min';

  @override
  String get settings45Min => '45 min';

  @override
  String get settings1Hour => '1 hora';

  @override
  String get settings2Hours => '2 horas';

  @override
  String get settingsNoRushHours => 'Horas sin prisa';

  @override
  String get settingsNoRushDescription =>
      'Los recordatorios sin prisa se muestran solo dentro de este rango de tiempo, para que solo seas notificado cuando quieras.';

  @override
  String get settingsFrom => 'Desde';

  @override
  String get settingsTo => 'Hasta';

  @override
  String get settingsSwipeToLeftActions =>
      'Acciones de deslizar a la izquierda';

  @override
  String get settingsSwipeLeft => 'Deslizar a la izquierda';

  @override
  String get settingsSwipeToRightActions => 'Acciones de deslizar a la derecha';

  @override
  String get settingsSwipeRight => 'Deslizar a la derecha';

  @override
  String get settingsGestures => 'Gestos';

  @override
  String get settingsNewReminder => 'Nuevo recordatorio';

  @override
  String get settingsDefaultLeadDuration =>
      'Duración de anticipación predeterminada';

  @override
  String settingsEvery(String duration) {
    return 'Cada $duration';
  }

  @override
  String get settingsDefaultAutoSnoozeDuration =>
      'Duración de repetición automática predeterminada';

  @override
  String get settingsQuickTimeTable => 'Tabla de tiempo rápido';

  @override
  String get settingsSnoozeOptions => 'Opciones de repetición';

  @override
  String get settingsDefaultLeadDurationTitle =>
      'Duración de anticipación predeterminada';

  @override
  String get settingsDefaultAutoSnoozeDurationTitle =>
      'Duración de repetición automática predeterminada';

  @override
  String get settingsQuickTimeTableTitle => 'Tabla de tiempo rápido';

  @override
  String get settingsSnoozeOptionsTitle => 'Opciones de repetición';

  @override
  String get settingsBackupRestore =>
      'Copia de seguridad y restauración (Experimental)';

  @override
  String get settingsBackup => 'Copia de seguridad';

  @override
  String get settingsNoDirectorySelected => 'No se seleccionó directorio';

  @override
  String get settingsBackupCreated => 'Copia de seguridad creada exitosamente';

  @override
  String get settingsBackupFailed => '¡La copia de seguridad falló!';

  @override
  String get settingsRestore => 'Restaurar';

  @override
  String get settingsNoFileSelected => 'No se seleccionó archivo';

  @override
  String get settingsBackupRestored =>
      'Copia de seguridad restaurada exitosamente';

  @override
  String get settingsRestoreFailed =>
      '¡La restauración de la copia de seguridad falló!';

  @override
  String get settingsLogs => 'Registros';

  @override
  String get settingsGetLogFile => 'Obtener archivo de registro';

  @override
  String get settingsLogsSaved => 'Registros guardados exitosamente';

  @override
  String get settingsExportLogsFailed =>
      '¡No se pudieron exportar los registros!';

  @override
  String get settingsClearAllLogs => 'Limpiar todos los registros';

  @override
  String get settingsLogsDeleted =>
      'Todos los registros eliminados exitosamente';

  @override
  String get settingsOther => 'Otro';

  @override
  String get settingsWhatsNew => '¿Qué hay de nuevo?';

  @override
  String get agendaTitle => 'Agenda';

  @override
  String get agendaNoTasks => 'No hay tareas para este día.';

  @override
  String get agendaToday => 'Hoy';

  @override
  String get agendaTomorrow => 'Mañana';

  @override
  String get agendaDayAfter => 'Pasado Mañana';

  @override
  String get agendaTaskTitle => 'Título de la Tarea';

  @override
  String get agendaEnterTaskHint => 'Introducir tarea...';

  @override
  String get agendaTapToCreateTask =>
      'Toca la tarjeta para crear una nueva tarea';

  @override
  String get settingsAgendaTimeTitle => '¿Cuándo mostrar la Agenda?';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsUseSystemFont => 'Usar fuente del sistema';

  @override
  String get settingsAdvanced => 'Avanzado';

  @override
  String get settingsAgenda => 'Configuración de Agenda';

  @override
  String get settingsPersonalization => 'Personalización';

  @override
  String get settingsReminders => 'Configuración de Recordatorios';

  @override
  String get swipeActionNone => 'Ninguno';

  @override
  String get swipeActionDone => 'Hecho';

  @override
  String get swipeActionDelete => 'Eliminar';

  @override
  String get swipeActionPostpone => 'Posponer';

  @override
  String get swipeActionDoneAndDelete => 'Hecho y Eliminar';
}
