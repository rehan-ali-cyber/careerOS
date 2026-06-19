// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAiMeta = const VerificationMeta('isAi');
  @override
  late final GeneratedColumn<bool> isAi = GeneratedColumn<bool>(
    'is_ai',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ai" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [id, content, isAi, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_ai')) {
      context.handle(
        _isAiMeta,
        isAi.isAcceptableOrUnknown(data['is_ai']!, _isAiMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      isAi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ai'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final String content;
  final bool isAi;
  final DateTime createdAt;
  const ChatMessage({
    required this.id,
    required this.content,
    required this.isAi,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content'] = Variable<String>(content);
    map['is_ai'] = Variable<bool>(isAi);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      content: Value(content),
      isAi: Value(isAi),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      isAi: serializer.fromJson<bool>(json['isAi']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String>(content),
      'isAi': serializer.toJson<bool>(isAi),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessage copyWith({
    int? id,
    String? content,
    bool? isAi,
    DateTime? createdAt,
  }) => ChatMessage(
    id: id ?? this.id,
    content: content ?? this.content,
    isAi: isAi ?? this.isAi,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      isAi: data.isAi.present ? data.isAi.value : this.isAi,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('isAi: $isAi, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content, isAi, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.content == this.content &&
          other.isAi == this.isAi &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<String> content;
  final Value<bool> isAi;
  final Value<DateTime> createdAt;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.isAi = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String content,
    this.isAi = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : content = Value(content);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<String>? content,
    Expression<bool>? isAi,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (isAi != null) 'is_ai': isAi,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? content,
    Value<bool>? isAi,
    Value<DateTime>? createdAt,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      isAi: isAi ?? this.isAi,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isAi.present) {
      map['is_ai'] = Variable<bool>(isAi.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('isAi: $isAi, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserCalibrationTable extends UserCalibration
    with TableInfo<$UserCalibrationTable, UserCalibrationData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCalibrationTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _targetCareerMeta = const VerificationMeta(
    'targetCareer',
  );
  @override
  late final GeneratedColumn<String> targetCareer = GeneratedColumn<String>(
    'target_career',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skillLevelMeta = const VerificationMeta(
    'skillLevel',
  );
  @override
  late final GeneratedColumn<int> skillLevel = GeneratedColumn<int>(
    'skill_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dailyHoursMeta = const VerificationMeta(
    'dailyHours',
  );
  @override
  late final GeneratedColumn<int> dailyHours = GeneratedColumn<int>(
    'daily_hours',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _dreamCompanyMeta = const VerificationMeta(
    'dreamCompany',
  );
  @override
  late final GeneratedColumn<String> dreamCompany = GeneratedColumn<String>(
    'dream_company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _counselingQuestionIndexMeta =
      const VerificationMeta('counselingQuestionIndex');
  @override
  late final GeneratedColumn<int> counselingQuestionIndex =
      GeneratedColumn<int>(
        'counseling_question_index',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _counselingContextJsonMeta =
      const VerificationMeta('counselingContextJson');
  @override
  late final GeneratedColumn<String> counselingContextJson =
      GeneratedColumn<String>(
        'counseling_context_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetCareer,
    skillLevel,
    dailyHours,
    dreamCompany,
    counselingQuestionIndex,
    counselingContextJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_calibration';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserCalibrationData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_career')) {
      context.handle(
        _targetCareerMeta,
        targetCareer.isAcceptableOrUnknown(
          data['target_career']!,
          _targetCareerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCareerMeta);
    }
    if (data.containsKey('skill_level')) {
      context.handle(
        _skillLevelMeta,
        skillLevel.isAcceptableOrUnknown(data['skill_level']!, _skillLevelMeta),
      );
    }
    if (data.containsKey('daily_hours')) {
      context.handle(
        _dailyHoursMeta,
        dailyHours.isAcceptableOrUnknown(data['daily_hours']!, _dailyHoursMeta),
      );
    }
    if (data.containsKey('dream_company')) {
      context.handle(
        _dreamCompanyMeta,
        dreamCompany.isAcceptableOrUnknown(
          data['dream_company']!,
          _dreamCompanyMeta,
        ),
      );
    }
    if (data.containsKey('counseling_question_index')) {
      context.handle(
        _counselingQuestionIndexMeta,
        counselingQuestionIndex.isAcceptableOrUnknown(
          data['counseling_question_index']!,
          _counselingQuestionIndexMeta,
        ),
      );
    }
    if (data.containsKey('counseling_context_json')) {
      context.handle(
        _counselingContextJsonMeta,
        counselingContextJson.isAcceptableOrUnknown(
          data['counseling_context_json']!,
          _counselingContextJsonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserCalibrationData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCalibrationData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetCareer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_career'],
      )!,
      skillLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skill_level'],
      )!,
      dailyHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_hours'],
      )!,
      dreamCompany: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dream_company'],
      ),
      counselingQuestionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}counseling_question_index'],
      )!,
      counselingContextJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counseling_context_json'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserCalibrationTable createAlias(String alias) {
    return $UserCalibrationTable(attachedDatabase, alias);
  }
}

class UserCalibrationData extends DataClass
    implements Insertable<UserCalibrationData> {
  final int id;
  final String targetCareer;
  final int skillLevel;
  final int dailyHours;
  final String? dreamCompany;
  final int counselingQuestionIndex;
  final String? counselingContextJson;
  final DateTime updatedAt;
  const UserCalibrationData({
    required this.id,
    required this.targetCareer,
    required this.skillLevel,
    required this.dailyHours,
    this.dreamCompany,
    required this.counselingQuestionIndex,
    this.counselingContextJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_career'] = Variable<String>(targetCareer);
    map['skill_level'] = Variable<int>(skillLevel);
    map['daily_hours'] = Variable<int>(dailyHours);
    if (!nullToAbsent || dreamCompany != null) {
      map['dream_company'] = Variable<String>(dreamCompany);
    }
    map['counseling_question_index'] = Variable<int>(counselingQuestionIndex);
    if (!nullToAbsent || counselingContextJson != null) {
      map['counseling_context_json'] = Variable<String>(counselingContextJson);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserCalibrationCompanion toCompanion(bool nullToAbsent) {
    return UserCalibrationCompanion(
      id: Value(id),
      targetCareer: Value(targetCareer),
      skillLevel: Value(skillLevel),
      dailyHours: Value(dailyHours),
      dreamCompany: dreamCompany == null && nullToAbsent
          ? const Value.absent()
          : Value(dreamCompany),
      counselingQuestionIndex: Value(counselingQuestionIndex),
      counselingContextJson: counselingContextJson == null && nullToAbsent
          ? const Value.absent()
          : Value(counselingContextJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserCalibrationData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCalibrationData(
      id: serializer.fromJson<int>(json['id']),
      targetCareer: serializer.fromJson<String>(json['targetCareer']),
      skillLevel: serializer.fromJson<int>(json['skillLevel']),
      dailyHours: serializer.fromJson<int>(json['dailyHours']),
      dreamCompany: serializer.fromJson<String?>(json['dreamCompany']),
      counselingQuestionIndex: serializer.fromJson<int>(
        json['counselingQuestionIndex'],
      ),
      counselingContextJson: serializer.fromJson<String?>(
        json['counselingContextJson'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetCareer': serializer.toJson<String>(targetCareer),
      'skillLevel': serializer.toJson<int>(skillLevel),
      'dailyHours': serializer.toJson<int>(dailyHours),
      'dreamCompany': serializer.toJson<String?>(dreamCompany),
      'counselingQuestionIndex': serializer.toJson<int>(
        counselingQuestionIndex,
      ),
      'counselingContextJson': serializer.toJson<String?>(
        counselingContextJson,
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserCalibrationData copyWith({
    int? id,
    String? targetCareer,
    int? skillLevel,
    int? dailyHours,
    Value<String?> dreamCompany = const Value.absent(),
    int? counselingQuestionIndex,
    Value<String?> counselingContextJson = const Value.absent(),
    DateTime? updatedAt,
  }) => UserCalibrationData(
    id: id ?? this.id,
    targetCareer: targetCareer ?? this.targetCareer,
    skillLevel: skillLevel ?? this.skillLevel,
    dailyHours: dailyHours ?? this.dailyHours,
    dreamCompany: dreamCompany.present ? dreamCompany.value : this.dreamCompany,
    counselingQuestionIndex:
        counselingQuestionIndex ?? this.counselingQuestionIndex,
    counselingContextJson: counselingContextJson.present
        ? counselingContextJson.value
        : this.counselingContextJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserCalibrationData copyWithCompanion(UserCalibrationCompanion data) {
    return UserCalibrationData(
      id: data.id.present ? data.id.value : this.id,
      targetCareer: data.targetCareer.present
          ? data.targetCareer.value
          : this.targetCareer,
      skillLevel: data.skillLevel.present
          ? data.skillLevel.value
          : this.skillLevel,
      dailyHours: data.dailyHours.present
          ? data.dailyHours.value
          : this.dailyHours,
      dreamCompany: data.dreamCompany.present
          ? data.dreamCompany.value
          : this.dreamCompany,
      counselingQuestionIndex: data.counselingQuestionIndex.present
          ? data.counselingQuestionIndex.value
          : this.counselingQuestionIndex,
      counselingContextJson: data.counselingContextJson.present
          ? data.counselingContextJson.value
          : this.counselingContextJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCalibrationData(')
          ..write('id: $id, ')
          ..write('targetCareer: $targetCareer, ')
          ..write('skillLevel: $skillLevel, ')
          ..write('dailyHours: $dailyHours, ')
          ..write('dreamCompany: $dreamCompany, ')
          ..write('counselingQuestionIndex: $counselingQuestionIndex, ')
          ..write('counselingContextJson: $counselingContextJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetCareer,
    skillLevel,
    dailyHours,
    dreamCompany,
    counselingQuestionIndex,
    counselingContextJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCalibrationData &&
          other.id == this.id &&
          other.targetCareer == this.targetCareer &&
          other.skillLevel == this.skillLevel &&
          other.dailyHours == this.dailyHours &&
          other.dreamCompany == this.dreamCompany &&
          other.counselingQuestionIndex == this.counselingQuestionIndex &&
          other.counselingContextJson == this.counselingContextJson &&
          other.updatedAt == this.updatedAt);
}

class UserCalibrationCompanion extends UpdateCompanion<UserCalibrationData> {
  final Value<int> id;
  final Value<String> targetCareer;
  final Value<int> skillLevel;
  final Value<int> dailyHours;
  final Value<String?> dreamCompany;
  final Value<int> counselingQuestionIndex;
  final Value<String?> counselingContextJson;
  final Value<DateTime> updatedAt;
  const UserCalibrationCompanion({
    this.id = const Value.absent(),
    this.targetCareer = const Value.absent(),
    this.skillLevel = const Value.absent(),
    this.dailyHours = const Value.absent(),
    this.dreamCompany = const Value.absent(),
    this.counselingQuestionIndex = const Value.absent(),
    this.counselingContextJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserCalibrationCompanion.insert({
    this.id = const Value.absent(),
    required String targetCareer,
    this.skillLevel = const Value.absent(),
    this.dailyHours = const Value.absent(),
    this.dreamCompany = const Value.absent(),
    this.counselingQuestionIndex = const Value.absent(),
    this.counselingContextJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : targetCareer = Value(targetCareer);
  static Insertable<UserCalibrationData> custom({
    Expression<int>? id,
    Expression<String>? targetCareer,
    Expression<int>? skillLevel,
    Expression<int>? dailyHours,
    Expression<String>? dreamCompany,
    Expression<int>? counselingQuestionIndex,
    Expression<String>? counselingContextJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetCareer != null) 'target_career': targetCareer,
      if (skillLevel != null) 'skill_level': skillLevel,
      if (dailyHours != null) 'daily_hours': dailyHours,
      if (dreamCompany != null) 'dream_company': dreamCompany,
      if (counselingQuestionIndex != null)
        'counseling_question_index': counselingQuestionIndex,
      if (counselingContextJson != null)
        'counseling_context_json': counselingContextJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserCalibrationCompanion copyWith({
    Value<int>? id,
    Value<String>? targetCareer,
    Value<int>? skillLevel,
    Value<int>? dailyHours,
    Value<String?>? dreamCompany,
    Value<int>? counselingQuestionIndex,
    Value<String?>? counselingContextJson,
    Value<DateTime>? updatedAt,
  }) {
    return UserCalibrationCompanion(
      id: id ?? this.id,
      targetCareer: targetCareer ?? this.targetCareer,
      skillLevel: skillLevel ?? this.skillLevel,
      dailyHours: dailyHours ?? this.dailyHours,
      dreamCompany: dreamCompany ?? this.dreamCompany,
      counselingQuestionIndex:
          counselingQuestionIndex ?? this.counselingQuestionIndex,
      counselingContextJson:
          counselingContextJson ?? this.counselingContextJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetCareer.present) {
      map['target_career'] = Variable<String>(targetCareer.value);
    }
    if (skillLevel.present) {
      map['skill_level'] = Variable<int>(skillLevel.value);
    }
    if (dailyHours.present) {
      map['daily_hours'] = Variable<int>(dailyHours.value);
    }
    if (dreamCompany.present) {
      map['dream_company'] = Variable<String>(dreamCompany.value);
    }
    if (counselingQuestionIndex.present) {
      map['counseling_question_index'] = Variable<int>(
        counselingQuestionIndex.value,
      );
    }
    if (counselingContextJson.present) {
      map['counseling_context_json'] = Variable<String>(
        counselingContextJson.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCalibrationCompanion(')
          ..write('id: $id, ')
          ..write('targetCareer: $targetCareer, ')
          ..write('skillLevel: $skillLevel, ')
          ..write('dailyHours: $dailyHours, ')
          ..write('dreamCompany: $dreamCompany, ')
          ..write('counselingQuestionIndex: $counselingQuestionIndex, ')
          ..write('counselingContextJson: $counselingContextJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RoadmapPathsTable extends RoadmapPaths
    with TableInfo<$RoadmapPathsTable, RoadmapPath> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoadmapPathsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [id, title, description, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roadmap_paths';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoadmapPath> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoadmapPath map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoadmapPath(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RoadmapPathsTable createAlias(String alias) {
    return $RoadmapPathsTable(attachedDatabase, alias);
  }
}

class RoadmapPath extends DataClass implements Insertable<RoadmapPath> {
  final int id;
  final String title;
  final String? description;
  final DateTime createdAt;
  const RoadmapPath({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RoadmapPathsCompanion toCompanion(bool nullToAbsent) {
    return RoadmapPathsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
    );
  }

  factory RoadmapPath.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoadmapPath(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RoadmapPath copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
  }) => RoadmapPath(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
  );
  RoadmapPath copyWithCompanion(RoadmapPathsCompanion data) {
    return RoadmapPath(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoadmapPath(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoadmapPath &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt);
}

class RoadmapPathsCompanion extends UpdateCompanion<RoadmapPath> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  const RoadmapPathsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RoadmapPathsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<RoadmapPath> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RoadmapPathsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? createdAt,
  }) {
    return RoadmapPathsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoadmapPathsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RoadmapStepsTable extends RoadmapSteps
    with TableInfo<$RoadmapStepsTable, RoadmapStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoadmapStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pathIdMeta = const VerificationMeta('pathId');
  @override
  late final GeneratedColumn<int> pathId = GeneratedColumn<int>(
    'path_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES roadmap_paths (id)',
    ),
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aiDeadlineMeta = const VerificationMeta(
    'aiDeadline',
  );
  @override
  late final GeneratedColumn<DateTime> aiDeadline = GeneratedColumn<DateTime>(
    'ai_deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pathId,
    title,
    description,
    aiDeadline,
    orderIndex,
    isCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roadmap_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoadmapStep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('path_id')) {
      context.handle(
        _pathIdMeta,
        pathId.isAcceptableOrUnknown(data['path_id']!, _pathIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pathIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('ai_deadline')) {
      context.handle(
        _aiDeadlineMeta,
        aiDeadline.isAcceptableOrUnknown(data['ai_deadline']!, _aiDeadlineMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoadmapStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoadmapStep(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pathId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}path_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      aiDeadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ai_deadline'],
      ),
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
    );
  }

  @override
  $RoadmapStepsTable createAlias(String alias) {
    return $RoadmapStepsTable(attachedDatabase, alias);
  }
}

class RoadmapStep extends DataClass implements Insertable<RoadmapStep> {
  final int id;
  final int pathId;
  final String title;
  final String? description;
  final DateTime? aiDeadline;
  final int orderIndex;
  final bool isCompleted;
  const RoadmapStep({
    required this.id,
    required this.pathId,
    required this.title,
    this.description,
    this.aiDeadline,
    required this.orderIndex,
    required this.isCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['path_id'] = Variable<int>(pathId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || aiDeadline != null) {
      map['ai_deadline'] = Variable<DateTime>(aiDeadline);
    }
    map['order_index'] = Variable<int>(orderIndex);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  RoadmapStepsCompanion toCompanion(bool nullToAbsent) {
    return RoadmapStepsCompanion(
      id: Value(id),
      pathId: Value(pathId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      aiDeadline: aiDeadline == null && nullToAbsent
          ? const Value.absent()
          : Value(aiDeadline),
      orderIndex: Value(orderIndex),
      isCompleted: Value(isCompleted),
    );
  }

  factory RoadmapStep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoadmapStep(
      id: serializer.fromJson<int>(json['id']),
      pathId: serializer.fromJson<int>(json['pathId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      aiDeadline: serializer.fromJson<DateTime?>(json['aiDeadline']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pathId': serializer.toJson<int>(pathId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'aiDeadline': serializer.toJson<DateTime?>(aiDeadline),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  RoadmapStep copyWith({
    int? id,
    int? pathId,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<DateTime?> aiDeadline = const Value.absent(),
    int? orderIndex,
    bool? isCompleted,
  }) => RoadmapStep(
    id: id ?? this.id,
    pathId: pathId ?? this.pathId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    aiDeadline: aiDeadline.present ? aiDeadline.value : this.aiDeadline,
    orderIndex: orderIndex ?? this.orderIndex,
    isCompleted: isCompleted ?? this.isCompleted,
  );
  RoadmapStep copyWithCompanion(RoadmapStepsCompanion data) {
    return RoadmapStep(
      id: data.id.present ? data.id.value : this.id,
      pathId: data.pathId.present ? data.pathId.value : this.pathId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      aiDeadline: data.aiDeadline.present
          ? data.aiDeadline.value
          : this.aiDeadline,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoadmapStep(')
          ..write('id: $id, ')
          ..write('pathId: $pathId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('aiDeadline: $aiDeadline, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pathId,
    title,
    description,
    aiDeadline,
    orderIndex,
    isCompleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoadmapStep &&
          other.id == this.id &&
          other.pathId == this.pathId &&
          other.title == this.title &&
          other.description == this.description &&
          other.aiDeadline == this.aiDeadline &&
          other.orderIndex == this.orderIndex &&
          other.isCompleted == this.isCompleted);
}

class RoadmapStepsCompanion extends UpdateCompanion<RoadmapStep> {
  final Value<int> id;
  final Value<int> pathId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime?> aiDeadline;
  final Value<int> orderIndex;
  final Value<bool> isCompleted;
  const RoadmapStepsCompanion({
    this.id = const Value.absent(),
    this.pathId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.aiDeadline = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.isCompleted = const Value.absent(),
  });
  RoadmapStepsCompanion.insert({
    this.id = const Value.absent(),
    required int pathId,
    required String title,
    this.description = const Value.absent(),
    this.aiDeadline = const Value.absent(),
    required int orderIndex,
    this.isCompleted = const Value.absent(),
  }) : pathId = Value(pathId),
       title = Value(title),
       orderIndex = Value(orderIndex);
  static Insertable<RoadmapStep> custom({
    Expression<int>? id,
    Expression<int>? pathId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? aiDeadline,
    Expression<int>? orderIndex,
    Expression<bool>? isCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pathId != null) 'path_id': pathId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (aiDeadline != null) 'ai_deadline': aiDeadline,
      if (orderIndex != null) 'order_index': orderIndex,
      if (isCompleted != null) 'is_completed': isCompleted,
    });
  }

  RoadmapStepsCompanion copyWith({
    Value<int>? id,
    Value<int>? pathId,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime?>? aiDeadline,
    Value<int>? orderIndex,
    Value<bool>? isCompleted,
  }) {
    return RoadmapStepsCompanion(
      id: id ?? this.id,
      pathId: pathId ?? this.pathId,
      title: title ?? this.title,
      description: description ?? this.description,
      aiDeadline: aiDeadline ?? this.aiDeadline,
      orderIndex: orderIndex ?? this.orderIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pathId.present) {
      map['path_id'] = Variable<int>(pathId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (aiDeadline.present) {
      map['ai_deadline'] = Variable<DateTime>(aiDeadline.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoadmapStepsCompanion(')
          ..write('id: $id, ')
          ..write('pathId: $pathId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('aiDeadline: $aiDeadline, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }
}

class $OpportunityLogTable extends OpportunityLog
    with TableInfo<$OpportunityLogTable, OpportunityLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpportunityLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minReadinessLevelMeta = const VerificationMeta(
    'minReadinessLevel',
  );
  @override
  late final GeneratedColumn<int> minReadinessLevel = GeneratedColumn<int>(
    'min_readiness_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _foundAtMeta = const VerificationMeta(
    'foundAt',
  );
  @override
  late final GeneratedColumn<DateTime> foundAt = GeneratedColumn<DateTime>(
    'found_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    company,
    type,
    url,
    minReadinessLevel,
    foundAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'opportunity_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<OpportunityLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    } else if (isInserting) {
      context.missing(_companyMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('min_readiness_level')) {
      context.handle(
        _minReadinessLevelMeta,
        minReadinessLevel.isAcceptableOrUnknown(
          data['min_readiness_level']!,
          _minReadinessLevelMeta,
        ),
      );
    }
    if (data.containsKey('found_at')) {
      context.handle(
        _foundAtMeta,
        foundAt.isAcceptableOrUnknown(data['found_at']!, _foundAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OpportunityLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpportunityLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      minReadinessLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_readiness_level'],
      )!,
      foundAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}found_at'],
      )!,
    );
  }

  @override
  $OpportunityLogTable createAlias(String alias) {
    return $OpportunityLogTable(attachedDatabase, alias);
  }
}

class OpportunityLogData extends DataClass
    implements Insertable<OpportunityLogData> {
  final int id;
  final String title;
  final String company;
  final String type;
  final String url;
  final int minReadinessLevel;
  final DateTime foundAt;
  const OpportunityLogData({
    required this.id,
    required this.title,
    required this.company,
    required this.type,
    required this.url,
    required this.minReadinessLevel,
    required this.foundAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['company'] = Variable<String>(company);
    map['type'] = Variable<String>(type);
    map['url'] = Variable<String>(url);
    map['min_readiness_level'] = Variable<int>(minReadinessLevel);
    map['found_at'] = Variable<DateTime>(foundAt);
    return map;
  }

  OpportunityLogCompanion toCompanion(bool nullToAbsent) {
    return OpportunityLogCompanion(
      id: Value(id),
      title: Value(title),
      company: Value(company),
      type: Value(type),
      url: Value(url),
      minReadinessLevel: Value(minReadinessLevel),
      foundAt: Value(foundAt),
    );
  }

  factory OpportunityLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpportunityLogData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      company: serializer.fromJson<String>(json['company']),
      type: serializer.fromJson<String>(json['type']),
      url: serializer.fromJson<String>(json['url']),
      minReadinessLevel: serializer.fromJson<int>(json['minReadinessLevel']),
      foundAt: serializer.fromJson<DateTime>(json['foundAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'company': serializer.toJson<String>(company),
      'type': serializer.toJson<String>(type),
      'url': serializer.toJson<String>(url),
      'minReadinessLevel': serializer.toJson<int>(minReadinessLevel),
      'foundAt': serializer.toJson<DateTime>(foundAt),
    };
  }

  OpportunityLogData copyWith({
    int? id,
    String? title,
    String? company,
    String? type,
    String? url,
    int? minReadinessLevel,
    DateTime? foundAt,
  }) => OpportunityLogData(
    id: id ?? this.id,
    title: title ?? this.title,
    company: company ?? this.company,
    type: type ?? this.type,
    url: url ?? this.url,
    minReadinessLevel: minReadinessLevel ?? this.minReadinessLevel,
    foundAt: foundAt ?? this.foundAt,
  );
  OpportunityLogData copyWithCompanion(OpportunityLogCompanion data) {
    return OpportunityLogData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      company: data.company.present ? data.company.value : this.company,
      type: data.type.present ? data.type.value : this.type,
      url: data.url.present ? data.url.value : this.url,
      minReadinessLevel: data.minReadinessLevel.present
          ? data.minReadinessLevel.value
          : this.minReadinessLevel,
      foundAt: data.foundAt.present ? data.foundAt.value : this.foundAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpportunityLogData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('company: $company, ')
          ..write('type: $type, ')
          ..write('url: $url, ')
          ..write('minReadinessLevel: $minReadinessLevel, ')
          ..write('foundAt: $foundAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, company, type, url, minReadinessLevel, foundAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpportunityLogData &&
          other.id == this.id &&
          other.title == this.title &&
          other.company == this.company &&
          other.type == this.type &&
          other.url == this.url &&
          other.minReadinessLevel == this.minReadinessLevel &&
          other.foundAt == this.foundAt);
}

class OpportunityLogCompanion extends UpdateCompanion<OpportunityLogData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> company;
  final Value<String> type;
  final Value<String> url;
  final Value<int> minReadinessLevel;
  final Value<DateTime> foundAt;
  const OpportunityLogCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.company = const Value.absent(),
    this.type = const Value.absent(),
    this.url = const Value.absent(),
    this.minReadinessLevel = const Value.absent(),
    this.foundAt = const Value.absent(),
  });
  OpportunityLogCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String company,
    required String type,
    required String url,
    this.minReadinessLevel = const Value.absent(),
    this.foundAt = const Value.absent(),
  }) : title = Value(title),
       company = Value(company),
       type = Value(type),
       url = Value(url);
  static Insertable<OpportunityLogData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? company,
    Expression<String>? type,
    Expression<String>? url,
    Expression<int>? minReadinessLevel,
    Expression<DateTime>? foundAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (company != null) 'company': company,
      if (type != null) 'type': type,
      if (url != null) 'url': url,
      if (minReadinessLevel != null) 'min_readiness_level': minReadinessLevel,
      if (foundAt != null) 'found_at': foundAt,
    });
  }

  OpportunityLogCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? company,
    Value<String>? type,
    Value<String>? url,
    Value<int>? minReadinessLevel,
    Value<DateTime>? foundAt,
  }) {
    return OpportunityLogCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      type: type ?? this.type,
      url: url ?? this.url,
      minReadinessLevel: minReadinessLevel ?? this.minReadinessLevel,
      foundAt: foundAt ?? this.foundAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (minReadinessLevel.present) {
      map['min_readiness_level'] = Variable<int>(minReadinessLevel.value);
    }
    if (foundAt.present) {
      map['found_at'] = Variable<DateTime>(foundAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpportunityLogCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('company: $company, ')
          ..write('type: $type, ')
          ..write('url: $url, ')
          ..write('minReadinessLevel: $minReadinessLevel, ')
          ..write('foundAt: $foundAt')
          ..write(')'))
        .toString();
  }
}

class $ReadinessScoresTable extends ReadinessScores
    with TableInfo<$ReadinessScoresTable, ReadinessScore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadinessScoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _skillNameMeta = const VerificationMeta(
    'skillName',
  );
  @override
  late final GeneratedColumn<String> skillName = GeneratedColumn<String>(
    'skill_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, skillName, score, lastUpdated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'readiness_scores';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadinessScore> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('skill_name')) {
      context.handle(
        _skillNameMeta,
        skillName.isAcceptableOrUnknown(data['skill_name']!, _skillNameMeta),
      );
    } else if (isInserting) {
      context.missing(_skillNameMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadinessScore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadinessScore(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      skillName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill_name'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $ReadinessScoresTable createAlias(String alias) {
    return $ReadinessScoresTable(attachedDatabase, alias);
  }
}

class ReadinessScore extends DataClass implements Insertable<ReadinessScore> {
  final int id;
  final String skillName;
  final int score;
  final DateTime lastUpdated;
  const ReadinessScore({
    required this.id,
    required this.skillName,
    required this.score,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['skill_name'] = Variable<String>(skillName);
    map['score'] = Variable<int>(score);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  ReadinessScoresCompanion toCompanion(bool nullToAbsent) {
    return ReadinessScoresCompanion(
      id: Value(id),
      skillName: Value(skillName),
      score: Value(score),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory ReadinessScore.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadinessScore(
      id: serializer.fromJson<int>(json['id']),
      skillName: serializer.fromJson<String>(json['skillName']),
      score: serializer.fromJson<int>(json['score']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'skillName': serializer.toJson<String>(skillName),
      'score': serializer.toJson<int>(score),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  ReadinessScore copyWith({
    int? id,
    String? skillName,
    int? score,
    DateTime? lastUpdated,
  }) => ReadinessScore(
    id: id ?? this.id,
    skillName: skillName ?? this.skillName,
    score: score ?? this.score,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  ReadinessScore copyWithCompanion(ReadinessScoresCompanion data) {
    return ReadinessScore(
      id: data.id.present ? data.id.value : this.id,
      skillName: data.skillName.present ? data.skillName.value : this.skillName,
      score: data.score.present ? data.score.value : this.score,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadinessScore(')
          ..write('id: $id, ')
          ..write('skillName: $skillName, ')
          ..write('score: $score, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, skillName, score, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadinessScore &&
          other.id == this.id &&
          other.skillName == this.skillName &&
          other.score == this.score &&
          other.lastUpdated == this.lastUpdated);
}

class ReadinessScoresCompanion extends UpdateCompanion<ReadinessScore> {
  final Value<int> id;
  final Value<String> skillName;
  final Value<int> score;
  final Value<DateTime> lastUpdated;
  const ReadinessScoresCompanion({
    this.id = const Value.absent(),
    this.skillName = const Value.absent(),
    this.score = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  ReadinessScoresCompanion.insert({
    this.id = const Value.absent(),
    required String skillName,
    this.score = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  }) : skillName = Value(skillName);
  static Insertable<ReadinessScore> custom({
    Expression<int>? id,
    Expression<String>? skillName,
    Expression<int>? score,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (skillName != null) 'skill_name': skillName,
      if (score != null) 'score': score,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  ReadinessScoresCompanion copyWith({
    Value<int>? id,
    Value<String>? skillName,
    Value<int>? score,
    Value<DateTime>? lastUpdated,
  }) {
    return ReadinessScoresCompanion(
      id: id ?? this.id,
      skillName: skillName ?? this.skillName,
      score: score ?? this.score,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (skillName.present) {
      map['skill_name'] = Variable<String>(skillName.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadinessScoresCompanion(')
          ..write('id: $id, ')
          ..write('skillName: $skillName, ')
          ..write('score: $score, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

class $CareerGoalsTable extends CareerGoals
    with TableInfo<$CareerGoalsTable, CareerGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CareerGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, isCompleted, deadline];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'career_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<CareerGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CareerGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CareerGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
    );
  }

  @override
  $CareerGoalsTable createAlias(String alias) {
    return $CareerGoalsTable(attachedDatabase, alias);
  }
}

class CareerGoal extends DataClass implements Insertable<CareerGoal> {
  final int id;
  final String title;
  final bool isCompleted;
  final DateTime? deadline;
  const CareerGoal({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.deadline,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    return map;
  }

  CareerGoalsCompanion toCompanion(bool nullToAbsent) {
    return CareerGoalsCompanion(
      id: Value(id),
      title: Value(title),
      isCompleted: Value(isCompleted),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
    );
  }

  factory CareerGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CareerGoal(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'deadline': serializer.toJson<DateTime?>(deadline),
    };
  }

  CareerGoal copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    Value<DateTime?> deadline = const Value.absent(),
  }) => CareerGoal(
    id: id ?? this.id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    deadline: deadline.present ? deadline.value : this.deadline,
  );
  CareerGoal copyWithCompanion(CareerGoalsCompanion data) {
    return CareerGoal(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CareerGoal(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('deadline: $deadline')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, isCompleted, deadline);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CareerGoal &&
          other.id == this.id &&
          other.title == this.title &&
          other.isCompleted == this.isCompleted &&
          other.deadline == this.deadline);
}

class CareerGoalsCompanion extends UpdateCompanion<CareerGoal> {
  final Value<int> id;
  final Value<String> title;
  final Value<bool> isCompleted;
  final Value<DateTime?> deadline;
  const CareerGoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.deadline = const Value.absent(),
  });
  CareerGoalsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.isCompleted = const Value.absent(),
    this.deadline = const Value.absent(),
  }) : title = Value(title);
  static Insertable<CareerGoal> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<bool>? isCompleted,
    Expression<DateTime>? deadline,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (deadline != null) 'deadline': deadline,
    });
  }

  CareerGoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<bool>? isCompleted,
    Value<DateTime?>? deadline,
  }) {
    return CareerGoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      deadline: deadline ?? this.deadline,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CareerGoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('deadline: $deadline')
          ..write(')'))
        .toString();
  }
}

class $DailyAttendanceTable extends DailyAttendance
    with TableInfo<$DailyAttendanceTable, DailyAttendanceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyAttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wasManualMeta = const VerificationMeta(
    'wasManual',
  );
  @override
  late final GeneratedColumn<bool> wasManual = GeneratedColumn<bool>(
    'was_manual',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_manual" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [date, status, wasManual];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyAttendanceData> instance, {
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
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('was_manual')) {
      context.handle(
        _wasManualMeta,
        wasManual.isAcceptableOrUnknown(data['was_manual']!, _wasManualMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailyAttendanceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyAttendanceData(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      wasManual: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_manual'],
      )!,
    );
  }

  @override
  $DailyAttendanceTable createAlias(String alias) {
    return $DailyAttendanceTable(attachedDatabase, alias);
  }
}

class DailyAttendanceData extends DataClass
    implements Insertable<DailyAttendanceData> {
  final DateTime date;
  final String status;
  final bool wasManual;
  const DailyAttendanceData({
    required this.date,
    required this.status,
    required this.wasManual,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    map['status'] = Variable<String>(status);
    map['was_manual'] = Variable<bool>(wasManual);
    return map;
  }

  DailyAttendanceCompanion toCompanion(bool nullToAbsent) {
    return DailyAttendanceCompanion(
      date: Value(date),
      status: Value(status),
      wasManual: Value(wasManual),
    );
  }

  factory DailyAttendanceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyAttendanceData(
      date: serializer.fromJson<DateTime>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      wasManual: serializer.fromJson<bool>(json['wasManual']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'status': serializer.toJson<String>(status),
      'wasManual': serializer.toJson<bool>(wasManual),
    };
  }

  DailyAttendanceData copyWith({
    DateTime? date,
    String? status,
    bool? wasManual,
  }) => DailyAttendanceData(
    date: date ?? this.date,
    status: status ?? this.status,
    wasManual: wasManual ?? this.wasManual,
  );
  DailyAttendanceData copyWithCompanion(DailyAttendanceCompanion data) {
    return DailyAttendanceData(
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      wasManual: data.wasManual.present ? data.wasManual.value : this.wasManual,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyAttendanceData(')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('wasManual: $wasManual')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, status, wasManual);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyAttendanceData &&
          other.date == this.date &&
          other.status == this.status &&
          other.wasManual == this.wasManual);
}

class DailyAttendanceCompanion extends UpdateCompanion<DailyAttendanceData> {
  final Value<DateTime> date;
  final Value<String> status;
  final Value<bool> wasManual;
  final Value<int> rowid;
  const DailyAttendanceCompanion({
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.wasManual = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyAttendanceCompanion.insert({
    required DateTime date,
    required String status,
    this.wasManual = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       status = Value(status);
  static Insertable<DailyAttendanceData> custom({
    Expression<DateTime>? date,
    Expression<String>? status,
    Expression<bool>? wasManual,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (wasManual != null) 'was_manual': wasManual,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyAttendanceCompanion copyWith({
    Value<DateTime>? date,
    Value<String>? status,
    Value<bool>? wasManual,
    Value<int>? rowid,
  }) {
    return DailyAttendanceCompanion(
      date: date ?? this.date,
      status: status ?? this.status,
      wasManual: wasManual ?? this.wasManual,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (wasManual.present) {
      map['was_manual'] = Variable<bool>(wasManual.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyAttendanceCompanion(')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('wasManual: $wasManual, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyTasksTable extends DailyTasks
    with TableInfo<$DailyTasksTable, DailyTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [id, date, title, isCompleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
    );
  }

  @override
  $DailyTasksTable createAlias(String alias) {
    return $DailyTasksTable(attachedDatabase, alias);
  }
}

class DailyTask extends DataClass implements Insertable<DailyTask> {
  final int id;
  final DateTime date;
  final String title;
  final bool isCompleted;
  const DailyTask({
    required this.id,
    required this.date,
    required this.title,
    required this.isCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['title'] = Variable<String>(title);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  DailyTasksCompanion toCompanion(bool nullToAbsent) {
    return DailyTasksCompanion(
      id: Value(id),
      date: Value(date),
      title: Value(title),
      isCompleted: Value(isCompleted),
    );
  }

  factory DailyTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyTask(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      title: serializer.fromJson<String>(json['title']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'title': serializer.toJson<String>(title),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  DailyTask copyWith({
    int? id,
    DateTime? date,
    String? title,
    bool? isCompleted,
  }) => DailyTask(
    id: id ?? this.id,
    date: date ?? this.date,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
  );
  DailyTask copyWithCompanion(DailyTasksCompanion data) {
    return DailyTask(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      title: data.title.present ? data.title.value : this.title,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyTask(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, title, isCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyTask &&
          other.id == this.id &&
          other.date == this.date &&
          other.title == this.title &&
          other.isCompleted == this.isCompleted);
}

class DailyTasksCompanion extends UpdateCompanion<DailyTask> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> title;
  final Value<bool> isCompleted;
  const DailyTasksCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
  });
  DailyTasksCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String title,
    this.isCompleted = const Value.absent(),
  }) : date = Value(date),
       title = Value(title);
  static Insertable<DailyTask> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? title,
    Expression<bool>? isCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
    });
  }

  DailyTasksCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? title,
    Value<bool>? isCompleted,
  }) {
    return DailyTasksCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyTasksCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }
}

class $VideoLearningLogsTable extends VideoLearningLogs
    with TableInfo<$VideoLearningLogsTable, VideoLearningLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoLearningLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _videoTitleMeta = const VerificationMeta(
    'videoTitle',
  );
  @override
  late final GeneratedColumn<String> videoTitle = GeneratedColumn<String>(
    'video_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalDurationSecondsMeta =
      const VerificationMeta('totalDurationSeconds');
  @override
  late final GeneratedColumn<int> totalDurationSeconds = GeneratedColumn<int>(
    'total_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _watchedSecondsMeta = const VerificationMeta(
    'watchedSeconds',
  );
  @override
  late final GeneratedColumn<int> watchedSeconds = GeneratedColumn<int>(
    'watched_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skipCountMeta = const VerificationMeta(
    'skipCount',
  );
  @override
  late final GeneratedColumn<int> skipCount = GeneratedColumn<int>(
    'skip_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sincerityScoreMeta = const VerificationMeta(
    'sincerityScore',
  );
  @override
  late final GeneratedColumn<double> sincerityScore = GeneratedColumn<double>(
    'sincerity_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(100.0),
  );
  static const VerificationMeta _watchedAtMeta = const VerificationMeta(
    'watchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> watchedAt = GeneratedColumn<DateTime>(
    'watched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    videoTitle,
    totalDurationSeconds,
    watchedSeconds,
    skipCount,
    sincerityScore,
    watchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_learning_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<VideoLearningLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('video_title')) {
      context.handle(
        _videoTitleMeta,
        videoTitle.isAcceptableOrUnknown(data['video_title']!, _videoTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_videoTitleMeta);
    }
    if (data.containsKey('total_duration_seconds')) {
      context.handle(
        _totalDurationSecondsMeta,
        totalDurationSeconds.isAcceptableOrUnknown(
          data['total_duration_seconds']!,
          _totalDurationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalDurationSecondsMeta);
    }
    if (data.containsKey('watched_seconds')) {
      context.handle(
        _watchedSecondsMeta,
        watchedSeconds.isAcceptableOrUnknown(
          data['watched_seconds']!,
          _watchedSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_watchedSecondsMeta);
    }
    if (data.containsKey('skip_count')) {
      context.handle(
        _skipCountMeta,
        skipCount.isAcceptableOrUnknown(data['skip_count']!, _skipCountMeta),
      );
    }
    if (data.containsKey('sincerity_score')) {
      context.handle(
        _sincerityScoreMeta,
        sincerityScore.isAcceptableOrUnknown(
          data['sincerity_score']!,
          _sincerityScoreMeta,
        ),
      );
    }
    if (data.containsKey('watched_at')) {
      context.handle(
        _watchedAtMeta,
        watchedAt.isAcceptableOrUnknown(data['watched_at']!, _watchedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VideoLearningLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoLearningLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      videoTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_title'],
      )!,
      totalDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration_seconds'],
      )!,
      watchedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}watched_seconds'],
      )!,
      skipCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skip_count'],
      )!,
      sincerityScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sincerity_score'],
      )!,
      watchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}watched_at'],
      )!,
    );
  }

  @override
  $VideoLearningLogsTable createAlias(String alias) {
    return $VideoLearningLogsTable(attachedDatabase, alias);
  }
}

class VideoLearningLog extends DataClass
    implements Insertable<VideoLearningLog> {
  final int id;
  final String videoTitle;
  final int totalDurationSeconds;
  final int watchedSeconds;
  final int skipCount;
  final double sincerityScore;
  final DateTime watchedAt;
  const VideoLearningLog({
    required this.id,
    required this.videoTitle,
    required this.totalDurationSeconds,
    required this.watchedSeconds,
    required this.skipCount,
    required this.sincerityScore,
    required this.watchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['video_title'] = Variable<String>(videoTitle);
    map['total_duration_seconds'] = Variable<int>(totalDurationSeconds);
    map['watched_seconds'] = Variable<int>(watchedSeconds);
    map['skip_count'] = Variable<int>(skipCount);
    map['sincerity_score'] = Variable<double>(sincerityScore);
    map['watched_at'] = Variable<DateTime>(watchedAt);
    return map;
  }

  VideoLearningLogsCompanion toCompanion(bool nullToAbsent) {
    return VideoLearningLogsCompanion(
      id: Value(id),
      videoTitle: Value(videoTitle),
      totalDurationSeconds: Value(totalDurationSeconds),
      watchedSeconds: Value(watchedSeconds),
      skipCount: Value(skipCount),
      sincerityScore: Value(sincerityScore),
      watchedAt: Value(watchedAt),
    );
  }

  factory VideoLearningLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoLearningLog(
      id: serializer.fromJson<int>(json['id']),
      videoTitle: serializer.fromJson<String>(json['videoTitle']),
      totalDurationSeconds: serializer.fromJson<int>(
        json['totalDurationSeconds'],
      ),
      watchedSeconds: serializer.fromJson<int>(json['watchedSeconds']),
      skipCount: serializer.fromJson<int>(json['skipCount']),
      sincerityScore: serializer.fromJson<double>(json['sincerityScore']),
      watchedAt: serializer.fromJson<DateTime>(json['watchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'videoTitle': serializer.toJson<String>(videoTitle),
      'totalDurationSeconds': serializer.toJson<int>(totalDurationSeconds),
      'watchedSeconds': serializer.toJson<int>(watchedSeconds),
      'skipCount': serializer.toJson<int>(skipCount),
      'sincerityScore': serializer.toJson<double>(sincerityScore),
      'watchedAt': serializer.toJson<DateTime>(watchedAt),
    };
  }

  VideoLearningLog copyWith({
    int? id,
    String? videoTitle,
    int? totalDurationSeconds,
    int? watchedSeconds,
    int? skipCount,
    double? sincerityScore,
    DateTime? watchedAt,
  }) => VideoLearningLog(
    id: id ?? this.id,
    videoTitle: videoTitle ?? this.videoTitle,
    totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
    watchedSeconds: watchedSeconds ?? this.watchedSeconds,
    skipCount: skipCount ?? this.skipCount,
    sincerityScore: sincerityScore ?? this.sincerityScore,
    watchedAt: watchedAt ?? this.watchedAt,
  );
  VideoLearningLog copyWithCompanion(VideoLearningLogsCompanion data) {
    return VideoLearningLog(
      id: data.id.present ? data.id.value : this.id,
      videoTitle: data.videoTitle.present
          ? data.videoTitle.value
          : this.videoTitle,
      totalDurationSeconds: data.totalDurationSeconds.present
          ? data.totalDurationSeconds.value
          : this.totalDurationSeconds,
      watchedSeconds: data.watchedSeconds.present
          ? data.watchedSeconds.value
          : this.watchedSeconds,
      skipCount: data.skipCount.present ? data.skipCount.value : this.skipCount,
      sincerityScore: data.sincerityScore.present
          ? data.sincerityScore.value
          : this.sincerityScore,
      watchedAt: data.watchedAt.present ? data.watchedAt.value : this.watchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoLearningLog(')
          ..write('id: $id, ')
          ..write('videoTitle: $videoTitle, ')
          ..write('totalDurationSeconds: $totalDurationSeconds, ')
          ..write('watchedSeconds: $watchedSeconds, ')
          ..write('skipCount: $skipCount, ')
          ..write('sincerityScore: $sincerityScore, ')
          ..write('watchedAt: $watchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    videoTitle,
    totalDurationSeconds,
    watchedSeconds,
    skipCount,
    sincerityScore,
    watchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoLearningLog &&
          other.id == this.id &&
          other.videoTitle == this.videoTitle &&
          other.totalDurationSeconds == this.totalDurationSeconds &&
          other.watchedSeconds == this.watchedSeconds &&
          other.skipCount == this.skipCount &&
          other.sincerityScore == this.sincerityScore &&
          other.watchedAt == this.watchedAt);
}

class VideoLearningLogsCompanion extends UpdateCompanion<VideoLearningLog> {
  final Value<int> id;
  final Value<String> videoTitle;
  final Value<int> totalDurationSeconds;
  final Value<int> watchedSeconds;
  final Value<int> skipCount;
  final Value<double> sincerityScore;
  final Value<DateTime> watchedAt;
  const VideoLearningLogsCompanion({
    this.id = const Value.absent(),
    this.videoTitle = const Value.absent(),
    this.totalDurationSeconds = const Value.absent(),
    this.watchedSeconds = const Value.absent(),
    this.skipCount = const Value.absent(),
    this.sincerityScore = const Value.absent(),
    this.watchedAt = const Value.absent(),
  });
  VideoLearningLogsCompanion.insert({
    this.id = const Value.absent(),
    required String videoTitle,
    required int totalDurationSeconds,
    required int watchedSeconds,
    this.skipCount = const Value.absent(),
    this.sincerityScore = const Value.absent(),
    this.watchedAt = const Value.absent(),
  }) : videoTitle = Value(videoTitle),
       totalDurationSeconds = Value(totalDurationSeconds),
       watchedSeconds = Value(watchedSeconds);
  static Insertable<VideoLearningLog> custom({
    Expression<int>? id,
    Expression<String>? videoTitle,
    Expression<int>? totalDurationSeconds,
    Expression<int>? watchedSeconds,
    Expression<int>? skipCount,
    Expression<double>? sincerityScore,
    Expression<DateTime>? watchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (videoTitle != null) 'video_title': videoTitle,
      if (totalDurationSeconds != null)
        'total_duration_seconds': totalDurationSeconds,
      if (watchedSeconds != null) 'watched_seconds': watchedSeconds,
      if (skipCount != null) 'skip_count': skipCount,
      if (sincerityScore != null) 'sincerity_score': sincerityScore,
      if (watchedAt != null) 'watched_at': watchedAt,
    });
  }

  VideoLearningLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? videoTitle,
    Value<int>? totalDurationSeconds,
    Value<int>? watchedSeconds,
    Value<int>? skipCount,
    Value<double>? sincerityScore,
    Value<DateTime>? watchedAt,
  }) {
    return VideoLearningLogsCompanion(
      id: id ?? this.id,
      videoTitle: videoTitle ?? this.videoTitle,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      watchedSeconds: watchedSeconds ?? this.watchedSeconds,
      skipCount: skipCount ?? this.skipCount,
      sincerityScore: sincerityScore ?? this.sincerityScore,
      watchedAt: watchedAt ?? this.watchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (videoTitle.present) {
      map['video_title'] = Variable<String>(videoTitle.value);
    }
    if (totalDurationSeconds.present) {
      map['total_duration_seconds'] = Variable<int>(totalDurationSeconds.value);
    }
    if (watchedSeconds.present) {
      map['watched_seconds'] = Variable<int>(watchedSeconds.value);
    }
    if (skipCount.present) {
      map['skip_count'] = Variable<int>(skipCount.value);
    }
    if (sincerityScore.present) {
      map['sincerity_score'] = Variable<double>(sincerityScore.value);
    }
    if (watchedAt.present) {
      map['watched_at'] = Variable<DateTime>(watchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoLearningLogsCompanion(')
          ..write('id: $id, ')
          ..write('videoTitle: $videoTitle, ')
          ..write('totalDurationSeconds: $totalDurationSeconds, ')
          ..write('watchedSeconds: $watchedSeconds, ')
          ..write('skipCount: $skipCount, ')
          ..write('sincerityScore: $sincerityScore, ')
          ..write('watchedAt: $watchedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $UserCalibrationTable userCalibration = $UserCalibrationTable(
    this,
  );
  late final $RoadmapPathsTable roadmapPaths = $RoadmapPathsTable(this);
  late final $RoadmapStepsTable roadmapSteps = $RoadmapStepsTable(this);
  late final $OpportunityLogTable opportunityLog = $OpportunityLogTable(this);
  late final $ReadinessScoresTable readinessScores = $ReadinessScoresTable(
    this,
  );
  late final $CareerGoalsTable careerGoals = $CareerGoalsTable(this);
  late final $DailyAttendanceTable dailyAttendance = $DailyAttendanceTable(
    this,
  );
  late final $DailyTasksTable dailyTasks = $DailyTasksTable(this);
  late final $VideoLearningLogsTable videoLearningLogs =
      $VideoLearningLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    chatMessages,
    userCalibration,
    roadmapPaths,
    roadmapSteps,
    opportunityLog,
    readinessScores,
    careerGoals,
    dailyAttendance,
    dailyTasks,
    videoLearningLogs,
  ];
}

typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      required String content,
      Value<bool> isAi,
      Value<DateTime> createdAt,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      Value<String> content,
      Value<bool> isAi,
      Value<DateTime> createdAt,
    });

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAi => $composableBuilder(
    column: $table.isAi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAi => $composableBuilder(
    column: $table.isAi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isAi =>
      $composableBuilder(column: $table.isAi, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (
            ChatMessage,
            BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
          ),
          ChatMessage,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<bool> isAi = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                content: content,
                isAi: isAi,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String content,
                Value<bool> isAi = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                content: content,
                isAi: isAi,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (
        ChatMessage,
        BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
      ),
      ChatMessage,
      PrefetchHooks Function()
    >;
typedef $$UserCalibrationTableCreateCompanionBuilder =
    UserCalibrationCompanion Function({
      Value<int> id,
      required String targetCareer,
      Value<int> skillLevel,
      Value<int> dailyHours,
      Value<String?> dreamCompany,
      Value<int> counselingQuestionIndex,
      Value<String?> counselingContextJson,
      Value<DateTime> updatedAt,
    });
typedef $$UserCalibrationTableUpdateCompanionBuilder =
    UserCalibrationCompanion Function({
      Value<int> id,
      Value<String> targetCareer,
      Value<int> skillLevel,
      Value<int> dailyHours,
      Value<String?> dreamCompany,
      Value<int> counselingQuestionIndex,
      Value<String?> counselingContextJson,
      Value<DateTime> updatedAt,
    });

class $$UserCalibrationTableFilterComposer
    extends Composer<_$AppDatabase, $UserCalibrationTable> {
  $$UserCalibrationTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetCareer => $composableBuilder(
    column: $table.targetCareer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skillLevel => $composableBuilder(
    column: $table.skillLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyHours => $composableBuilder(
    column: $table.dailyHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dreamCompany => $composableBuilder(
    column: $table.dreamCompany,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get counselingQuestionIndex => $composableBuilder(
    column: $table.counselingQuestionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counselingContextJson => $composableBuilder(
    column: $table.counselingContextJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserCalibrationTableOrderingComposer
    extends Composer<_$AppDatabase, $UserCalibrationTable> {
  $$UserCalibrationTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetCareer => $composableBuilder(
    column: $table.targetCareer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skillLevel => $composableBuilder(
    column: $table.skillLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyHours => $composableBuilder(
    column: $table.dailyHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dreamCompany => $composableBuilder(
    column: $table.dreamCompany,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get counselingQuestionIndex => $composableBuilder(
    column: $table.counselingQuestionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counselingContextJson => $composableBuilder(
    column: $table.counselingContextJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserCalibrationTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserCalibrationTable> {
  $$UserCalibrationTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetCareer => $composableBuilder(
    column: $table.targetCareer,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skillLevel => $composableBuilder(
    column: $table.skillLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyHours => $composableBuilder(
    column: $table.dailyHours,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dreamCompany => $composableBuilder(
    column: $table.dreamCompany,
    builder: (column) => column,
  );

  GeneratedColumn<int> get counselingQuestionIndex => $composableBuilder(
    column: $table.counselingQuestionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get counselingContextJson => $composableBuilder(
    column: $table.counselingContextJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserCalibrationTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserCalibrationTable,
          UserCalibrationData,
          $$UserCalibrationTableFilterComposer,
          $$UserCalibrationTableOrderingComposer,
          $$UserCalibrationTableAnnotationComposer,
          $$UserCalibrationTableCreateCompanionBuilder,
          $$UserCalibrationTableUpdateCompanionBuilder,
          (
            UserCalibrationData,
            BaseReferences<
              _$AppDatabase,
              $UserCalibrationTable,
              UserCalibrationData
            >,
          ),
          UserCalibrationData,
          PrefetchHooks Function()
        > {
  $$UserCalibrationTableTableManager(
    _$AppDatabase db,
    $UserCalibrationTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCalibrationTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCalibrationTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCalibrationTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> targetCareer = const Value.absent(),
                Value<int> skillLevel = const Value.absent(),
                Value<int> dailyHours = const Value.absent(),
                Value<String?> dreamCompany = const Value.absent(),
                Value<int> counselingQuestionIndex = const Value.absent(),
                Value<String?> counselingContextJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserCalibrationCompanion(
                id: id,
                targetCareer: targetCareer,
                skillLevel: skillLevel,
                dailyHours: dailyHours,
                dreamCompany: dreamCompany,
                counselingQuestionIndex: counselingQuestionIndex,
                counselingContextJson: counselingContextJson,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String targetCareer,
                Value<int> skillLevel = const Value.absent(),
                Value<int> dailyHours = const Value.absent(),
                Value<String?> dreamCompany = const Value.absent(),
                Value<int> counselingQuestionIndex = const Value.absent(),
                Value<String?> counselingContextJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserCalibrationCompanion.insert(
                id: id,
                targetCareer: targetCareer,
                skillLevel: skillLevel,
                dailyHours: dailyHours,
                dreamCompany: dreamCompany,
                counselingQuestionIndex: counselingQuestionIndex,
                counselingContextJson: counselingContextJson,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserCalibrationTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserCalibrationTable,
      UserCalibrationData,
      $$UserCalibrationTableFilterComposer,
      $$UserCalibrationTableOrderingComposer,
      $$UserCalibrationTableAnnotationComposer,
      $$UserCalibrationTableCreateCompanionBuilder,
      $$UserCalibrationTableUpdateCompanionBuilder,
      (
        UserCalibrationData,
        BaseReferences<
          _$AppDatabase,
          $UserCalibrationTable,
          UserCalibrationData
        >,
      ),
      UserCalibrationData,
      PrefetchHooks Function()
    >;
typedef $$RoadmapPathsTableCreateCompanionBuilder =
    RoadmapPathsCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> description,
      Value<DateTime> createdAt,
    });
typedef $$RoadmapPathsTableUpdateCompanionBuilder =
    RoadmapPathsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> createdAt,
    });

final class $$RoadmapPathsTableReferences
    extends BaseReferences<_$AppDatabase, $RoadmapPathsTable, RoadmapPath> {
  $$RoadmapPathsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoadmapStepsTable, List<RoadmapStep>>
  _roadmapStepsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.roadmapSteps,
    aliasName: $_aliasNameGenerator(db.roadmapPaths.id, db.roadmapSteps.pathId),
  );

  $$RoadmapStepsTableProcessedTableManager get roadmapStepsRefs {
    final manager = $$RoadmapStepsTableTableManager(
      $_db,
      $_db.roadmapSteps,
    ).filter((f) => f.pathId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_roadmapStepsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoadmapPathsTableFilterComposer
    extends Composer<_$AppDatabase, $RoadmapPathsTable> {
  $$RoadmapPathsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> roadmapStepsRefs(
    Expression<bool> Function($$RoadmapStepsTableFilterComposer f) f,
  ) {
    final $$RoadmapStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.roadmapSteps,
      getReferencedColumn: (t) => t.pathId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoadmapStepsTableFilterComposer(
            $db: $db,
            $table: $db.roadmapSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoadmapPathsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoadmapPathsTable> {
  $$RoadmapPathsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoadmapPathsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoadmapPathsTable> {
  $$RoadmapPathsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> roadmapStepsRefs<T extends Object>(
    Expression<T> Function($$RoadmapStepsTableAnnotationComposer a) f,
  ) {
    final $$RoadmapStepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.roadmapSteps,
      getReferencedColumn: (t) => t.pathId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoadmapStepsTableAnnotationComposer(
            $db: $db,
            $table: $db.roadmapSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoadmapPathsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoadmapPathsTable,
          RoadmapPath,
          $$RoadmapPathsTableFilterComposer,
          $$RoadmapPathsTableOrderingComposer,
          $$RoadmapPathsTableAnnotationComposer,
          $$RoadmapPathsTableCreateCompanionBuilder,
          $$RoadmapPathsTableUpdateCompanionBuilder,
          (RoadmapPath, $$RoadmapPathsTableReferences),
          RoadmapPath,
          PrefetchHooks Function({bool roadmapStepsRefs})
        > {
  $$RoadmapPathsTableTableManager(_$AppDatabase db, $RoadmapPathsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoadmapPathsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoadmapPathsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoadmapPathsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RoadmapPathsCompanion(
                id: id,
                title: title,
                description: description,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RoadmapPathsCompanion.insert(
                id: id,
                title: title,
                description: description,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoadmapPathsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({roadmapStepsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (roadmapStepsRefs) db.roadmapSteps],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (roadmapStepsRefs)
                    await $_getPrefetchedData<
                      RoadmapPath,
                      $RoadmapPathsTable,
                      RoadmapStep
                    >(
                      currentTable: table,
                      referencedTable: $$RoadmapPathsTableReferences
                          ._roadmapStepsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoadmapPathsTableReferences(
                            db,
                            table,
                            p0,
                          ).roadmapStepsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.pathId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoadmapPathsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoadmapPathsTable,
      RoadmapPath,
      $$RoadmapPathsTableFilterComposer,
      $$RoadmapPathsTableOrderingComposer,
      $$RoadmapPathsTableAnnotationComposer,
      $$RoadmapPathsTableCreateCompanionBuilder,
      $$RoadmapPathsTableUpdateCompanionBuilder,
      (RoadmapPath, $$RoadmapPathsTableReferences),
      RoadmapPath,
      PrefetchHooks Function({bool roadmapStepsRefs})
    >;
typedef $$RoadmapStepsTableCreateCompanionBuilder =
    RoadmapStepsCompanion Function({
      Value<int> id,
      required int pathId,
      required String title,
      Value<String?> description,
      Value<DateTime?> aiDeadline,
      required int orderIndex,
      Value<bool> isCompleted,
    });
typedef $$RoadmapStepsTableUpdateCompanionBuilder =
    RoadmapStepsCompanion Function({
      Value<int> id,
      Value<int> pathId,
      Value<String> title,
      Value<String?> description,
      Value<DateTime?> aiDeadline,
      Value<int> orderIndex,
      Value<bool> isCompleted,
    });

final class $$RoadmapStepsTableReferences
    extends BaseReferences<_$AppDatabase, $RoadmapStepsTable, RoadmapStep> {
  $$RoadmapStepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoadmapPathsTable _pathIdTable(_$AppDatabase db) =>
      db.roadmapPaths.createAlias(
        $_aliasNameGenerator(db.roadmapSteps.pathId, db.roadmapPaths.id),
      );

  $$RoadmapPathsTableProcessedTableManager get pathId {
    final $_column = $_itemColumn<int>('path_id')!;

    final manager = $$RoadmapPathsTableTableManager(
      $_db,
      $_db.roadmapPaths,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pathIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoadmapStepsTableFilterComposer
    extends Composer<_$AppDatabase, $RoadmapStepsTable> {
  $$RoadmapStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get aiDeadline => $composableBuilder(
    column: $table.aiDeadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  $$RoadmapPathsTableFilterComposer get pathId {
    final $$RoadmapPathsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pathId,
      referencedTable: $db.roadmapPaths,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoadmapPathsTableFilterComposer(
            $db: $db,
            $table: $db.roadmapPaths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoadmapStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoadmapStepsTable> {
  $$RoadmapStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get aiDeadline => $composableBuilder(
    column: $table.aiDeadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoadmapPathsTableOrderingComposer get pathId {
    final $$RoadmapPathsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pathId,
      referencedTable: $db.roadmapPaths,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoadmapPathsTableOrderingComposer(
            $db: $db,
            $table: $db.roadmapPaths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoadmapStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoadmapStepsTable> {
  $$RoadmapStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get aiDeadline => $composableBuilder(
    column: $table.aiDeadline,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  $$RoadmapPathsTableAnnotationComposer get pathId {
    final $$RoadmapPathsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pathId,
      referencedTable: $db.roadmapPaths,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoadmapPathsTableAnnotationComposer(
            $db: $db,
            $table: $db.roadmapPaths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoadmapStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoadmapStepsTable,
          RoadmapStep,
          $$RoadmapStepsTableFilterComposer,
          $$RoadmapStepsTableOrderingComposer,
          $$RoadmapStepsTableAnnotationComposer,
          $$RoadmapStepsTableCreateCompanionBuilder,
          $$RoadmapStepsTableUpdateCompanionBuilder,
          (RoadmapStep, $$RoadmapStepsTableReferences),
          RoadmapStep,
          PrefetchHooks Function({bool pathId})
        > {
  $$RoadmapStepsTableTableManager(_$AppDatabase db, $RoadmapStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoadmapStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoadmapStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoadmapStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pathId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime?> aiDeadline = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
              }) => RoadmapStepsCompanion(
                id: id,
                pathId: pathId,
                title: title,
                description: description,
                aiDeadline: aiDeadline,
                orderIndex: orderIndex,
                isCompleted: isCompleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pathId,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<DateTime?> aiDeadline = const Value.absent(),
                required int orderIndex,
                Value<bool> isCompleted = const Value.absent(),
              }) => RoadmapStepsCompanion.insert(
                id: id,
                pathId: pathId,
                title: title,
                description: description,
                aiDeadline: aiDeadline,
                orderIndex: orderIndex,
                isCompleted: isCompleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoadmapStepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pathId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pathId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pathId,
                                referencedTable: $$RoadmapStepsTableReferences
                                    ._pathIdTable(db),
                                referencedColumn: $$RoadmapStepsTableReferences
                                    ._pathIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoadmapStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoadmapStepsTable,
      RoadmapStep,
      $$RoadmapStepsTableFilterComposer,
      $$RoadmapStepsTableOrderingComposer,
      $$RoadmapStepsTableAnnotationComposer,
      $$RoadmapStepsTableCreateCompanionBuilder,
      $$RoadmapStepsTableUpdateCompanionBuilder,
      (RoadmapStep, $$RoadmapStepsTableReferences),
      RoadmapStep,
      PrefetchHooks Function({bool pathId})
    >;
typedef $$OpportunityLogTableCreateCompanionBuilder =
    OpportunityLogCompanion Function({
      Value<int> id,
      required String title,
      required String company,
      required String type,
      required String url,
      Value<int> minReadinessLevel,
      Value<DateTime> foundAt,
    });
typedef $$OpportunityLogTableUpdateCompanionBuilder =
    OpportunityLogCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> company,
      Value<String> type,
      Value<String> url,
      Value<int> minReadinessLevel,
      Value<DateTime> foundAt,
    });

class $$OpportunityLogTableFilterComposer
    extends Composer<_$AppDatabase, $OpportunityLogTable> {
  $$OpportunityLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minReadinessLevel => $composableBuilder(
    column: $table.minReadinessLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get foundAt => $composableBuilder(
    column: $table.foundAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OpportunityLogTableOrderingComposer
    extends Composer<_$AppDatabase, $OpportunityLogTable> {
  $$OpportunityLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minReadinessLevel => $composableBuilder(
    column: $table.minReadinessLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get foundAt => $composableBuilder(
    column: $table.foundAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OpportunityLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $OpportunityLogTable> {
  $$OpportunityLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get minReadinessLevel => $composableBuilder(
    column: $table.minReadinessLevel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get foundAt =>
      $composableBuilder(column: $table.foundAt, builder: (column) => column);
}

class $$OpportunityLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OpportunityLogTable,
          OpportunityLogData,
          $$OpportunityLogTableFilterComposer,
          $$OpportunityLogTableOrderingComposer,
          $$OpportunityLogTableAnnotationComposer,
          $$OpportunityLogTableCreateCompanionBuilder,
          $$OpportunityLogTableUpdateCompanionBuilder,
          (
            OpportunityLogData,
            BaseReferences<
              _$AppDatabase,
              $OpportunityLogTable,
              OpportunityLogData
            >,
          ),
          OpportunityLogData,
          PrefetchHooks Function()
        > {
  $$OpportunityLogTableTableManager(
    _$AppDatabase db,
    $OpportunityLogTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpportunityLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpportunityLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpportunityLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> company = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<int> minReadinessLevel = const Value.absent(),
                Value<DateTime> foundAt = const Value.absent(),
              }) => OpportunityLogCompanion(
                id: id,
                title: title,
                company: company,
                type: type,
                url: url,
                minReadinessLevel: minReadinessLevel,
                foundAt: foundAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String company,
                required String type,
                required String url,
                Value<int> minReadinessLevel = const Value.absent(),
                Value<DateTime> foundAt = const Value.absent(),
              }) => OpportunityLogCompanion.insert(
                id: id,
                title: title,
                company: company,
                type: type,
                url: url,
                minReadinessLevel: minReadinessLevel,
                foundAt: foundAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OpportunityLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OpportunityLogTable,
      OpportunityLogData,
      $$OpportunityLogTableFilterComposer,
      $$OpportunityLogTableOrderingComposer,
      $$OpportunityLogTableAnnotationComposer,
      $$OpportunityLogTableCreateCompanionBuilder,
      $$OpportunityLogTableUpdateCompanionBuilder,
      (
        OpportunityLogData,
        BaseReferences<_$AppDatabase, $OpportunityLogTable, OpportunityLogData>,
      ),
      OpportunityLogData,
      PrefetchHooks Function()
    >;
typedef $$ReadinessScoresTableCreateCompanionBuilder =
    ReadinessScoresCompanion Function({
      Value<int> id,
      required String skillName,
      Value<int> score,
      Value<DateTime> lastUpdated,
    });
typedef $$ReadinessScoresTableUpdateCompanionBuilder =
    ReadinessScoresCompanion Function({
      Value<int> id,
      Value<String> skillName,
      Value<int> score,
      Value<DateTime> lastUpdated,
    });

class $$ReadinessScoresTableFilterComposer
    extends Composer<_$AppDatabase, $ReadinessScoresTable> {
  $$ReadinessScoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skillName => $composableBuilder(
    column: $table.skillName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadinessScoresTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadinessScoresTable> {
  $$ReadinessScoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skillName => $composableBuilder(
    column: $table.skillName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadinessScoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadinessScoresTable> {
  $$ReadinessScoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get skillName =>
      $composableBuilder(column: $table.skillName, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$ReadinessScoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadinessScoresTable,
          ReadinessScore,
          $$ReadinessScoresTableFilterComposer,
          $$ReadinessScoresTableOrderingComposer,
          $$ReadinessScoresTableAnnotationComposer,
          $$ReadinessScoresTableCreateCompanionBuilder,
          $$ReadinessScoresTableUpdateCompanionBuilder,
          (
            ReadinessScore,
            BaseReferences<
              _$AppDatabase,
              $ReadinessScoresTable,
              ReadinessScore
            >,
          ),
          ReadinessScore,
          PrefetchHooks Function()
        > {
  $$ReadinessScoresTableTableManager(
    _$AppDatabase db,
    $ReadinessScoresTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadinessScoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadinessScoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadinessScoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> skillName = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => ReadinessScoresCompanion(
                id: id,
                skillName: skillName,
                score: score,
                lastUpdated: lastUpdated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String skillName,
                Value<int> score = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => ReadinessScoresCompanion.insert(
                id: id,
                skillName: skillName,
                score: score,
                lastUpdated: lastUpdated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadinessScoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadinessScoresTable,
      ReadinessScore,
      $$ReadinessScoresTableFilterComposer,
      $$ReadinessScoresTableOrderingComposer,
      $$ReadinessScoresTableAnnotationComposer,
      $$ReadinessScoresTableCreateCompanionBuilder,
      $$ReadinessScoresTableUpdateCompanionBuilder,
      (
        ReadinessScore,
        BaseReferences<_$AppDatabase, $ReadinessScoresTable, ReadinessScore>,
      ),
      ReadinessScore,
      PrefetchHooks Function()
    >;
typedef $$CareerGoalsTableCreateCompanionBuilder =
    CareerGoalsCompanion Function({
      Value<int> id,
      required String title,
      Value<bool> isCompleted,
      Value<DateTime?> deadline,
    });
typedef $$CareerGoalsTableUpdateCompanionBuilder =
    CareerGoalsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<bool> isCompleted,
      Value<DateTime?> deadline,
    });

class $$CareerGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $CareerGoalsTable> {
  $$CareerGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CareerGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $CareerGoalsTable> {
  $$CareerGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CareerGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CareerGoalsTable> {
  $$CareerGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);
}

class $$CareerGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CareerGoalsTable,
          CareerGoal,
          $$CareerGoalsTableFilterComposer,
          $$CareerGoalsTableOrderingComposer,
          $$CareerGoalsTableAnnotationComposer,
          $$CareerGoalsTableCreateCompanionBuilder,
          $$CareerGoalsTableUpdateCompanionBuilder,
          (
            CareerGoal,
            BaseReferences<_$AppDatabase, $CareerGoalsTable, CareerGoal>,
          ),
          CareerGoal,
          PrefetchHooks Function()
        > {
  $$CareerGoalsTableTableManager(_$AppDatabase db, $CareerGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CareerGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CareerGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CareerGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
              }) => CareerGoalsCompanion(
                id: id,
                title: title,
                isCompleted: isCompleted,
                deadline: deadline,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
              }) => CareerGoalsCompanion.insert(
                id: id,
                title: title,
                isCompleted: isCompleted,
                deadline: deadline,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CareerGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CareerGoalsTable,
      CareerGoal,
      $$CareerGoalsTableFilterComposer,
      $$CareerGoalsTableOrderingComposer,
      $$CareerGoalsTableAnnotationComposer,
      $$CareerGoalsTableCreateCompanionBuilder,
      $$CareerGoalsTableUpdateCompanionBuilder,
      (
        CareerGoal,
        BaseReferences<_$AppDatabase, $CareerGoalsTable, CareerGoal>,
      ),
      CareerGoal,
      PrefetchHooks Function()
    >;
typedef $$DailyAttendanceTableCreateCompanionBuilder =
    DailyAttendanceCompanion Function({
      required DateTime date,
      required String status,
      Value<bool> wasManual,
      Value<int> rowid,
    });
typedef $$DailyAttendanceTableUpdateCompanionBuilder =
    DailyAttendanceCompanion Function({
      Value<DateTime> date,
      Value<String> status,
      Value<bool> wasManual,
      Value<int> rowid,
    });

class $$DailyAttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $DailyAttendanceTable> {
  $$DailyAttendanceTableFilterComposer({
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasManual => $composableBuilder(
    column: $table.wasManual,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyAttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyAttendanceTable> {
  $$DailyAttendanceTableOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasManual => $composableBuilder(
    column: $table.wasManual,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyAttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyAttendanceTable> {
  $$DailyAttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get wasManual =>
      $composableBuilder(column: $table.wasManual, builder: (column) => column);
}

class $$DailyAttendanceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyAttendanceTable,
          DailyAttendanceData,
          $$DailyAttendanceTableFilterComposer,
          $$DailyAttendanceTableOrderingComposer,
          $$DailyAttendanceTableAnnotationComposer,
          $$DailyAttendanceTableCreateCompanionBuilder,
          $$DailyAttendanceTableUpdateCompanionBuilder,
          (
            DailyAttendanceData,
            BaseReferences<
              _$AppDatabase,
              $DailyAttendanceTable,
              DailyAttendanceData
            >,
          ),
          DailyAttendanceData,
          PrefetchHooks Function()
        > {
  $$DailyAttendanceTableTableManager(
    _$AppDatabase db,
    $DailyAttendanceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyAttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyAttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyAttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> date = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> wasManual = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyAttendanceCompanion(
                date: date,
                status: status,
                wasManual: wasManual,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime date,
                required String status,
                Value<bool> wasManual = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyAttendanceCompanion.insert(
                date: date,
                status: status,
                wasManual: wasManual,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyAttendanceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyAttendanceTable,
      DailyAttendanceData,
      $$DailyAttendanceTableFilterComposer,
      $$DailyAttendanceTableOrderingComposer,
      $$DailyAttendanceTableAnnotationComposer,
      $$DailyAttendanceTableCreateCompanionBuilder,
      $$DailyAttendanceTableUpdateCompanionBuilder,
      (
        DailyAttendanceData,
        BaseReferences<
          _$AppDatabase,
          $DailyAttendanceTable,
          DailyAttendanceData
        >,
      ),
      DailyAttendanceData,
      PrefetchHooks Function()
    >;
typedef $$DailyTasksTableCreateCompanionBuilder =
    DailyTasksCompanion Function({
      Value<int> id,
      required DateTime date,
      required String title,
      Value<bool> isCompleted,
    });
typedef $$DailyTasksTableUpdateCompanionBuilder =
    DailyTasksCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> title,
      Value<bool> isCompleted,
    });

class $$DailyTasksTableFilterComposer
    extends Composer<_$AppDatabase, $DailyTasksTable> {
  $$DailyTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyTasksTable> {
  $$DailyTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyTasksTable> {
  $$DailyTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );
}

class $$DailyTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyTasksTable,
          DailyTask,
          $$DailyTasksTableFilterComposer,
          $$DailyTasksTableOrderingComposer,
          $$DailyTasksTableAnnotationComposer,
          $$DailyTasksTableCreateCompanionBuilder,
          $$DailyTasksTableUpdateCompanionBuilder,
          (
            DailyTask,
            BaseReferences<_$AppDatabase, $DailyTasksTable, DailyTask>,
          ),
          DailyTask,
          PrefetchHooks Function()
        > {
  $$DailyTasksTableTableManager(_$AppDatabase db, $DailyTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
              }) => DailyTasksCompanion(
                id: id,
                date: date,
                title: title,
                isCompleted: isCompleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String title,
                Value<bool> isCompleted = const Value.absent(),
              }) => DailyTasksCompanion.insert(
                id: id,
                date: date,
                title: title,
                isCompleted: isCompleted,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyTasksTable,
      DailyTask,
      $$DailyTasksTableFilterComposer,
      $$DailyTasksTableOrderingComposer,
      $$DailyTasksTableAnnotationComposer,
      $$DailyTasksTableCreateCompanionBuilder,
      $$DailyTasksTableUpdateCompanionBuilder,
      (DailyTask, BaseReferences<_$AppDatabase, $DailyTasksTable, DailyTask>),
      DailyTask,
      PrefetchHooks Function()
    >;
typedef $$VideoLearningLogsTableCreateCompanionBuilder =
    VideoLearningLogsCompanion Function({
      Value<int> id,
      required String videoTitle,
      required int totalDurationSeconds,
      required int watchedSeconds,
      Value<int> skipCount,
      Value<double> sincerityScore,
      Value<DateTime> watchedAt,
    });
typedef $$VideoLearningLogsTableUpdateCompanionBuilder =
    VideoLearningLogsCompanion Function({
      Value<int> id,
      Value<String> videoTitle,
      Value<int> totalDurationSeconds,
      Value<int> watchedSeconds,
      Value<int> skipCount,
      Value<double> sincerityScore,
      Value<DateTime> watchedAt,
    });

class $$VideoLearningLogsTableFilterComposer
    extends Composer<_$AppDatabase, $VideoLearningLogsTable> {
  $$VideoLearningLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoTitle => $composableBuilder(
    column: $table.videoTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDurationSeconds => $composableBuilder(
    column: $table.totalDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get watchedSeconds => $composableBuilder(
    column: $table.watchedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sincerityScore => $composableBuilder(
    column: $table.sincerityScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VideoLearningLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoLearningLogsTable> {
  $$VideoLearningLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoTitle => $composableBuilder(
    column: $table.videoTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDurationSeconds => $composableBuilder(
    column: $table.totalDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get watchedSeconds => $composableBuilder(
    column: $table.watchedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sincerityScore => $composableBuilder(
    column: $table.sincerityScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VideoLearningLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoLearningLogsTable> {
  $$VideoLearningLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get videoTitle => $composableBuilder(
    column: $table.videoTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDurationSeconds => $composableBuilder(
    column: $table.totalDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get watchedSeconds => $composableBuilder(
    column: $table.watchedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skipCount =>
      $composableBuilder(column: $table.skipCount, builder: (column) => column);

  GeneratedColumn<double> get sincerityScore => $composableBuilder(
    column: $table.sincerityScore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get watchedAt =>
      $composableBuilder(column: $table.watchedAt, builder: (column) => column);
}

class $$VideoLearningLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideoLearningLogsTable,
          VideoLearningLog,
          $$VideoLearningLogsTableFilterComposer,
          $$VideoLearningLogsTableOrderingComposer,
          $$VideoLearningLogsTableAnnotationComposer,
          $$VideoLearningLogsTableCreateCompanionBuilder,
          $$VideoLearningLogsTableUpdateCompanionBuilder,
          (
            VideoLearningLog,
            BaseReferences<
              _$AppDatabase,
              $VideoLearningLogsTable,
              VideoLearningLog
            >,
          ),
          VideoLearningLog,
          PrefetchHooks Function()
        > {
  $$VideoLearningLogsTableTableManager(
    _$AppDatabase db,
    $VideoLearningLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoLearningLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoLearningLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoLearningLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> videoTitle = const Value.absent(),
                Value<int> totalDurationSeconds = const Value.absent(),
                Value<int> watchedSeconds = const Value.absent(),
                Value<int> skipCount = const Value.absent(),
                Value<double> sincerityScore = const Value.absent(),
                Value<DateTime> watchedAt = const Value.absent(),
              }) => VideoLearningLogsCompanion(
                id: id,
                videoTitle: videoTitle,
                totalDurationSeconds: totalDurationSeconds,
                watchedSeconds: watchedSeconds,
                skipCount: skipCount,
                sincerityScore: sincerityScore,
                watchedAt: watchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String videoTitle,
                required int totalDurationSeconds,
                required int watchedSeconds,
                Value<int> skipCount = const Value.absent(),
                Value<double> sincerityScore = const Value.absent(),
                Value<DateTime> watchedAt = const Value.absent(),
              }) => VideoLearningLogsCompanion.insert(
                id: id,
                videoTitle: videoTitle,
                totalDurationSeconds: totalDurationSeconds,
                watchedSeconds: watchedSeconds,
                skipCount: skipCount,
                sincerityScore: sincerityScore,
                watchedAt: watchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VideoLearningLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideoLearningLogsTable,
      VideoLearningLog,
      $$VideoLearningLogsTableFilterComposer,
      $$VideoLearningLogsTableOrderingComposer,
      $$VideoLearningLogsTableAnnotationComposer,
      $$VideoLearningLogsTableCreateCompanionBuilder,
      $$VideoLearningLogsTableUpdateCompanionBuilder,
      (
        VideoLearningLog,
        BaseReferences<
          _$AppDatabase,
          $VideoLearningLogsTable,
          VideoLearningLog
        >,
      ),
      VideoLearningLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$UserCalibrationTableTableManager get userCalibration =>
      $$UserCalibrationTableTableManager(_db, _db.userCalibration);
  $$RoadmapPathsTableTableManager get roadmapPaths =>
      $$RoadmapPathsTableTableManager(_db, _db.roadmapPaths);
  $$RoadmapStepsTableTableManager get roadmapSteps =>
      $$RoadmapStepsTableTableManager(_db, _db.roadmapSteps);
  $$OpportunityLogTableTableManager get opportunityLog =>
      $$OpportunityLogTableTableManager(_db, _db.opportunityLog);
  $$ReadinessScoresTableTableManager get readinessScores =>
      $$ReadinessScoresTableTableManager(_db, _db.readinessScores);
  $$CareerGoalsTableTableManager get careerGoals =>
      $$CareerGoalsTableTableManager(_db, _db.careerGoals);
  $$DailyAttendanceTableTableManager get dailyAttendance =>
      $$DailyAttendanceTableTableManager(_db, _db.dailyAttendance);
  $$DailyTasksTableTableManager get dailyTasks =>
      $$DailyTasksTableTableManager(_db, _db.dailyTasks);
  $$VideoLearningLogsTableTableManager get videoLearningLogs =>
      $$VideoLearningLogsTableTableManager(_db, _db.videoLearningLogs);
}
