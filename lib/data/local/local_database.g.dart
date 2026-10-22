// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $CurrenciesTable extends Currencies
    with TableInfo<$CurrenciesTable, LocalCurrency> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  @override
  List<GeneratedColumn> get $columns => [id, name, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'currencies';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCurrency> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCurrency map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCurrency(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $CurrenciesTable createAlias(String alias) {
    return $CurrenciesTable(attachedDatabase, alias);
  }
}

class LocalCurrency extends DataClass implements Insertable<LocalCurrency> {
  final int id;
  final String name;
  final double value;
  const LocalCurrency({
    required this.id,
    required this.name,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['value'] = Variable<double>(value);
    return map;
  }

  CurrenciesCompanion toCompanion(bool nullToAbsent) {
    return CurrenciesCompanion(
      id: Value(id),
      name: Value(name),
      value: Value(value),
    );
  }

  factory LocalCurrency.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCurrency(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<double>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<double>(value),
    };
  }

  LocalCurrency copyWith({int? id, String? name, double? value}) =>
      LocalCurrency(
        id: id ?? this.id,
        name: name ?? this.name,
        value: value ?? this.value,
      );
  LocalCurrency copyWithCompanion(CurrenciesCompanion data) {
    return LocalCurrency(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCurrency(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCurrency &&
          other.id == this.id &&
          other.name == this.name &&
          other.value == this.value);
}

class CurrenciesCompanion extends UpdateCompanion<LocalCurrency> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> value;
  const CurrenciesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.value = const Value.absent(),
  });
  CurrenciesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double value,
  }) : name = Value(name),
       value = Value(value);
  static Insertable<LocalCurrency> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
    });
  }

  CurrenciesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? value,
  }) {
    return CurrenciesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrenciesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, LocalAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountTypeMeta = const VerificationMeta(
    'accountType',
  );
  @override
  late final GeneratedColumn<int> accountType = GeneratedColumn<int>(
    'account_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyIdMeta = const VerificationMeta(
    'currencyId',
  );
  @override
  late final GeneratedColumn<int> currencyId = GeneratedColumn<int>(
    'currency_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES currencies (id)',
    ),
  );
  static const VerificationMeta _measurableMeta = const VerificationMeta(
    'measurable',
  );
  @override
  late final GeneratedColumn<bool> measurable = GeneratedColumn<bool>(
    'measurable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("measurable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _archiveMeta = const VerificationMeta(
    'archive',
  );
  @override
  late final GeneratedColumn<bool> archive = GeneratedColumn<bool>(
    'archive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archive" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _transactionsImportedMeta =
      const VerificationMeta('transactionsImported');
  @override
  late final GeneratedColumn<bool> transactionsImported = GeneratedColumn<bool>(
    'transactions_imported',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("transactions_imported" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    accountType,
    currencyId,
    measurable,
    archive,
    isHidden,
    serverId,
    transactionsImported,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('account_type')) {
      context.handle(
        _accountTypeMeta,
        accountType.isAcceptableOrUnknown(
          data['account_type']!,
          _accountTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountTypeMeta);
    }
    if (data.containsKey('currency_id')) {
      context.handle(
        _currencyIdMeta,
        currencyId.isAcceptableOrUnknown(data['currency_id']!, _currencyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyIdMeta);
    }
    if (data.containsKey('measurable')) {
      context.handle(
        _measurableMeta,
        measurable.isAcceptableOrUnknown(data['measurable']!, _measurableMeta),
      );
    }
    if (data.containsKey('archive')) {
      context.handle(
        _archiveMeta,
        archive.isAcceptableOrUnknown(data['archive']!, _archiveMeta),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('transactions_imported')) {
      context.handle(
        _transactionsImportedMeta,
        transactionsImported.isAcceptableOrUnknown(
          data['transactions_imported']!,
          _transactionsImportedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      accountType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_type'],
      )!,
      currencyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}currency_id'],
      )!,
      measurable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}measurable'],
      )!,
      archive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archive'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      transactionsImported: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}transactions_imported'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class LocalAccount extends DataClass implements Insertable<LocalAccount> {
  final int id;
  final String name;

  /// 0 = Cash, 1 = BankAccount
  final int accountType;
  final int currencyId;
  final bool measurable;
  final bool archive;
  final bool isHidden;
  final int? serverId;
  final bool transactionsImported;
  const LocalAccount({
    required this.id,
    required this.name,
    required this.accountType,
    required this.currencyId,
    required this.measurable,
    required this.archive,
    required this.isHidden,
    this.serverId,
    required this.transactionsImported,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['account_type'] = Variable<int>(accountType);
    map['currency_id'] = Variable<int>(currencyId);
    map['measurable'] = Variable<bool>(measurable);
    map['archive'] = Variable<bool>(archive);
    map['is_hidden'] = Variable<bool>(isHidden);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['transactions_imported'] = Variable<bool>(transactionsImported);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      accountType: Value(accountType),
      currencyId: Value(currencyId),
      measurable: Value(measurable),
      archive: Value(archive),
      isHidden: Value(isHidden),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      transactionsImported: Value(transactionsImported),
    );
  }

  factory LocalAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAccount(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      accountType: serializer.fromJson<int>(json['accountType']),
      currencyId: serializer.fromJson<int>(json['currencyId']),
      measurable: serializer.fromJson<bool>(json['measurable']),
      archive: serializer.fromJson<bool>(json['archive']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      transactionsImported: serializer.fromJson<bool>(
        json['transactionsImported'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'accountType': serializer.toJson<int>(accountType),
      'currencyId': serializer.toJson<int>(currencyId),
      'measurable': serializer.toJson<bool>(measurable),
      'archive': serializer.toJson<bool>(archive),
      'isHidden': serializer.toJson<bool>(isHidden),
      'serverId': serializer.toJson<int?>(serverId),
      'transactionsImported': serializer.toJson<bool>(transactionsImported),
    };
  }

  LocalAccount copyWith({
    int? id,
    String? name,
    int? accountType,
    int? currencyId,
    bool? measurable,
    bool? archive,
    bool? isHidden,
    Value<int?> serverId = const Value.absent(),
    bool? transactionsImported,
  }) => LocalAccount(
    id: id ?? this.id,
    name: name ?? this.name,
    accountType: accountType ?? this.accountType,
    currencyId: currencyId ?? this.currencyId,
    measurable: measurable ?? this.measurable,
    archive: archive ?? this.archive,
    isHidden: isHidden ?? this.isHidden,
    serverId: serverId.present ? serverId.value : this.serverId,
    transactionsImported: transactionsImported ?? this.transactionsImported,
  );
  LocalAccount copyWithCompanion(AccountsCompanion data) {
    return LocalAccount(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      accountType: data.accountType.present
          ? data.accountType.value
          : this.accountType,
      currencyId: data.currencyId.present
          ? data.currencyId.value
          : this.currencyId,
      measurable: data.measurable.present
          ? data.measurable.value
          : this.measurable,
      archive: data.archive.present ? data.archive.value : this.archive,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      transactionsImported: data.transactionsImported.present
          ? data.transactionsImported.value
          : this.transactionsImported,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccount(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountType: $accountType, ')
          ..write('currencyId: $currencyId, ')
          ..write('measurable: $measurable, ')
          ..write('archive: $archive, ')
          ..write('isHidden: $isHidden, ')
          ..write('serverId: $serverId, ')
          ..write('transactionsImported: $transactionsImported')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    accountType,
    currencyId,
    measurable,
    archive,
    isHidden,
    serverId,
    transactionsImported,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAccount &&
          other.id == this.id &&
          other.name == this.name &&
          other.accountType == this.accountType &&
          other.currencyId == this.currencyId &&
          other.measurable == this.measurable &&
          other.archive == this.archive &&
          other.isHidden == this.isHidden &&
          other.serverId == this.serverId &&
          other.transactionsImported == this.transactionsImported);
}

class AccountsCompanion extends UpdateCompanion<LocalAccount> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> accountType;
  final Value<int> currencyId;
  final Value<bool> measurable;
  final Value<bool> archive;
  final Value<bool> isHidden;
  final Value<int?> serverId;
  final Value<bool> transactionsImported;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.accountType = const Value.absent(),
    this.currencyId = const Value.absent(),
    this.measurable = const Value.absent(),
    this.archive = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.serverId = const Value.absent(),
    this.transactionsImported = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int accountType,
    required int currencyId,
    this.measurable = const Value.absent(),
    this.archive = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.serverId = const Value.absent(),
    this.transactionsImported = const Value.absent(),
  }) : name = Value(name),
       accountType = Value(accountType),
       currencyId = Value(currencyId);
  static Insertable<LocalAccount> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? accountType,
    Expression<int>? currencyId,
    Expression<bool>? measurable,
    Expression<bool>? archive,
    Expression<bool>? isHidden,
    Expression<int>? serverId,
    Expression<bool>? transactionsImported,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (accountType != null) 'account_type': accountType,
      if (currencyId != null) 'currency_id': currencyId,
      if (measurable != null) 'measurable': measurable,
      if (archive != null) 'archive': archive,
      if (isHidden != null) 'is_hidden': isHidden,
      if (serverId != null) 'server_id': serverId,
      if (transactionsImported != null)
        'transactions_imported': transactionsImported,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? accountType,
    Value<int>? currencyId,
    Value<bool>? measurable,
    Value<bool>? archive,
    Value<bool>? isHidden,
    Value<int?>? serverId,
    Value<bool>? transactionsImported,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      currencyId: currencyId ?? this.currencyId,
      measurable: measurable ?? this.measurable,
      archive: archive ?? this.archive,
      isHidden: isHidden ?? this.isHidden,
      serverId: serverId ?? this.serverId,
      transactionsImported: transactionsImported ?? this.transactionsImported,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (accountType.present) {
      map['account_type'] = Variable<int>(accountType.value);
    }
    if (currencyId.present) {
      map['currency_id'] = Variable<int>(currencyId.value);
    }
    if (measurable.present) {
      map['measurable'] = Variable<bool>(measurable.value);
    }
    if (archive.present) {
      map['archive'] = Variable<bool>(archive.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (transactionsImported.present) {
      map['transactions_imported'] = Variable<bool>(transactionsImported.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountType: $accountType, ')
          ..write('currencyId: $currencyId, ')
          ..write('measurable: $measurable, ')
          ..write('archive: $archive, ')
          ..write('isHidden: $isHidden, ')
          ..write('serverId: $serverId, ')
          ..write('transactionsImported: $transactionsImported')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, LocalCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#ffffff'),
  );
  static const VerificationMeta _measurableMeta = const VerificationMeta(
    'measurable',
  );
  @override
  late final GeneratedColumn<bool> measurable = GeneratedColumn<bool>(
    'measurable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("measurable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nameKey,
    icon,
    color,
    measurable,
    isActive,
    serverId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('measurable')) {
      context.handle(
        _measurableMeta,
        measurable.isAcceptableOrUnknown(data['measurable']!, _measurableMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      measurable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}measurable'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class LocalCategory extends DataClass implements Insertable<LocalCategory> {
  final int id;
  final String name;

  /// [categoryNameKey] of the name. It is what must be unique, because SQLite's
  /// `lower()` only folds ASCII, so a unique index on `lower(name)` lets "Útiles"
  /// and "útiles" both in. The default only fills rows that existed before schema 2.
  final String nameKey;
  final String icon;
  final String color;
  final bool measurable;
  final bool isActive;
  final int? serverId;
  const LocalCategory({
    required this.id,
    required this.name,
    required this.nameKey,
    required this.icon,
    required this.color,
    required this.measurable,
    required this.isActive,
    this.serverId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_key'] = Variable<String>(nameKey);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    map['measurable'] = Variable<bool>(measurable);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      nameKey: Value(nameKey),
      icon: Value(icon),
      color: Value(color),
      measurable: Value(measurable),
      isActive: Value(isActive),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
    );
  }

  factory LocalCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      measurable: serializer.fromJson<bool>(json['measurable']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      serverId: serializer.fromJson<int?>(json['serverId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'measurable': serializer.toJson<bool>(measurable),
      'isActive': serializer.toJson<bool>(isActive),
      'serverId': serializer.toJson<int?>(serverId),
    };
  }

  LocalCategory copyWith({
    int? id,
    String? name,
    String? nameKey,
    String? icon,
    String? color,
    bool? measurable,
    bool? isActive,
    Value<int?> serverId = const Value.absent(),
  }) => LocalCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    measurable: measurable ?? this.measurable,
    isActive: isActive ?? this.isActive,
    serverId: serverId.present ? serverId.value : this.serverId,
  );
  LocalCategory copyWithCompanion(CategoriesCompanion data) {
    return LocalCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      measurable: data.measurable.present
          ? data.measurable.value
          : this.measurable,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('measurable: $measurable, ')
          ..write('isActive: $isActive, ')
          ..write('serverId: $serverId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nameKey,
    icon,
    color,
    measurable,
    isActive,
    serverId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameKey == this.nameKey &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.measurable == this.measurable &&
          other.isActive == this.isActive &&
          other.serverId == this.serverId);
}

class CategoriesCompanion extends UpdateCompanion<LocalCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameKey;
  final Value<String> icon;
  final Value<String> color;
  final Value<bool> measurable;
  final Value<bool> isActive;
  final Value<int?> serverId;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.measurable = const Value.absent(),
    this.isActive = const Value.absent(),
    this.serverId = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nameKey = const Value.absent(),
    required String icon,
    this.color = const Value.absent(),
    this.measurable = const Value.absent(),
    this.isActive = const Value.absent(),
    this.serverId = const Value.absent(),
  }) : name = Value(name),
       icon = Value(icon);
  static Insertable<LocalCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameKey,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<bool>? measurable,
    Expression<bool>? isActive,
    Expression<int>? serverId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameKey != null) 'name_key': nameKey,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (measurable != null) 'measurable': measurable,
      if (isActive != null) 'is_active': isActive,
      if (serverId != null) 'server_id': serverId,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameKey,
    Value<String>? icon,
    Value<String>? color,
    Value<bool>? measurable,
    Value<bool>? isActive,
    Value<int?>? serverId,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      measurable: measurable ?? this.measurable,
      isActive: isActive ?? this.isActive,
      serverId: serverId ?? this.serverId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (measurable.present) {
      map['measurable'] = Variable<bool>(measurable.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('measurable: $measurable, ')
          ..write('isActive: $isActive, ')
          ..write('serverId: $serverId')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, LocalTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    check: () => ComparableExpr(amount).isBiggerThanValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<int> transactionType = GeneratedColumn<int>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    categoryId,
    name,
    amount,
    transactionType,
    date,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
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
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_type'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class LocalTransaction extends DataClass
    implements Insertable<LocalTransaction> {
  final int id;
  final int accountId;
  final int categoryId;
  final String name;
  final double amount;

  /// 0 = Income, 1 = Outcome
  final int transactionType;

  /// UTC midnight of the chosen day.
  final DateTime date;
  final DateTime createdAt;
  const LocalTransaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.transactionType,
    required this.date,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    map['category_id'] = Variable<int>(categoryId);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['transaction_type'] = Variable<int>(transactionType);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      categoryId: Value(categoryId),
      name: Value(name),
      amount: Value(amount),
      transactionType: Value(transactionType),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory LocalTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTransaction(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      transactionType: serializer.fromJson<int>(json['transactionType']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'categoryId': serializer.toJson<int>(categoryId),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'transactionType': serializer.toJson<int>(transactionType),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalTransaction copyWith({
    int? id,
    int? accountId,
    int? categoryId,
    String? name,
    double? amount,
    int? transactionType,
    DateTime? date,
    DateTime? createdAt,
  }) => LocalTransaction(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    transactionType: transactionType ?? this.transactionType,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalTransaction copyWithCompanion(TransactionsCompanion data) {
    return LocalTransaction(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransaction(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('transactionType: $transactionType, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    categoryId,
    name,
    amount,
    transactionType,
    date,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTransaction &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.transactionType == this.transactionType &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<LocalTransaction> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<int> categoryId;
  final Value<String> name;
  final Value<double> amount;
  final Value<int> transactionType;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    required int categoryId,
    required String name,
    required double amount,
    required int transactionType,
    required DateTime date,
    required DateTime createdAt,
  }) : accountId = Value(accountId),
       categoryId = Value(categoryId),
       name = Value(name),
       amount = Value(amount),
       transactionType = Value(transactionType),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<LocalTransaction> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<int>? categoryId,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<int>? transactionType,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (transactionType != null) 'transaction_type': transactionType,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? accountId,
    Value<int>? categoryId,
    Value<String>? name,
    Value<double>? amount,
    Value<int>? transactionType,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      transactionType: transactionType ?? this.transactionType,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<int>(transactionType.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('transactionType: $transactionType, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ImportStatesTable extends ImportStates
    with TableInfo<$ImportStatesTable, LocalImportState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ImportStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ImportStatus>($ImportStatesTable.$converterstatus);
  static const VerificationMeta _targetEmailMeta = const VerificationMeta(
    'targetEmail',
  );
  @override
  late final GeneratedColumn<String> targetEmail = GeneratedColumn<String>(
    'target_email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importTagMeta = const VerificationMeta(
    'importTag',
  );
  @override
  late final GeneratedColumn<String> importTag = GeneratedColumn<String>(
    'import_tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultAccountServerIdMeta =
      const VerificationMeta('defaultAccountServerId');
  @override
  late final GeneratedColumn<int> defaultAccountServerId = GeneratedColumn<int>(
    'default_account_server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    targetEmail,
    startedAt,
    lastError,
    importTag,
    defaultAccountServerId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalImportState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_email')) {
      context.handle(
        _targetEmailMeta,
        targetEmail.isAcceptableOrUnknown(
          data['target_email']!,
          _targetEmailMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('import_tag')) {
      context.handle(
        _importTagMeta,
        importTag.isAcceptableOrUnknown(data['import_tag']!, _importTagMeta),
      );
    }
    if (data.containsKey('default_account_server_id')) {
      context.handle(
        _defaultAccountServerIdMeta,
        defaultAccountServerId.isAcceptableOrUnknown(
          data['default_account_server_id']!,
          _defaultAccountServerIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalImportState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalImportState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      status: $ImportStatesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      targetEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_email'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      importTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_tag'],
      ),
      defaultAccountServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_account_server_id'],
      ),
    );
  }

  @override
  $ImportStatesTable createAlias(String alias) {
    return $ImportStatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ImportStatus, int, int> $converterstatus =
      const EnumIndexConverter<ImportStatus>(ImportStatus.values);
}

class LocalImportState extends DataClass
    implements Insertable<LocalImportState> {
  final int id;
  final ImportStatus status;
  final String? targetEmail;
  final DateTime? startedAt;
  final String? lastError;

  /// 8 random hex chars. Makes the temporary account names unique to one import.
  final String? importTag;
  final int? defaultAccountServerId;
  const LocalImportState({
    required this.id,
    required this.status,
    this.targetEmail,
    this.startedAt,
    this.lastError,
    this.importTag,
    this.defaultAccountServerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['status'] = Variable<int>(
        $ImportStatesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || targetEmail != null) {
      map['target_email'] = Variable<String>(targetEmail);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || importTag != null) {
      map['import_tag'] = Variable<String>(importTag);
    }
    if (!nullToAbsent || defaultAccountServerId != null) {
      map['default_account_server_id'] = Variable<int>(defaultAccountServerId);
    }
    return map;
  }

  ImportStatesCompanion toCompanion(bool nullToAbsent) {
    return ImportStatesCompanion(
      id: Value(id),
      status: Value(status),
      targetEmail: targetEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(targetEmail),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      importTag: importTag == null && nullToAbsent
          ? const Value.absent()
          : Value(importTag),
      defaultAccountServerId: defaultAccountServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultAccountServerId),
    );
  }

  factory LocalImportState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalImportState(
      id: serializer.fromJson<int>(json['id']),
      status: $ImportStatesTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      targetEmail: serializer.fromJson<String?>(json['targetEmail']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      importTag: serializer.fromJson<String?>(json['importTag']),
      defaultAccountServerId: serializer.fromJson<int?>(
        json['defaultAccountServerId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'status': serializer.toJson<int>(
        $ImportStatesTable.$converterstatus.toJson(status),
      ),
      'targetEmail': serializer.toJson<String?>(targetEmail),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'importTag': serializer.toJson<String?>(importTag),
      'defaultAccountServerId': serializer.toJson<int?>(defaultAccountServerId),
    };
  }

  LocalImportState copyWith({
    int? id,
    ImportStatus? status,
    Value<String?> targetEmail = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    Value<String?> importTag = const Value.absent(),
    Value<int?> defaultAccountServerId = const Value.absent(),
  }) => LocalImportState(
    id: id ?? this.id,
    status: status ?? this.status,
    targetEmail: targetEmail.present ? targetEmail.value : this.targetEmail,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    importTag: importTag.present ? importTag.value : this.importTag,
    defaultAccountServerId: defaultAccountServerId.present
        ? defaultAccountServerId.value
        : this.defaultAccountServerId,
  );
  LocalImportState copyWithCompanion(ImportStatesCompanion data) {
    return LocalImportState(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      targetEmail: data.targetEmail.present
          ? data.targetEmail.value
          : this.targetEmail,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      importTag: data.importTag.present ? data.importTag.value : this.importTag,
      defaultAccountServerId: data.defaultAccountServerId.present
          ? data.defaultAccountServerId.value
          : this.defaultAccountServerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalImportState(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('targetEmail: $targetEmail, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastError: $lastError, ')
          ..write('importTag: $importTag, ')
          ..write('defaultAccountServerId: $defaultAccountServerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    status,
    targetEmail,
    startedAt,
    lastError,
    importTag,
    defaultAccountServerId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalImportState &&
          other.id == this.id &&
          other.status == this.status &&
          other.targetEmail == this.targetEmail &&
          other.startedAt == this.startedAt &&
          other.lastError == this.lastError &&
          other.importTag == this.importTag &&
          other.defaultAccountServerId == this.defaultAccountServerId);
}

class ImportStatesCompanion extends UpdateCompanion<LocalImportState> {
  final Value<int> id;
  final Value<ImportStatus> status;
  final Value<String?> targetEmail;
  final Value<DateTime?> startedAt;
  final Value<String?> lastError;
  final Value<String?> importTag;
  final Value<int?> defaultAccountServerId;
  const ImportStatesCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.targetEmail = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.importTag = const Value.absent(),
    this.defaultAccountServerId = const Value.absent(),
  });
  ImportStatesCompanion.insert({
    this.id = const Value.absent(),
    required ImportStatus status,
    this.targetEmail = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.importTag = const Value.absent(),
    this.defaultAccountServerId = const Value.absent(),
  }) : status = Value(status);
  static Insertable<LocalImportState> custom({
    Expression<int>? id,
    Expression<int>? status,
    Expression<String>? targetEmail,
    Expression<DateTime>? startedAt,
    Expression<String>? lastError,
    Expression<String>? importTag,
    Expression<int>? defaultAccountServerId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (targetEmail != null) 'target_email': targetEmail,
      if (startedAt != null) 'started_at': startedAt,
      if (lastError != null) 'last_error': lastError,
      if (importTag != null) 'import_tag': importTag,
      if (defaultAccountServerId != null)
        'default_account_server_id': defaultAccountServerId,
    });
  }

  ImportStatesCompanion copyWith({
    Value<int>? id,
    Value<ImportStatus>? status,
    Value<String?>? targetEmail,
    Value<DateTime?>? startedAt,
    Value<String?>? lastError,
    Value<String?>? importTag,
    Value<int?>? defaultAccountServerId,
  }) {
    return ImportStatesCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      targetEmail: targetEmail ?? this.targetEmail,
      startedAt: startedAt ?? this.startedAt,
      lastError: lastError ?? this.lastError,
      importTag: importTag ?? this.importTag,
      defaultAccountServerId:
          defaultAccountServerId ?? this.defaultAccountServerId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $ImportStatesTable.$converterstatus.toSql(status.value),
      );
    }
    if (targetEmail.present) {
      map['target_email'] = Variable<String>(targetEmail.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (importTag.present) {
      map['import_tag'] = Variable<String>(importTag.value);
    }
    if (defaultAccountServerId.present) {
      map['default_account_server_id'] = Variable<int>(
        defaultAccountServerId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportStatesCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('targetEmail: $targetEmail, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastError: $lastError, ')
          ..write('importTag: $importTag, ')
          ..write('defaultAccountServerId: $defaultAccountServerId')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $CurrenciesTable currencies = $CurrenciesTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $ImportStatesTable importStates = $ImportStatesTable(this);
  late final Index categoriesNameKey = Index(
    'categories_name_key',
    'CREATE UNIQUE INDEX categories_name_key ON categories (name_key)',
  );
  late final Index transactionsAccountDate = Index(
    'transactions_account_date',
    'CREATE INDEX transactions_account_date ON transactions (account_id, date DESC, id DESC)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    currencies,
    accounts,
    categories,
    transactions,
    importStates,
    categoriesNameKey,
    transactionsAccountDate,
  ];
}

typedef $$CurrenciesTableCreateCompanionBuilder =
    CurrenciesCompanion Function({
      Value<int> id,
      required String name,
      required double value,
    });
typedef $$CurrenciesTableUpdateCompanionBuilder =
    CurrenciesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> value,
    });

final class $$CurrenciesTableReferences
    extends BaseReferences<_$LocalDatabase, $CurrenciesTable, LocalCurrency> {
  $$CurrenciesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AccountsTable, List<LocalAccount>>
  _accountsRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.accounts,
    aliasName: 'currencies__id__accounts__currency_id',
  );

  $$AccountsTableProcessedTableManager get accountsRefs {
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.currencyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_accountsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CurrenciesTableFilterComposer
    extends Composer<_$LocalDatabase, $CurrenciesTable> {
  $$CurrenciesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> accountsRefs(
    Expression<bool> Function($$AccountsTableFilterComposer f) f,
  ) {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.currencyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CurrenciesTableOrderingComposer
    extends Composer<_$LocalDatabase, $CurrenciesTable> {
  $$CurrenciesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurrenciesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CurrenciesTable> {
  $$CurrenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  Expression<T> accountsRefs<T extends Object>(
    Expression<T> Function($$AccountsTableAnnotationComposer a) f,
  ) {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.currencyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CurrenciesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $CurrenciesTable,
          LocalCurrency,
          $$CurrenciesTableFilterComposer,
          $$CurrenciesTableOrderingComposer,
          $$CurrenciesTableAnnotationComposer,
          $$CurrenciesTableCreateCompanionBuilder,
          $$CurrenciesTableUpdateCompanionBuilder,
          (LocalCurrency, $$CurrenciesTableReferences),
          LocalCurrency,
          PrefetchHooks Function({bool accountsRefs})
        > {
  $$CurrenciesTableTableManager(_$LocalDatabase db, $CurrenciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurrenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurrenciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> value = const Value.absent(),
              }) => CurrenciesCompanion(id: id, name: name, value: value),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double value,
              }) =>
                  CurrenciesCompanion.insert(id: id, name: name, value: value),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CurrenciesTable, LocalCurrency>(table),
                  $$CurrenciesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (accountsRefs) db.accounts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (accountsRefs)
                    await $_getPrefetchedData<
                      LocalCurrency,
                      $CurrenciesTable,
                      LocalAccount
                    >(
                      currentTable: table,
                      referencedTable: $$CurrenciesTableReferences
                          ._accountsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CurrenciesTableReferences(
                            db,
                            table,
                            p0,
                          ).accountsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.currencyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CurrenciesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $CurrenciesTable,
      LocalCurrency,
      $$CurrenciesTableFilterComposer,
      $$CurrenciesTableOrderingComposer,
      $$CurrenciesTableAnnotationComposer,
      $$CurrenciesTableCreateCompanionBuilder,
      $$CurrenciesTableUpdateCompanionBuilder,
      (LocalCurrency, $$CurrenciesTableReferences),
      LocalCurrency,
      PrefetchHooks Function({bool accountsRefs})
    >;
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      required String name,
      required int accountType,
      required int currencyId,
      Value<bool> measurable,
      Value<bool> archive,
      Value<bool> isHidden,
      Value<int?> serverId,
      Value<bool> transactionsImported,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> accountType,
      Value<int> currencyId,
      Value<bool> measurable,
      Value<bool> archive,
      Value<bool> isHidden,
      Value<int?> serverId,
      Value<bool> transactionsImported,
    });

final class $$AccountsTableReferences
    extends BaseReferences<_$LocalDatabase, $AccountsTable, LocalAccount> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CurrenciesTable _currencyIdTable(_$LocalDatabase db) =>
      db.currencies.createAlias('accounts__currency_id__currencies__id');

  $$CurrenciesTableProcessedTableManager get currencyId {
    final $_column = $_itemColumn<int>('currency_id')!;

    final manager = $$CurrenciesTableTableManager(
      $_db,
      $_db.currencies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<LocalTransaction>>
  _transactionsRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'accounts__id__transactions__account_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$LocalDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get measurable => $composableBuilder(
    column: $table.measurable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archive => $composableBuilder(
    column: $table.archive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get transactionsImported => $composableBuilder(
    column: $table.transactionsImported,
    builder: (column) => ColumnFilters(column),
  );

  $$CurrenciesTableFilterComposer get currencyId {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyId,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableFilterComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$LocalDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get measurable => $composableBuilder(
    column: $table.measurable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archive => $composableBuilder(
    column: $table.archive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get transactionsImported => $composableBuilder(
    column: $table.transactionsImported,
    builder: (column) => ColumnOrderings(column),
  );

  $$CurrenciesTableOrderingComposer get currencyId {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyId,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableOrderingComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get measurable => $composableBuilder(
    column: $table.measurable,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archive =>
      $composableBuilder(column: $table.archive, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<bool> get transactionsImported => $composableBuilder(
    column: $table.transactionsImported,
    builder: (column) => column,
  );

  $$CurrenciesTableAnnotationComposer get currencyId {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyId,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $AccountsTable,
          LocalAccount,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (LocalAccount, $$AccountsTableReferences),
          LocalAccount,
          PrefetchHooks Function({bool currencyId, bool transactionsRefs})
        > {
  $$AccountsTableTableManager(_$LocalDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> accountType = const Value.absent(),
                Value<int> currencyId = const Value.absent(),
                Value<bool> measurable = const Value.absent(),
                Value<bool> archive = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<bool> transactionsImported = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                accountType: accountType,
                currencyId: currencyId,
                measurable: measurable,
                archive: archive,
                isHidden: isHidden,
                serverId: serverId,
                transactionsImported: transactionsImported,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int accountType,
                required int currencyId,
                Value<bool> measurable = const Value.absent(),
                Value<bool> archive = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<bool> transactionsImported = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                accountType: accountType,
                currencyId: currencyId,
                measurable: measurable,
                archive: archive,
                isHidden: isHidden,
                serverId: serverId,
                transactionsImported: transactionsImported,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, LocalAccount>(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({currencyId = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                  ],
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
                        if (currencyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.currencyId,
                                    referencedTable: $$AccountsTableReferences
                                        ._currencyIdTable(db),
                                    referencedColumn: $$AccountsTableReferences
                                        ._currencyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          LocalAccount,
                          $AccountsTable,
                          LocalTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $AccountsTable,
      LocalAccount,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (LocalAccount, $$AccountsTableReferences),
      LocalAccount,
      PrefetchHooks Function({bool currencyId, bool transactionsRefs})
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<String> nameKey,
      required String icon,
      Value<String> color,
      Value<bool> measurable,
      Value<bool> isActive,
      Value<int?> serverId,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> nameKey,
      Value<String> icon,
      Value<String> color,
      Value<bool> measurable,
      Value<bool> isActive,
      Value<int?> serverId,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$LocalDatabase, $CategoriesTable, LocalCategory> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<LocalTransaction>>
  _transactionsRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'categories__id__transactions__category_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$LocalDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get measurable => $composableBuilder(
    column: $table.measurable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$LocalDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get measurable => $composableBuilder(
    column: $table.measurable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get measurable => $composableBuilder(
    column: $table.measurable,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $CategoriesTable,
          LocalCategory,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (LocalCategory, $$CategoriesTableReferences),
          LocalCategory,
          PrefetchHooks Function({bool transactionsRefs})
        > {
  $$CategoriesTableTableManager(_$LocalDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<bool> measurable = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                nameKey: nameKey,
                icon: icon,
                color: color,
                measurable: measurable,
                isActive: isActive,
                serverId: serverId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> nameKey = const Value.absent(),
                required String icon,
                Value<String> color = const Value.absent(),
                Value<bool> measurable = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                nameKey: nameKey,
                icon: icon,
                color: color,
                measurable: measurable,
                isActive: isActive,
                serverId: serverId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, LocalCategory>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (transactionsRefs) db.transactions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<
                      LocalCategory,
                      $CategoriesTable,
                      LocalTransaction
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._transactionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).transactionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $CategoriesTable,
      LocalCategory,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (LocalCategory, $$CategoriesTableReferences),
      LocalCategory,
      PrefetchHooks Function({bool transactionsRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required int accountId,
      required int categoryId,
      required String name,
      required double amount,
      required int transactionType,
      required DateTime date,
      required DateTime createdAt,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<int> accountId,
      Value<int> categoryId,
      Value<String> name,
      Value<double> amount,
      Value<int> transactionType,
      Value<DateTime> date,
      Value<DateTime> createdAt,
    });

final class $$TransactionsTableReferences
    extends
        BaseReferences<_$LocalDatabase, $TransactionsTable, LocalTransaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$LocalDatabase db) =>
      db.accounts.createAlias('transactions__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$LocalDatabase db) =>
      db.categories.createAlias('transactions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$LocalDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionType => $composableBuilder(
    column: $table.transactionType,
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

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$LocalDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionType => $composableBuilder(
    column: $table.transactionType,
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

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $TransactionsTable,
          LocalTransaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (LocalTransaction, $$TransactionsTableReferences),
          LocalTransaction,
          PrefetchHooks Function({bool accountId, bool categoryId})
        > {
  $$TransactionsTableTableManager(_$LocalDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> transactionType = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                name: name,
                amount: amount,
                transactionType: transactionType,
                date: date,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int accountId,
                required int categoryId,
                required String name,
                required double amount,
                required int transactionType,
                required DateTime date,
                required DateTime createdAt,
              }) => TransactionsCompanion.insert(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                name: name,
                amount: amount,
                transactionType: transactionType,
                date: date,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, LocalTransaction>(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false, categoryId = false}) {
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
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable: $$TransactionsTableReferences
                                    ._accountIdTable(db),
                                referencedColumn: $$TransactionsTableReferences
                                    ._accountIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$TransactionsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$TransactionsTableReferences
                                    ._categoryIdTable(db)
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

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $TransactionsTable,
      LocalTransaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (LocalTransaction, $$TransactionsTableReferences),
      LocalTransaction,
      PrefetchHooks Function({bool accountId, bool categoryId})
    >;
typedef $$ImportStatesTableCreateCompanionBuilder =
    ImportStatesCompanion Function({
      Value<int> id,
      required ImportStatus status,
      Value<String?> targetEmail,
      Value<DateTime?> startedAt,
      Value<String?> lastError,
      Value<String?> importTag,
      Value<int?> defaultAccountServerId,
    });
typedef $$ImportStatesTableUpdateCompanionBuilder =
    ImportStatesCompanion Function({
      Value<int> id,
      Value<ImportStatus> status,
      Value<String?> targetEmail,
      Value<DateTime?> startedAt,
      Value<String?> lastError,
      Value<String?> importTag,
      Value<int?> defaultAccountServerId,
    });

class $$ImportStatesTableFilterComposer
    extends Composer<_$LocalDatabase, $ImportStatesTable> {
  $$ImportStatesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ImportStatus, ImportStatus, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get targetEmail => $composableBuilder(
    column: $table.targetEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importTag => $composableBuilder(
    column: $table.importTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultAccountServerId => $composableBuilder(
    column: $table.defaultAccountServerId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportStatesTableOrderingComposer
    extends Composer<_$LocalDatabase, $ImportStatesTable> {
  $$ImportStatesTableOrderingComposer({
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

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetEmail => $composableBuilder(
    column: $table.targetEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importTag => $composableBuilder(
    column: $table.importTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultAccountServerId => $composableBuilder(
    column: $table.defaultAccountServerId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportStatesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ImportStatesTable> {
  $$ImportStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ImportStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get targetEmail => $composableBuilder(
    column: $table.targetEmail,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get importTag =>
      $composableBuilder(column: $table.importTag, builder: (column) => column);

  GeneratedColumn<int> get defaultAccountServerId => $composableBuilder(
    column: $table.defaultAccountServerId,
    builder: (column) => column,
  );
}

class $$ImportStatesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $ImportStatesTable,
          LocalImportState,
          $$ImportStatesTableFilterComposer,
          $$ImportStatesTableOrderingComposer,
          $$ImportStatesTableAnnotationComposer,
          $$ImportStatesTableCreateCompanionBuilder,
          $$ImportStatesTableUpdateCompanionBuilder,
          (
            LocalImportState,
            BaseReferences<
              _$LocalDatabase,
              $ImportStatesTable,
              LocalImportState
            >,
          ),
          LocalImportState,
          PrefetchHooks Function()
        > {
  $$ImportStatesTableTableManager(_$LocalDatabase db, $ImportStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<ImportStatus> status = const Value.absent(),
                Value<String?> targetEmail = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> importTag = const Value.absent(),
                Value<int?> defaultAccountServerId = const Value.absent(),
              }) => ImportStatesCompanion(
                id: id,
                status: status,
                targetEmail: targetEmail,
                startedAt: startedAt,
                lastError: lastError,
                importTag: importTag,
                defaultAccountServerId: defaultAccountServerId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required ImportStatus status,
                Value<String?> targetEmail = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> importTag = const Value.absent(),
                Value<int?> defaultAccountServerId = const Value.absent(),
              }) => ImportStatesCompanion.insert(
                id: id,
                status: status,
                targetEmail: targetEmail,
                startedAt: startedAt,
                lastError: lastError,
                importTag: importTag,
                defaultAccountServerId: defaultAccountServerId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportStatesTable, LocalImportState>(table),
                  BaseReferences<
                    _$LocalDatabase,
                    $ImportStatesTable,
                    LocalImportState
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $ImportStatesTable,
      LocalImportState,
      $$ImportStatesTableFilterComposer,
      $$ImportStatesTableOrderingComposer,
      $$ImportStatesTableAnnotationComposer,
      $$ImportStatesTableCreateCompanionBuilder,
      $$ImportStatesTableUpdateCompanionBuilder,
      (
        LocalImportState,
        BaseReferences<_$LocalDatabase, $ImportStatesTable, LocalImportState>,
      ),
      LocalImportState,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db, _db.currencies);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$ImportStatesTableTableManager get importStates =>
      $$ImportStatesTableTableManager(_db, _db.importStates);
}
