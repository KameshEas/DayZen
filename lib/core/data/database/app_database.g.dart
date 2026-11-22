// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startHourMeta = const VerificationMeta(
    'startHour',
  );
  @override
  late final GeneratedColumn<int> startHour = GeneratedColumn<int>(
    'start_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endHourMeta = const VerificationMeta(
    'endHour',
  );
  @override
  late final GeneratedColumn<int> endHour = GeneratedColumn<int>(
    'end_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinuteMeta = const VerificationMeta(
    'endMinute',
  );
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
    'end_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rolloverCountMeta = const VerificationMeta(
    'rolloverCount',
  );
  @override
  late final GeneratedColumn<int> rolloverCount = GeneratedColumn<int>(
    'rollover_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _effortMeta = const VerificationMeta('effort');
  @override
  late final GeneratedColumn<int> effort = GeneratedColumn<int>(
    'effort',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalDateMeta = const VerificationMeta(
    'originalDate',
  );
  @override
  late final GeneratedColumn<DateTime> originalDate = GeneratedColumn<DateTime>(
    'original_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    startHour,
    startMinute,
    endHour,
    endMinute,
    priority,
    category,
    iconCodePoint,
    subtitle,
    isCompleted,
    status,
    completedAt,
    rolloverCount,
    effort,
    originalDate,
    date,
    createdAt,
    updatedAt,
    dirty,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('start_hour')) {
      context.handle(
        _startHourMeta,
        startHour.isAcceptableOrUnknown(data['start_hour']!, _startHourMeta),
      );
    } else if (isInserting) {
      context.missing(_startHourMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('end_hour')) {
      context.handle(
        _endHourMeta,
        endHour.isAcceptableOrUnknown(data['end_hour']!, _endHourMeta),
      );
    } else if (isInserting) {
      context.missing(_endHourMeta);
    }
    if (data.containsKey('end_minute')) {
      context.handle(
        _endMinuteMeta,
        endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinuteMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('rollover_count')) {
      context.handle(
        _rolloverCountMeta,
        rolloverCount.isAcceptableOrUnknown(
          data['rollover_count']!,
          _rolloverCountMeta,
        ),
      );
    }
    if (data.containsKey('effort')) {
      context.handle(
        _effortMeta,
        effort.isAcceptableOrUnknown(data['effort']!, _effortMeta),
      );
    }
    if (data.containsKey('original_date')) {
      context.handle(
        _originalDateMeta,
        originalDate.isAcceptableOrUnknown(
          data['original_date']!,
          _originalDateMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      startHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_hour'],
      )!,
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      )!,
      endHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_hour'],
      )!,
      endMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      ),
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      rolloverCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rollover_count'],
      )!,
      effort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effort'],
      ),
      originalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}original_date'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final String id;
  final String title;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  /// [TaskPriority] enum name (e.g. "high", "zen").
  final String priority;

  /// [TaskCategory] enum name (e.g. "work", "study").
  final String category;

  /// [IconData.codePoint], nullable — [DzTask.icon] is optional.
  final int? iconCodePoint;
  final String? subtitle;
  final bool isCompleted;

  /// [TaskStatus] name: `active`, `done` or `released`. Schema v2.
  /// [isCompleted] mirrors `status == 'done'` for one release so older code
  /// paths and older servers stay consistent.
  final String status;

  /// When the task was completed. Rows completed before v2 were backfilled
  /// from `updatedAt`, so for those it's approximate.
  final DateTime? completedAt;

  /// Days this task has been carried forward by Gentle Rollover.
  final int rolloverCount;

  /// 1 (light) to 3 (heavy). Null = not set.
  final int? effort;

  /// The date the task was first planned for, set on its first rollover.
  final DateTime? originalDate;

  /// Normalised to midnight, matching [DzTask.date]. Indexed — this is the
  /// column `forDate`/`forWeek` filter on.
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// True when this row has local changes not yet confirmed synced to the
  /// server. Written by the repository on every local mutation; cleared by
  /// the sync layer once the server acknowledges the change.
  final bool dirty;

  /// Soft-delete timestamp. Null = active. Rows are never hard-deleted
  /// except by [TaskDao.hardDeleteAll] (used for the Settings "clear all
  /// data" action), so sync can still see what was removed locally.
  final DateTime? deletedAt;
  const TaskRow({
    required this.id,
    required this.title,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.priority,
    required this.category,
    this.iconCodePoint,
    this.subtitle,
    required this.isCompleted,
    required this.status,
    this.completedAt,
    required this.rolloverCount,
    this.effort,
    this.originalDate,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.dirty,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['start_hour'] = Variable<int>(startHour);
    map['start_minute'] = Variable<int>(startMinute);
    map['end_hour'] = Variable<int>(endHour);
    map['end_minute'] = Variable<int>(endMinute);
    map['priority'] = Variable<String>(priority);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || iconCodePoint != null) {
      map['icon_code_point'] = Variable<int>(iconCodePoint);
    }
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['rollover_count'] = Variable<int>(rolloverCount);
    if (!nullToAbsent || effort != null) {
      map['effort'] = Variable<int>(effort);
    }
    if (!nullToAbsent || originalDate != null) {
      map['original_date'] = Variable<DateTime>(originalDate);
    }
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      startHour: Value(startHour),
      startMinute: Value(startMinute),
      endHour: Value(endHour),
      endMinute: Value(endMinute),
      priority: Value(priority),
      category: Value(category),
      iconCodePoint: iconCodePoint == null && nullToAbsent
          ? const Value.absent()
          : Value(iconCodePoint),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      isCompleted: Value(isCompleted),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      rolloverCount: Value(rolloverCount),
      effort: effort == null && nullToAbsent
          ? const Value.absent()
          : Value(effort),
      originalDate: originalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(originalDate),
      date: Value(date),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      startHour: serializer.fromJson<int>(json['startHour']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endHour: serializer.fromJson<int>(json['endHour']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      priority: serializer.fromJson<String>(json['priority']),
      category: serializer.fromJson<String>(json['category']),
      iconCodePoint: serializer.fromJson<int?>(json['iconCodePoint']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      rolloverCount: serializer.fromJson<int>(json['rolloverCount']),
      effort: serializer.fromJson<int?>(json['effort']),
      originalDate: serializer.fromJson<DateTime?>(json['originalDate']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'startHour': serializer.toJson<int>(startHour),
      'startMinute': serializer.toJson<int>(startMinute),
      'endHour': serializer.toJson<int>(endHour),
      'endMinute': serializer.toJson<int>(endMinute),
      'priority': serializer.toJson<String>(priority),
      'category': serializer.toJson<String>(category),
      'iconCodePoint': serializer.toJson<int?>(iconCodePoint),
      'subtitle': serializer.toJson<String?>(subtitle),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'rolloverCount': serializer.toJson<int>(rolloverCount),
      'effort': serializer.toJson<int?>(effort),
      'originalDate': serializer.toJson<DateTime?>(originalDate),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TaskRow copyWith({
    String? id,
    String? title,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    String? priority,
    String? category,
    Value<int?> iconCodePoint = const Value.absent(),
    Value<String?> subtitle = const Value.absent(),
    bool? isCompleted,
    String? status,
    Value<DateTime?> completedAt = const Value.absent(),
    int? rolloverCount,
    Value<int?> effort = const Value.absent(),
    Value<DateTime?> originalDate = const Value.absent(),
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TaskRow(
    id: id ?? this.id,
    title: title ?? this.title,
    startHour: startHour ?? this.startHour,
    startMinute: startMinute ?? this.startMinute,
    endHour: endHour ?? this.endHour,
    endMinute: endMinute ?? this.endMinute,
    priority: priority ?? this.priority,
    category: category ?? this.category,
    iconCodePoint: iconCodePoint.present
        ? iconCodePoint.value
        : this.iconCodePoint,
    subtitle: subtitle.present ? subtitle.value : this.subtitle,
    isCompleted: isCompleted ?? this.isCompleted,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    rolloverCount: rolloverCount ?? this.rolloverCount,
    effort: effort.present ? effort.value : this.effort,
    originalDate: originalDate.present ? originalDate.value : this.originalDate,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      startHour: data.startHour.present ? data.startHour.value : this.startHour,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      endHour: data.endHour.present ? data.endHour.value : this.endHour,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      priority: data.priority.present ? data.priority.value : this.priority,
      category: data.category.present ? data.category.value : this.category,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      status: data.status.present ? data.status.value : this.status,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      rolloverCount: data.rolloverCount.present
          ? data.rolloverCount.value
          : this.rolloverCount,
      effort: data.effort.present ? data.effort.value : this.effort,
      originalDate: data.originalDate.present
          ? data.originalDate.value
          : this.originalDate,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startHour: $startHour, ')
          ..write('startMinute: $startMinute, ')
          ..write('endHour: $endHour, ')
          ..write('endMinute: $endMinute, ')
          ..write('priority: $priority, ')
          ..write('category: $category, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('subtitle: $subtitle, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('rolloverCount: $rolloverCount, ')
          ..write('effort: $effort, ')
          ..write('originalDate: $originalDate, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    startHour,
    startMinute,
    endHour,
    endMinute,
    priority,
    category,
    iconCodePoint,
    subtitle,
    isCompleted,
    status,
    completedAt,
    rolloverCount,
    effort,
    originalDate,
    date,
    createdAt,
    updatedAt,
    dirty,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.startHour == this.startHour &&
          other.startMinute == this.startMinute &&
          other.endHour == this.endHour &&
          other.endMinute == this.endMinute &&
          other.priority == this.priority &&
          other.category == this.category &&
          other.iconCodePoint == this.iconCodePoint &&
          other.subtitle == this.subtitle &&
          other.isCompleted == this.isCompleted &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.rolloverCount == this.rolloverCount &&
          other.effort == this.effort &&
          other.originalDate == this.originalDate &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> startHour;
  final Value<int> startMinute;
  final Value<int> endHour;
  final Value<int> endMinute;
  final Value<String> priority;
  final Value<String> category;
  final Value<int?> iconCodePoint;
  final Value<String?> subtitle;
  final Value<bool> isCompleted;
  final Value<String> status;
  final Value<DateTime?> completedAt;
  final Value<int> rolloverCount;
  final Value<int?> effort;
  final Value<DateTime?> originalDate;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.startHour = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endHour = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.priority = const Value.absent(),
    this.category = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rolloverCount = const Value.absent(),
    this.effort = const Value.absent(),
    this.originalDate = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required String priority,
    required String category,
    this.iconCodePoint = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rolloverCount = const Value.absent(),
    this.effort = const Value.absent(),
    this.originalDate = const Value.absent(),
    required DateTime date,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       startHour = Value(startHour),
       startMinute = Value(startMinute),
       endHour = Value(endHour),
       endMinute = Value(endMinute),
       priority = Value(priority),
       category = Value(category),
       date = Value(date);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? startHour,
    Expression<int>? startMinute,
    Expression<int>? endHour,
    Expression<int>? endMinute,
    Expression<String>? priority,
    Expression<String>? category,
    Expression<int>? iconCodePoint,
    Expression<String>? subtitle,
    Expression<bool>? isCompleted,
    Expression<String>? status,
    Expression<DateTime>? completedAt,
    Expression<int>? rolloverCount,
    Expression<int>? effort,
    Expression<DateTime>? originalDate,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (startHour != null) 'start_hour': startHour,
      if (startMinute != null) 'start_minute': startMinute,
      if (endHour != null) 'end_hour': endHour,
      if (endMinute != null) 'end_minute': endMinute,
      if (priority != null) 'priority': priority,
      if (category != null) 'category': category,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (subtitle != null) 'subtitle': subtitle,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (rolloverCount != null) 'rollover_count': rolloverCount,
      if (effort != null) 'effort': effort,
      if (originalDate != null) 'original_date': originalDate,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? startHour,
    Value<int>? startMinute,
    Value<int>? endHour,
    Value<int>? endMinute,
    Value<String>? priority,
    Value<String>? category,
    Value<int?>? iconCodePoint,
    Value<String?>? subtitle,
    Value<bool>? isCompleted,
    Value<String>? status,
    Value<DateTime?>? completedAt,
    Value<int>? rolloverCount,
    Value<int?>? effort,
    Value<DateTime?>? originalDate,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      subtitle: subtitle ?? this.subtitle,
      isCompleted: isCompleted ?? this.isCompleted,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      rolloverCount: rolloverCount ?? this.rolloverCount,
      effort: effort ?? this.effort,
      originalDate: originalDate ?? this.originalDate,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startHour.present) {
      map['start_hour'] = Variable<int>(startHour.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endHour.present) {
      map['end_hour'] = Variable<int>(endHour.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rolloverCount.present) {
      map['rollover_count'] = Variable<int>(rolloverCount.value);
    }
    if (effort.present) {
      map['effort'] = Variable<int>(effort.value);
    }
    if (originalDate.present) {
      map['original_date'] = Variable<DateTime>(originalDate.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startHour: $startHour, ')
          ..write('startMinute: $startMinute, ')
          ..write('endHour: $endHour, ')
          ..write('endMinute: $endMinute, ')
          ..write('priority: $priority, ')
          ..write('category: $category, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('subtitle: $subtitle, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('rolloverCount: $rolloverCount, ')
          ..write('effort: $effort, ')
          ..write('originalDate: $originalDate, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accentColorValueMeta = const VerificationMeta(
    'accentColorValue',
  );
  @override
  late final GeneratedColumn<int> accentColorValue = GeneratedColumn<int>(
    'accent_color_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    body,
    mood,
    timestamp,
    accentColorValue,
    createdAt,
    updatedAt,
    dirty,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('accent_color_value')) {
      context.handle(
        _accentColorValueMeta,
        accentColorValue.isAcceptableOrUnknown(
          data['accent_color_value']!,
          _accentColorValueMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      accentColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accent_color_value'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntryRow extends DataClass implements Insertable<JournalEntryRow> {
  final String id;
  final String title;
  final String body;

  /// [JournalMood] enum name (e.g. "happy", "peaceful").
  final String mood;

  /// Entry timestamp ("entry_timestamp" in the API). Indexed — entries are
  /// always queried newest-first.
  final DateTime timestamp;

  /// ARGB int from [Color.toARGB32], nullable — [JournalEntry.accentColor]
  /// is optional.
  final int? accentColorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// See [Tasks.dirty] — same sync-pending semantics.
  final bool dirty;

  /// See [Tasks.deletedAt] — same soft-delete semantics.
  final DateTime? deletedAt;
  const JournalEntryRow({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.timestamp,
    this.accentColorValue,
    required this.createdAt,
    required this.updatedAt,
    required this.dirty,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['mood'] = Variable<String>(mood);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || accentColorValue != null) {
      map['accent_color_value'] = Variable<int>(accentColorValue);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      mood: Value(mood),
      timestamp: Value(timestamp),
      accentColorValue: accentColorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(accentColorValue),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory JournalEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntryRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      mood: serializer.fromJson<String>(json['mood']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      accentColorValue: serializer.fromJson<int?>(json['accentColorValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'mood': serializer.toJson<String>(mood),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'accentColorValue': serializer.toJson<int?>(accentColorValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  JournalEntryRow copyWith({
    String? id,
    String? title,
    String? body,
    String? mood,
    DateTime? timestamp,
    Value<int?> accentColorValue = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => JournalEntryRow(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    mood: mood ?? this.mood,
    timestamp: timestamp ?? this.timestamp,
    accentColorValue: accentColorValue.present
        ? accentColorValue.value
        : this.accentColorValue,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  JournalEntryRow copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntryRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      mood: data.mood.present ? data.mood.value : this.mood,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      accentColorValue: data.accentColorValue.present
          ? data.accentColorValue.value
          : this.accentColorValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntryRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('mood: $mood, ')
          ..write('timestamp: $timestamp, ')
          ..write('accentColorValue: $accentColorValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    body,
    mood,
    timestamp,
    accentColorValue,
    createdAt,
    updatedAt,
    dirty,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntryRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.mood == this.mood &&
          other.timestamp == this.timestamp &&
          other.accentColorValue == this.accentColorValue &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntryRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> body;
  final Value<String> mood;
  final Value<DateTime> timestamp;
  final Value<int?> accentColorValue;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.mood = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.accentColorValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    required String id,
    required String title,
    required String body,
    required String mood,
    required DateTime timestamp,
    this.accentColorValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       body = Value(body),
       mood = Value(mood),
       timestamp = Value(timestamp);
  static Insertable<JournalEntryRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? mood,
    Expression<DateTime>? timestamp,
    Expression<int>? accentColorValue,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (mood != null) 'mood': mood,
      if (timestamp != null) 'timestamp': timestamp,
      if (accentColorValue != null) 'accent_color_value': accentColorValue,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? body,
    Value<String>? mood,
    Value<DateTime>? timestamp,
    Value<int?>? accentColorValue,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      mood: mood ?? this.mood,
      timestamp: timestamp ?? this.timestamp,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (accentColorValue.present) {
      map['accent_color_value'] = Variable<int>(accentColorValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('mood: $mood, ')
          ..write('timestamp: $timestamp, ')
          ..write('accentColorValue: $accentColorValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CheckinsTable extends Checkins
    with TableInfo<$CheckinsTable, CheckinRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
    'energy',
    aliasedName,
    false,
    check: () => ComparableExpr(energy).isBetweenValues(1, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, at, energy, mood];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checkins';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckinRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    } else if (isInserting) {
      context.missing(_energyMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CheckinRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckinRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      ),
    );
  }

  @override
  $CheckinsTable createAlias(String alias) {
    return $CheckinsTable(attachedDatabase, alias);
  }
}

class CheckinRow extends DataClass implements Insertable<CheckinRow> {
  final String id;
  final DateTime at;
  final int energy;
  final String? mood;
  const CheckinRow({
    required this.id,
    required this.at,
    required this.energy,
    this.mood,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['at'] = Variable<DateTime>(at);
    map['energy'] = Variable<int>(energy);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    return map;
  }

  CheckinsCompanion toCompanion(bool nullToAbsent) {
    return CheckinsCompanion(
      id: Value(id),
      at: Value(at),
      energy: Value(energy),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
    );
  }

  factory CheckinRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckinRow(
      id: serializer.fromJson<String>(json['id']),
      at: serializer.fromJson<DateTime>(json['at']),
      energy: serializer.fromJson<int>(json['energy']),
      mood: serializer.fromJson<String?>(json['mood']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'at': serializer.toJson<DateTime>(at),
      'energy': serializer.toJson<int>(energy),
      'mood': serializer.toJson<String?>(mood),
    };
  }

  CheckinRow copyWith({
    String? id,
    DateTime? at,
    int? energy,
    Value<String?> mood = const Value.absent(),
  }) => CheckinRow(
    id: id ?? this.id,
    at: at ?? this.at,
    energy: energy ?? this.energy,
    mood: mood.present ? mood.value : this.mood,
  );
  CheckinRow copyWithCompanion(CheckinsCompanion data) {
    return CheckinRow(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
      energy: data.energy.present ? data.energy.value : this.energy,
      mood: data.mood.present ? data.mood.value : this.mood,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckinRow(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('energy: $energy, ')
          ..write('mood: $mood')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, at, energy, mood);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckinRow &&
          other.id == this.id &&
          other.at == this.at &&
          other.energy == this.energy &&
          other.mood == this.mood);
}

class CheckinsCompanion extends UpdateCompanion<CheckinRow> {
  final Value<String> id;
  final Value<DateTime> at;
  final Value<int> energy;
  final Value<String?> mood;
  final Value<int> rowid;
  const CheckinsCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
    this.energy = const Value.absent(),
    this.mood = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CheckinsCompanion.insert({
    required String id,
    required DateTime at,
    required int energy,
    this.mood = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       at = Value(at),
       energy = Value(energy);
  static Insertable<CheckinRow> custom({
    Expression<String>? id,
    Expression<DateTime>? at,
    Expression<int>? energy,
    Expression<String>? mood,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
      if (energy != null) 'energy': energy,
      if (mood != null) 'mood': mood,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CheckinsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? at,
    Value<int>? energy,
    Value<String?>? mood,
    Value<int>? rowid,
  }) {
    return CheckinsCompanion(
      id: id ?? this.id,
      at: at ?? this.at,
      energy: energy ?? this.energy,
      mood: mood ?? this.mood,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckinsCompanion(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('energy: $energy, ')
          ..write('mood: $mood, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayClosesTable extends DayCloses
    with TableInfo<$DayClosesTable, DayCloseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayClosesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<int> done = GeneratedColumn<int>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carriedMeta = const VerificationMeta(
    'carried',
  );
  @override
  late final GeneratedColumn<int> carried = GeneratedColumn<int>(
    'carried',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _releasedMeta = const VerificationMeta(
    'released',
  );
  @override
  late final GeneratedColumn<int> released = GeneratedColumn<int>(
    'released',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    closedAt,
    done,
    carried,
    released,
    journalEntryId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_closes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayCloseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_closedAtMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    } else if (isInserting) {
      context.missing(_doneMeta);
    }
    if (data.containsKey('carried')) {
      context.handle(
        _carriedMeta,
        carried.isAcceptableOrUnknown(data['carried']!, _carriedMeta),
      );
    } else if (isInserting) {
      context.missing(_carriedMeta);
    }
    if (data.containsKey('released')) {
      context.handle(
        _releasedMeta,
        released.isAcceptableOrUnknown(data['released']!, _releasedMeta),
      );
    } else if (isInserting) {
      context.missing(_releasedMeta);
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DayCloseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayCloseRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}done'],
      )!,
      carried: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carried'],
      )!,
      released: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}released'],
      )!,
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      ),
    );
  }

  @override
  $DayClosesTable createAlias(String alias) {
    return $DayClosesTable(attachedDatabase, alias);
  }
}

class DayCloseRow extends DataClass implements Insertable<DayCloseRow> {
  final DateTime date;
  final DateTime closedAt;
  final int done;
  final int carried;
  final int released;
  final String? journalEntryId;
  const DayCloseRow({
    required this.date,
    required this.closedAt,
    required this.done,
    required this.carried,
    required this.released,
    this.journalEntryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    map['closed_at'] = Variable<DateTime>(closedAt);
    map['done'] = Variable<int>(done);
    map['carried'] = Variable<int>(carried);
    map['released'] = Variable<int>(released);
    if (!nullToAbsent || journalEntryId != null) {
      map['journal_entry_id'] = Variable<String>(journalEntryId);
    }
    return map;
  }

  DayClosesCompanion toCompanion(bool nullToAbsent) {
    return DayClosesCompanion(
      date: Value(date),
      closedAt: Value(closedAt),
      done: Value(done),
      carried: Value(carried),
      released: Value(released),
      journalEntryId: journalEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(journalEntryId),
    );
  }

  factory DayCloseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayCloseRow(
      date: serializer.fromJson<DateTime>(json['date']),
      closedAt: serializer.fromJson<DateTime>(json['closedAt']),
      done: serializer.fromJson<int>(json['done']),
      carried: serializer.fromJson<int>(json['carried']),
      released: serializer.fromJson<int>(json['released']),
      journalEntryId: serializer.fromJson<String?>(json['journalEntryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'closedAt': serializer.toJson<DateTime>(closedAt),
      'done': serializer.toJson<int>(done),
      'carried': serializer.toJson<int>(carried),
      'released': serializer.toJson<int>(released),
      'journalEntryId': serializer.toJson<String?>(journalEntryId),
    };
  }

  DayCloseRow copyWith({
    DateTime? date,
    DateTime? closedAt,
    int? done,
    int? carried,
    int? released,
    Value<String?> journalEntryId = const Value.absent(),
  }) => DayCloseRow(
    date: date ?? this.date,
    closedAt: closedAt ?? this.closedAt,
    done: done ?? this.done,
    carried: carried ?? this.carried,
    released: released ?? this.released,
    journalEntryId: journalEntryId.present
        ? journalEntryId.value
        : this.journalEntryId,
  );
  DayCloseRow copyWithCompanion(DayClosesCompanion data) {
    return DayCloseRow(
      date: data.date.present ? data.date.value : this.date,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      done: data.done.present ? data.done.value : this.done,
      carried: data.carried.present ? data.carried.value : this.carried,
      released: data.released.present ? data.released.value : this.released,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayCloseRow(')
          ..write('date: $date, ')
          ..write('closedAt: $closedAt, ')
          ..write('done: $done, ')
          ..write('carried: $carried, ')
          ..write('released: $released, ')
          ..write('journalEntryId: $journalEntryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(date, closedAt, done, carried, released, journalEntryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayCloseRow &&
          other.date == this.date &&
          other.closedAt == this.closedAt &&
          other.done == this.done &&
          other.carried == this.carried &&
          other.released == this.released &&
          other.journalEntryId == this.journalEntryId);
}

class DayClosesCompanion extends UpdateCompanion<DayCloseRow> {
  final Value<DateTime> date;
  final Value<DateTime> closedAt;
  final Value<int> done;
  final Value<int> carried;
  final Value<int> released;
  final Value<String?> journalEntryId;
  final Value<int> rowid;
  const DayClosesCompanion({
    this.date = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.done = const Value.absent(),
    this.carried = const Value.absent(),
    this.released = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayClosesCompanion.insert({
    required DateTime date,
    required DateTime closedAt,
    required int done,
    required int carried,
    required int released,
    this.journalEntryId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       closedAt = Value(closedAt),
       done = Value(done),
       carried = Value(carried),
       released = Value(released);
  static Insertable<DayCloseRow> custom({
    Expression<DateTime>? date,
    Expression<DateTime>? closedAt,
    Expression<int>? done,
    Expression<int>? carried,
    Expression<int>? released,
    Expression<String>? journalEntryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (closedAt != null) 'closed_at': closedAt,
      if (done != null) 'done': done,
      if (carried != null) 'carried': carried,
      if (released != null) 'released': released,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayClosesCompanion copyWith({
    Value<DateTime>? date,
    Value<DateTime>? closedAt,
    Value<int>? done,
    Value<int>? carried,
    Value<int>? released,
    Value<String?>? journalEntryId,
    Value<int>? rowid,
  }) {
    return DayClosesCompanion(
      date: date ?? this.date,
      closedAt: closedAt ?? this.closedAt,
      done: done ?? this.done,
      carried: carried ?? this.carried,
      released: released ?? this.released,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (done.present) {
      map['done'] = Variable<int>(done.value);
    }
    if (carried.present) {
      map['carried'] = Variable<int>(carried.value);
    }
    if (released.present) {
      map['released'] = Variable<int>(released.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayClosesCompanion(')
          ..write('date: $date, ')
          ..write('closedAt: $closedAt, ')
          ..write('done: $done, ')
          ..write('carried: $carried, ')
          ..write('released: $released, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RhythmProfileTable extends RhythmProfile
    with TableInfo<$RhythmProfileTable, RhythmBinRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RhythmProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _binMeta = const VerificationMeta('bin');
  @override
  late final GeneratedColumn<int> bin = GeneratedColumn<int>(
    'bin',
    aliasedName,
    false,
    check: () => ComparableExpr(bin).isBetweenValues(0, 23),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [bin, value, weight, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rhythm_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<RhythmBinRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bin')) {
      context.handle(
        _binMeta,
        bin.isAcceptableOrUnknown(data['bin']!, _binMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bin};
  @override
  RhythmBinRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RhythmBinRow(
      bin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bin'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RhythmProfileTable createAlias(String alias) {
    return $RhythmProfileTable(attachedDatabase, alias);
  }
}

class RhythmBinRow extends DataClass implements Insertable<RhythmBinRow> {
  final int bin;
  final double value;
  final double weight;
  final DateTime updatedAt;
  const RhythmBinRow({
    required this.bin,
    required this.value,
    required this.weight,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bin'] = Variable<int>(bin);
    map['value'] = Variable<double>(value);
    map['weight'] = Variable<double>(weight);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RhythmProfileCompanion toCompanion(bool nullToAbsent) {
    return RhythmProfileCompanion(
      bin: Value(bin),
      value: Value(value),
      weight: Value(weight),
      updatedAt: Value(updatedAt),
    );
  }

  factory RhythmBinRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RhythmBinRow(
      bin: serializer.fromJson<int>(json['bin']),
      value: serializer.fromJson<double>(json['value']),
      weight: serializer.fromJson<double>(json['weight']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bin': serializer.toJson<int>(bin),
      'value': serializer.toJson<double>(value),
      'weight': serializer.toJson<double>(weight),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RhythmBinRow copyWith({
    int? bin,
    double? value,
    double? weight,
    DateTime? updatedAt,
  }) => RhythmBinRow(
    bin: bin ?? this.bin,
    value: value ?? this.value,
    weight: weight ?? this.weight,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RhythmBinRow copyWithCompanion(RhythmProfileCompanion data) {
    return RhythmBinRow(
      bin: data.bin.present ? data.bin.value : this.bin,
      value: data.value.present ? data.value.value : this.value,
      weight: data.weight.present ? data.weight.value : this.weight,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RhythmBinRow(')
          ..write('bin: $bin, ')
          ..write('value: $value, ')
          ..write('weight: $weight, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bin, value, weight, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RhythmBinRow &&
          other.bin == this.bin &&
          other.value == this.value &&
          other.weight == this.weight &&
          other.updatedAt == this.updatedAt);
}

class RhythmProfileCompanion extends UpdateCompanion<RhythmBinRow> {
  final Value<int> bin;
  final Value<double> value;
  final Value<double> weight;
  final Value<DateTime> updatedAt;
  const RhythmProfileCompanion({
    this.bin = const Value.absent(),
    this.value = const Value.absent(),
    this.weight = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RhythmProfileCompanion.insert({
    this.bin = const Value.absent(),
    required double value,
    required double weight,
    required DateTime updatedAt,
  }) : value = Value(value),
       weight = Value(weight),
       updatedAt = Value(updatedAt);
  static Insertable<RhythmBinRow> custom({
    Expression<int>? bin,
    Expression<double>? value,
    Expression<double>? weight,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (bin != null) 'bin': bin,
      if (value != null) 'value': value,
      if (weight != null) 'weight': weight,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RhythmProfileCompanion copyWith({
    Value<int>? bin,
    Value<double>? value,
    Value<double>? weight,
    Value<DateTime>? updatedAt,
  }) {
    return RhythmProfileCompanion(
      bin: bin ?? this.bin,
      value: value ?? this.value,
      weight: weight ?? this.weight,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bin.present) {
      map['bin'] = Variable<int>(bin.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RhythmProfileCompanion(')
          ..write('bin: $bin, ')
          ..write('value: $value, ')
          ..write('weight: $weight, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CountersTable extends Counters
    with TableInfo<$CountersTable, CounterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'counters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CounterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  CounterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CounterRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CountersTable createAlias(String alias) {
    return $CountersTable(attachedDatabase, alias);
  }
}

class CounterRow extends DataClass implements Insertable<CounterRow> {
  final String key;
  final int value;
  final DateTime updatedAt;
  const CounterRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<int>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CountersCompanion toCompanion(bool nullToAbsent) {
    return CountersCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory CounterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CounterRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<int>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<int>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CounterRow copyWith({String? key, int? value, DateTime? updatedAt}) =>
      CounterRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CounterRow copyWithCompanion(CountersCompanion data) {
    return CounterRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CounterRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CounterRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class CountersCompanion extends UpdateCompanion<CounterRow> {
  final Value<String> key;
  final Value<int> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CountersCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountersCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       updatedAt = Value(updatedAt);
  static Insertable<CounterRow> custom({
    Expression<String>? key,
    Expression<int>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountersCompanion copyWith({
    Value<String>? key,
    Value<int>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CountersCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountersCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $CheckinsTable checkins = $CheckinsTable(this);
  late final $DayClosesTable dayCloses = $DayClosesTable(this);
  late final $RhythmProfileTable rhythmProfile = $RhythmProfileTable(this);
  late final $CountersTable counters = $CountersTable(this);
  late final Index idxTasksDate = Index(
    'idx_tasks_date',
    'CREATE INDEX idx_tasks_date ON tasks (date)',
  );
  late final Index idxTasksDeletedAt = Index(
    'idx_tasks_deleted_at',
    'CREATE INDEX idx_tasks_deleted_at ON tasks (deleted_at)',
  );
  late final Index idxJournalTimestamp = Index(
    'idx_journal_timestamp',
    'CREATE INDEX idx_journal_timestamp ON journal_entries (timestamp)',
  );
  late final Index idxJournalDeletedAt = Index(
    'idx_journal_deleted_at',
    'CREATE INDEX idx_journal_deleted_at ON journal_entries (deleted_at)',
  );
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  late final JournalDao journalDao = JournalDao(this as AppDatabase);
  late final LocalOnlyDao localOnlyDao = LocalOnlyDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    journalEntries,
    checkins,
    dayCloses,
    rhythmProfile,
    counters,
    idxTasksDate,
    idxTasksDeletedAt,
    idxJournalTimestamp,
    idxJournalDeletedAt,
  ];
}

typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required String id,
      required String title,
      required int startHour,
      required int startMinute,
      required int endHour,
      required int endMinute,
      required String priority,
      required String category,
      Value<int?> iconCodePoint,
      Value<String?> subtitle,
      Value<bool> isCompleted,
      Value<String> status,
      Value<DateTime?> completedAt,
      Value<int> rolloverCount,
      Value<int?> effort,
      Value<DateTime?> originalDate,
      required DateTime date,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> startHour,
      Value<int> startMinute,
      Value<int> endHour,
      Value<int> endMinute,
      Value<String> priority,
      Value<String> category,
      Value<int?> iconCodePoint,
      Value<String?> subtitle,
      Value<bool> isCompleted,
      Value<String> status,
      Value<DateTime?> completedAt,
      Value<int> rolloverCount,
      Value<int?> effort,
      Value<DateTime?> originalDate,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startHour => $composableBuilder(
    column: $table.startHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endHour => $composableBuilder(
    column: $table.endHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rolloverCount => $composableBuilder(
    column: $table.rolloverCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effort => $composableBuilder(
    column: $table.effort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startHour => $composableBuilder(
    column: $table.startHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endHour => $composableBuilder(
    column: $table.endHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rolloverCount => $composableBuilder(
    column: $table.rolloverCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effort => $composableBuilder(
    column: $table.effort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get startHour =>
      $composableBuilder(column: $table.startHour, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endHour =>
      $composableBuilder(column: $table.endHour, builder: (column) => column);

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rolloverCount => $composableBuilder(
    column: $table.rolloverCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get effort =>
      $composableBuilder(column: $table.effort, builder: (column) => column);

  GeneratedColumn<DateTime> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
          TaskRow,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> startHour = const Value.absent(),
                Value<int> startMinute = const Value.absent(),
                Value<int> endHour = const Value.absent(),
                Value<int> endMinute = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int?> iconCodePoint = const Value.absent(),
                Value<String?> subtitle = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rolloverCount = const Value.absent(),
                Value<int?> effort = const Value.absent(),
                Value<DateTime?> originalDate = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                startHour: startHour,
                startMinute: startMinute,
                endHour: endHour,
                endMinute: endMinute,
                priority: priority,
                category: category,
                iconCodePoint: iconCodePoint,
                subtitle: subtitle,
                isCompleted: isCompleted,
                status: status,
                completedAt: completedAt,
                rolloverCount: rolloverCount,
                effort: effort,
                originalDate: originalDate,
                date: date,
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int startHour,
                required int startMinute,
                required int endHour,
                required int endMinute,
                required String priority,
                required String category,
                Value<int?> iconCodePoint = const Value.absent(),
                Value<String?> subtitle = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rolloverCount = const Value.absent(),
                Value<int?> effort = const Value.absent(),
                Value<DateTime?> originalDate = const Value.absent(),
                required DateTime date,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                startHour: startHour,
                startMinute: startMinute,
                endHour: endHour,
                endMinute: endMinute,
                priority: priority,
                category: category,
                iconCodePoint: iconCodePoint,
                subtitle: subtitle,
                isCompleted: isCompleted,
                status: status,
                completedAt: completedAt,
                rolloverCount: rolloverCount,
                effort: effort,
                originalDate: originalDate,
                date: date,
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, TaskRow>(table),
                  BaseReferences<_$AppDatabase, $TasksTable, TaskRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
      TaskRow,
      PrefetchHooks Function()
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      required String id,
      required String title,
      required String body,
      required String mood,
      required DateTime timestamp,
      Value<int?> accentColorValue,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> body,
      Value<String> mood,
      Value<DateTime> timestamp,
      Value<int?> accentColorValue,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accentColorValue => $composableBuilder(
    column: $table.accentColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accentColorValue => $composableBuilder(
    column: $table.accentColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get accentColorValue => $composableBuilder(
    column: $table.accentColorValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntryRow,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntryRow,
            BaseReferences<
              _$AppDatabase,
              $JournalEntriesTable,
              JournalEntryRow
            >,
          ),
          JournalEntryRow,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> mood = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int?> accentColorValue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                title: title,
                body: body,
                mood: mood,
                timestamp: timestamp,
                accentColorValue: accentColorValue,
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String body,
                required String mood,
                required DateTime timestamp,
                Value<int?> accentColorValue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                title: title,
                body: body,
                mood: mood,
                timestamp: timestamp,
                accentColorValue: accentColorValue,
                createdAt: createdAt,
                updatedAt: updatedAt,
                dirty: dirty,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JournalEntriesTable, JournalEntryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $JournalEntriesTable,
                    JournalEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntryRow,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntryRow,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntryRow>,
      ),
      JournalEntryRow,
      PrefetchHooks Function()
    >;
typedef $$CheckinsTableCreateCompanionBuilder =
    CheckinsCompanion Function({
      required String id,
      required DateTime at,
      required int energy,
      Value<String?> mood,
      Value<int> rowid,
    });
typedef $$CheckinsTableUpdateCompanionBuilder =
    CheckinsCompanion Function({
      Value<String> id,
      Value<DateTime> at,
      Value<int> energy,
      Value<String?> mood,
      Value<int> rowid,
    });

class $$CheckinsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CheckinsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CheckinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);
}

class $$CheckinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckinsTable,
          CheckinRow,
          $$CheckinsTableFilterComposer,
          $$CheckinsTableOrderingComposer,
          $$CheckinsTableAnnotationComposer,
          $$CheckinsTableCreateCompanionBuilder,
          $$CheckinsTableUpdateCompanionBuilder,
          (
            CheckinRow,
            BaseReferences<_$AppDatabase, $CheckinsTable, CheckinRow>,
          ),
          CheckinRow,
          PrefetchHooks Function()
        > {
  $$CheckinsTableTableManager(_$AppDatabase db, $CheckinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> energy = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CheckinsCompanion(
                id: id,
                at: at,
                energy: energy,
                mood: mood,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime at,
                required int energy,
                Value<String?> mood = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CheckinsCompanion.insert(
                id: id,
                at: at,
                energy: energy,
                mood: mood,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CheckinsTable, CheckinRow>(table),
                  BaseReferences<_$AppDatabase, $CheckinsTable, CheckinRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CheckinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckinsTable,
      CheckinRow,
      $$CheckinsTableFilterComposer,
      $$CheckinsTableOrderingComposer,
      $$CheckinsTableAnnotationComposer,
      $$CheckinsTableCreateCompanionBuilder,
      $$CheckinsTableUpdateCompanionBuilder,
      (CheckinRow, BaseReferences<_$AppDatabase, $CheckinsTable, CheckinRow>),
      CheckinRow,
      PrefetchHooks Function()
    >;
typedef $$DayClosesTableCreateCompanionBuilder =
    DayClosesCompanion Function({
      required DateTime date,
      required DateTime closedAt,
      required int done,
      required int carried,
      required int released,
      Value<String?> journalEntryId,
      Value<int> rowid,
    });
typedef $$DayClosesTableUpdateCompanionBuilder =
    DayClosesCompanion Function({
      Value<DateTime> date,
      Value<DateTime> closedAt,
      Value<int> done,
      Value<int> carried,
      Value<int> released,
      Value<String?> journalEntryId,
      Value<int> rowid,
    });

class $$DayClosesTableFilterComposer
    extends Composer<_$AppDatabase, $DayClosesTable> {
  $$DayClosesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get carried => $composableBuilder(
    column: $table.carried,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get released => $composableBuilder(
    column: $table.released,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayClosesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayClosesTable> {
  $$DayClosesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get carried => $composableBuilder(
    column: $table.carried,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get released => $composableBuilder(
    column: $table.released,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayClosesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayClosesTable> {
  $$DayClosesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<int> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<int> get carried =>
      $composableBuilder(column: $table.carried, builder: (column) => column);

  GeneratedColumn<int> get released =>
      $composableBuilder(column: $table.released, builder: (column) => column);

  GeneratedColumn<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => column,
  );
}

class $$DayClosesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayClosesTable,
          DayCloseRow,
          $$DayClosesTableFilterComposer,
          $$DayClosesTableOrderingComposer,
          $$DayClosesTableAnnotationComposer,
          $$DayClosesTableCreateCompanionBuilder,
          $$DayClosesTableUpdateCompanionBuilder,
          (
            DayCloseRow,
            BaseReferences<_$AppDatabase, $DayClosesTable, DayCloseRow>,
          ),
          DayCloseRow,
          PrefetchHooks Function()
        > {
  $$DayClosesTableTableManager(_$AppDatabase db, $DayClosesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayClosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayClosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayClosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> closedAt = const Value.absent(),
                Value<int> done = const Value.absent(),
                Value<int> carried = const Value.absent(),
                Value<int> released = const Value.absent(),
                Value<String?> journalEntryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayClosesCompanion(
                date: date,
                closedAt: closedAt,
                done: done,
                carried: carried,
                released: released,
                journalEntryId: journalEntryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime date,
                required DateTime closedAt,
                required int done,
                required int carried,
                required int released,
                Value<String?> journalEntryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayClosesCompanion.insert(
                date: date,
                closedAt: closedAt,
                done: done,
                carried: carried,
                released: released,
                journalEntryId: journalEntryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DayClosesTable, DayCloseRow>(table),
                  BaseReferences<_$AppDatabase, $DayClosesTable, DayCloseRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayClosesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayClosesTable,
      DayCloseRow,
      $$DayClosesTableFilterComposer,
      $$DayClosesTableOrderingComposer,
      $$DayClosesTableAnnotationComposer,
      $$DayClosesTableCreateCompanionBuilder,
      $$DayClosesTableUpdateCompanionBuilder,
      (
        DayCloseRow,
        BaseReferences<_$AppDatabase, $DayClosesTable, DayCloseRow>,
      ),
      DayCloseRow,
      PrefetchHooks Function()
    >;
typedef $$RhythmProfileTableCreateCompanionBuilder =
    RhythmProfileCompanion Function({
      Value<int> bin,
      required double value,
      required double weight,
      required DateTime updatedAt,
    });
typedef $$RhythmProfileTableUpdateCompanionBuilder =
    RhythmProfileCompanion Function({
      Value<int> bin,
      Value<double> value,
      Value<double> weight,
      Value<DateTime> updatedAt,
    });

class $$RhythmProfileTableFilterComposer
    extends Composer<_$AppDatabase, $RhythmProfileTable> {
  $$RhythmProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get bin => $composableBuilder(
    column: $table.bin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RhythmProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $RhythmProfileTable> {
  $$RhythmProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get bin => $composableBuilder(
    column: $table.bin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RhythmProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $RhythmProfileTable> {
  $$RhythmProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get bin =>
      $composableBuilder(column: $table.bin, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RhythmProfileTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RhythmProfileTable,
          RhythmBinRow,
          $$RhythmProfileTableFilterComposer,
          $$RhythmProfileTableOrderingComposer,
          $$RhythmProfileTableAnnotationComposer,
          $$RhythmProfileTableCreateCompanionBuilder,
          $$RhythmProfileTableUpdateCompanionBuilder,
          (
            RhythmBinRow,
            BaseReferences<_$AppDatabase, $RhythmProfileTable, RhythmBinRow>,
          ),
          RhythmBinRow,
          PrefetchHooks Function()
        > {
  $$RhythmProfileTableTableManager(_$AppDatabase db, $RhythmProfileTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RhythmProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RhythmProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RhythmProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> bin = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RhythmProfileCompanion(
                bin: bin,
                value: value,
                weight: weight,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> bin = const Value.absent(),
                required double value,
                required double weight,
                required DateTime updatedAt,
              }) => RhythmProfileCompanion.insert(
                bin: bin,
                value: value,
                weight: weight,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RhythmProfileTable, RhythmBinRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RhythmProfileTable,
                    RhythmBinRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RhythmProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RhythmProfileTable,
      RhythmBinRow,
      $$RhythmProfileTableFilterComposer,
      $$RhythmProfileTableOrderingComposer,
      $$RhythmProfileTableAnnotationComposer,
      $$RhythmProfileTableCreateCompanionBuilder,
      $$RhythmProfileTableUpdateCompanionBuilder,
      (
        RhythmBinRow,
        BaseReferences<_$AppDatabase, $RhythmProfileTable, RhythmBinRow>,
      ),
      RhythmBinRow,
      PrefetchHooks Function()
    >;
typedef $$CountersTableCreateCompanionBuilder =
    CountersCompanion Function({
      required String key,
      Value<int> value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CountersTableUpdateCompanionBuilder =
    CountersCompanion Function({
      Value<String> key,
      Value<int> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CountersTableFilterComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CountersTableOrderingComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CountersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CountersTable,
          CounterRow,
          $$CountersTableFilterComposer,
          $$CountersTableOrderingComposer,
          $$CountersTableAnnotationComposer,
          $$CountersTableCreateCompanionBuilder,
          $$CountersTableUpdateCompanionBuilder,
          (
            CounterRow,
            BaseReferences<_$AppDatabase, $CountersTable, CounterRow>,
          ),
          CounterRow,
          PrefetchHooks Function()
        > {
  $$CountersTableTableManager(_$AppDatabase db, $CountersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CountersCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<int> value = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CountersCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CountersTable, CounterRow>(table),
                  BaseReferences<_$AppDatabase, $CountersTable, CounterRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CountersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CountersTable,
      CounterRow,
      $$CountersTableFilterComposer,
      $$CountersTableOrderingComposer,
      $$CountersTableAnnotationComposer,
      $$CountersTableCreateCompanionBuilder,
      $$CountersTableUpdateCompanionBuilder,
      (CounterRow, BaseReferences<_$AppDatabase, $CountersTable, CounterRow>),
      CounterRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$CheckinsTableTableManager get checkins =>
      $$CheckinsTableTableManager(_db, _db.checkins);
  $$DayClosesTableTableManager get dayCloses =>
      $$DayClosesTableTableManager(_db, _db.dayCloses);
  $$RhythmProfileTableTableManager get rhythmProfile =>
      $$RhythmProfileTableTableManager(_db, _db.rhythmProfile);
  $$CountersTableTableManager get counters =>
      $$CountersTableTableManager(_db, _db.counters);
}
