import 'dart:async';
import 'dart:convert';
import 'package:islamia/data/models/calendar/daily_reminder.dart';
import 'package:islamia/data/models/calendar/hijri_date.dart';
import 'package:islamia/data/models/calendar/islamic_event.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class CalendarDatabase {
  static final CalendarDatabase _instance = CalendarDatabase._internal();
  factory CalendarDatabase() => _instance;
  CalendarDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'islamic_calendar.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Islamic Events table
    await db.execute('''
      CREATE TABLE islamic_events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        title_arabic TEXT NOT NULL,
        description TEXT NOT NULL,
        description_arabic TEXT NOT NULL,
        gregorian_date TEXT NOT NULL,
        hijri_date TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        is_recurring INTEGER DEFAULT 0,
        recurrence_type TEXT,
        duration INTEGER,
        image_url TEXT,
        significances TEXT,
        practices TEXT,
        has_notification INTEGER DEFAULT 0,
        notification_time TEXT,
        source TEXT,
        is_user_created INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        metadata TEXT
      )
    ''');

    // Daily Reminders table
    await db.execute('''
      CREATE TABLE daily_reminders (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        hijri_date TEXT NOT NULL,
        quran_verse TEXT NOT NULL,
        quran_verse_arabic TEXT NOT NULL,
        translation TEXT NOT NULL,
        hadith TEXT NOT NULL,
        hadith_arabic TEXT NOT NULL,
        hadith_source TEXT NOT NULL,
        islamic_quote TEXT NOT NULL,
        islamic_quote_arabic TEXT NOT NULL,
        author TEXT NOT NULL,
        daily_practices TEXT,
        supplications TEXT,
        moon_phase_info TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Moon Phases table
    await db.execute('''
      CREATE TABLE moon_phases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        phase TEXT NOT NULL,
        illumination REAL NOT NULL,
        age INTEGER NOT NULL,
        phase_name TEXT NOT NULL,
        phase_name_arabic TEXT NOT NULL,
        description TEXT NOT NULL,
        UNIQUE(date)
      )
    ''');

    // Hijri Date Cache table
    await db.execute('''
      CREATE TABLE hijri_date_cache (
        gregorian_date TEXT PRIMARY KEY,
        day INTEGER NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        month_name TEXT NOT NULL,
        month_name_arabic TEXT NOT NULL,
        day_name TEXT NOT NULL,
        day_name_arabic TEXT NOT NULL,
        is_leap_year INTEGER DEFAULT 0,
        week_day INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Islamic Month Information table
    await db.execute('''
      CREATE TABLE islamic_months (
        month_number INTEGER PRIMARY KEY,
        name_english TEXT NOT NULL,
        name_arabic TEXT NOT NULL,
        significance TEXT NOT NULL,
        significance_arabic TEXT NOT NULL,
        special_days TEXT,
        practices TEXT,
        historical_events TEXT
      )
    ''');

    // User Custom Events table
    await db.execute('''
      CREATE TABLE user_events (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        gregorian_date TEXT NOT NULL,
        hijri_date TEXT,
        event_type TEXT NOT NULL,
        color TEXT DEFAULT '#2196F3',
        has_notification INTEGER DEFAULT 0,
        notification_time TEXT,
        is_recurring INTEGER DEFAULT 0,
        recurrence_type TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');

    // Create indexes
    await db.execute(
      'CREATE INDEX idx_events_date ON islamic_events (gregorian_date)',
    );
    await db.execute(
      'CREATE INDEX idx_events_category ON islamic_events (category)',
    );
    await db.execute('CREATE INDEX idx_events_type ON islamic_events (type)');
    await db.execute(
      'CREATE INDEX idx_reminders_date ON daily_reminders (date)',
    );
    await db.execute('CREATE INDEX idx_moon_phases_date ON moon_phases (date)');
    await db.execute(
      'CREATE INDEX idx_user_events_date ON user_events (gregorian_date)',
    );
    await db.execute(
      'CREATE INDEX idx_user_events_user ON user_events (user_id)',
    );

    // Insert default Islamic months data
    await _insertDefaultIslamicMonths(db);

    // Insert default Islamic events
    await _insertDefaultIslamicEvents(db);
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database upgrades
  }

  // Insert default Islamic months information
  Future<void> _insertDefaultIslamicMonths(Database db) async {
    final months = [
      {
        'month_number': 1,
        'name_english': 'Muharram',
        'name_arabic': 'مُحَرَّم',
        'significance':
            'The first month of Islamic calendar, one of the four sacred months',
        'significance_arabic':
            'الشهر الأول من التقويم الإسلامي، وهو من الأشهر الحرم الأربعة',
        'special_days': jsonEncode([
          'Day of Ashura (10th)',
          'Day of Arafa for those not on Hajj',
        ]),
        'practices': jsonEncode([
          'Fasting on 9th, 10th, 11th',
          'Increased worship',
          'Charity',
        ]),
        'historical_events': jsonEncode([
          'Battle of Karbala',
          'Migration to Medina',
        ]),
      },
      {
        'month_number': 2,
        'name_english': 'Safar',
        'name_arabic': 'صَفَر',
        'significance': 'The second month of Islamic calendar',
        'significance_arabic': 'الشهر الثاني من التقويم الإسلامي',
        'special_days': jsonEncode([]),
        'practices': jsonEncode(['Regular worship', 'Seeking knowledge']),
        'historical_events': jsonEncode(['Various battles and expeditions']),
      },
      {
        'month_number': 3,
        'name_english': 'Rabi\' al-Awwal',
        'name_arabic': 'رَبِيع الأَوَّل',
        'significance': 'Birth month of Prophet Muhammad (PBUH)',
        'significance_arabic': 'شهر مولد النبي محمد صلى الله عليه وسلم',
        'special_days': jsonEncode(['Mawlid an-Nabi (12th)']),
        'practices': jsonEncode([
          'Reciting Seerah',
          'Sending Salawat',
          'Charity',
        ]),
        'historical_events': jsonEncode([
          'Birth of Prophet Muhammad',
          'Migration to Medina',
        ]),
      },
      {
        'month_number': 4,
        'name_english': 'Rabi\' al-Thani',
        'name_arabic': 'رَبِيع الثَّانِي',
        'significance': 'The fourth month of Islamic calendar',
        'significance_arabic': 'الشهر الرابع من التقويم الإسلامي',
        'special_days': jsonEncode([]),
        'practices': jsonEncode(['Regular worship', 'Quran recitation']),
        'historical_events': jsonEncode(['Various Islamic historical events']),
      },
      {
        'month_number': 5,
        'name_english': 'Jumada al-Awwal',
        'name_arabic': 'جُمَادَى الأُولَى',
        'significance': 'The fifth month of Islamic calendar',
        'significance_arabic': 'الشهر الخامس من التقويم الإسلامي',
        'special_days': jsonEncode([]),
        'practices': jsonEncode(['Regular worship', 'Seeking forgiveness']),
        'historical_events': jsonEncode(['Battle of Mutah']),
      },
      {
        'month_number': 6,
        'name_english': 'Jumada al-Thani',
        'name_arabic': 'جُمَادَى الثَّانِيَة',
        'significance': 'The sixth month of Islamic calendar',
        'significance_arabic': 'الشهر السادس من التقويم الإسلامي',
        'special_days': jsonEncode([]),
        'practices': jsonEncode(['Regular worship', 'Charity']),
        'historical_events': jsonEncode(['Death of Fatimah (RA)']),
      },
      {
        'month_number': 7,
        'name_english': 'Rajab',
        'name_arabic': 'رَجَب',
        'significance': 'One of the four sacred months',
        'significance_arabic': 'من الأشهر الحرم الأربعة',
        'special_days': jsonEncode(['Isra and Mi\'raj (27th)']),
        'practices': jsonEncode([
          'Increased fasting',
          'Night prayers',
          'Seeking forgiveness',
        ]),
        'historical_events': jsonEncode([
          'Isra and Mi\'raj',
          'Various expeditions',
        ]),
      },
      {
        'month_number': 8,
        'name_english': 'Sha\'ban',
        'name_arabic': 'شَعْبَان',
        'significance': 'The month before Ramadan',
        'significance_arabic': 'الشهر الذي يسبق رمضان',
        'special_days': jsonEncode(['Laylat al-Bara\'at (15th)']),
        'practices': jsonEncode([
          'Preparation for Ramadan',
          'Increased fasting',
          'Seeking forgiveness',
        ]),
        'historical_events': jsonEncode(['Change of Qibla direction']),
      },
      {
        'month_number': 9,
        'name_english': 'Ramadan',
        'name_arabic': 'رَمَضَان',
        'significance': 'The holy month of fasting',
        'significance_arabic': 'الشهر المقدس للصيام',
        'special_days': jsonEncode([
          'Laylat al-Qadr',
          'First 10 days',
          'Last 10 days',
        ]),
        'practices': jsonEncode([
          'Fasting',
          'Tarawih prayers',
          'Quran recitation',
          'Charity',
          'I\'tikaf',
        ]),
        'historical_events': jsonEncode([
          'Revelation of Quran',
          'Battle of Badr',
          'Conquest of Mecca',
        ]),
      },
      {
        'month_number': 10,
        'name_english': 'Shawwal',
        'name_arabic': 'شَوَّال',
        'significance': 'Month containing Eid al-Fitr',
        'significance_arabic': 'شهر عيد الفطر',
        'special_days': jsonEncode(['Eid al-Fitr (1st)']),
        'practices': jsonEncode([
          'Eid celebrations',
          'Six days of Shawwal fasting',
          'Charity',
        ]),
        'historical_events': jsonEncode(['Various battles and events']),
      },
      {
        'month_number': 11,
        'name_english': 'Dhu al-Qi\'dah',
        'name_arabic': 'ذُو القِعْدَة',
        'significance': 'One of the four sacred months',
        'significance_arabic': 'من الأشهر الحرم الأربعة',
        'special_days': jsonEncode([]),
        'practices': jsonEncode(['Preparation for Hajj', 'Increased worship']),
        'historical_events': jsonEncode(['Treaty of Hudaybiyyah']),
      },
      {
        'month_number': 12,
        'name_english': 'Dhu al-Hijjah',
        'name_arabic': 'ذُو الحِجَّة',
        'significance': 'The month of Hajj pilgrimage',
        'significance_arabic': 'شهر الحج',
        'special_days': jsonEncode([
          'Day of Arafa (9th)',
          'Eid al-Adha (10th)',
          'Days of Tashreeq (11-13th)',
        ]),
        'practices': jsonEncode([
          'Hajj pilgrimage',
          'Fasting first 9 days',
          'Qurbani',
          'Takbir',
        ]),
        'historical_events': jsonEncode([
          'Farewell Hajj of Prophet',
          'Farewell Sermon',
        ]),
      },
    ];

    for (final month in months) {
      await db.insert('islamic_months', month);
    }
  }

Future<void> _insertDefaultIslamicEvents(Database db) async {
    final events = [
      // Major Islamic Events
      {
        'id': 'muharram_01',
        'title': 'Islamic New Year',
        'title_arabic': 'رأس السنة الهجرية',
        'description': 'The beginning of the Islamic calendar year, marking the Hijra (migration) of Prophet Muhammad from Mecca to Medina.',
        'description_arabic': 'بداية السنة الإسلامية، تحتفل بذكرى الهجرة النبوية من مكة إلى المدينة.',
        'gregorian_date': DateTime.now().year.toString() + '-07-19', // Approximate, will be calculated
        'hijri_date': jsonEncode({'day': 1, 'month': 1, 'year': 1445}),
        'type': 'religious',
        'category': 'islamic_months',
        'is_recurring': 1,
        'recurrence_type': 'hijri_yearly',
        'duration': 1,
        'significances': jsonEncode(['Marks the beginning of Islamic calendar', 'Commemorates the Hijra', 'Time for reflection and renewal']),
        'practices': jsonEncode(['Recitation of Quran', 'Reflection on the Hijra', 'Seeking Allah\'s guidance']),
        'has_notification': 1,
        'source': 'Islamic Calendar',
        'is_user_created': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'metadata': jsonEncode({'color': '#4CAF50', 'icon': 'calendar'})
      },
      {
        'id': 'muharram_10',
        'title': 'Day of Ashura',
        'title_arabic': 'يوم عاشوراء',
        'description': 'The 10th day of Muharram, a day of fasting and remembrance. Allah saved Moses and the Israelites from Pharaoh on this day.',
        'description_arabic': 'اليوم العاشر من محرم، يوم صيام وذكرى. نجى الله موسى وبني إسرائيل من فرعون في هذا اليوم.',
        'gregorian_date': DateTime.now().year.toString() + '-07-28',
        'hijri_date': jsonEncode({'day': 10, 'month': 1, 'year': 1445}),
        'type': 'religious',
        'category': 'sunnah_days',
        'is_recurring': 1,
        'recurrence_type': 'hijri_yearly',
        'duration': 1,
        'significances': jsonEncode(['Day Moses was saved from Pharaoh', 'Recommended fasting day', 'Day of remembrance and reflection']),
        'practices': jsonEncode(['Fasting', 'Extra prayers', 'Charity', 'Reading Quran']),
        'has_notification': 1,
        'source': 'Hadith and Islamic tradition',
        'is_user_created': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'metadata': jsonEncode({'color': '#FF9800', 'icon': 'star'})
      },
      {
        'id': 'rabi_awwal_12',
        'title': 'Mawlid an-Nabi',
        'title_arabic': 'المولد النبوي',
        'description': 'The birth anniversary of Prophet Muhammad (peace be upon him), celebrated by Muslims worldwide.',
        'description_arabic': 'ذكرى مولد النبي محمد صلى الله عليه وسلم، يحتفل بها المسلمون في جميع أنحاء العالم.',
        'gregorian_date': DateTime.now().year.toString() + '-09-27',
        'hijri_date': jsonEncode({'day': 12, 'month': 3, 'year': 1445}),
        'type': 'religious',
        'category': 'prophet',
        'is_recurring': 1,
        'recurrence_type': 'hijri_yearly',
        'duration': 1,
        'significances': jsonEncode(['Birth of Prophet Muhammad', 'Celebration of prophetic guidance', 'Reminder of Islamic values']),
        'practices': jsonEncode(['Reciting Seerah', 'Sending Salawat on Prophet', 'Charity', 'Community gatherings']),
        'has_notification': 1,
        'source': 'Islamic tradition',
        'is_user_created': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'metadata': jsonEncode({'color': '#2196F3', 'icon': 'mosque'})
      },
      {
        'id': 'rajab_27',
        'title': 'Isra and Mi\'raj',
        'title_arabic': 'الإسراء والمعراج',
        'description': 'The night journey of Prophet Muhammad from Mecca to Jerusalem and his ascension to heaven.',
        'description_arabic': 'رحلة النبي محمد الليلية من مكة إلى القدس وعروجه إلى السماء.',
        'gregorian_date': DateTime.now().year.toString() + '-02-08',
        'hijri_date': jsonEncode({'day': 27, 'month': 7, 'year': 1445}),
        'type': 'religious',
        'category': 'prophet',
        'is_recurring': 1,
        'recurrence_type': 'hijri_yearly',
        'duration': 1,
        'significances': jsonEncode(['Night journey to Jerusalem', 'Ascension to heaven', 'Institution of five daily prayers']),
        'practices': jsonEncode(['Night prayers', 'Recitation of Quran', 'Dhikr and reflection']),
        'has_notification': 1,
        'source': 'Quran and Hadith',
        'is_user_created': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'metadata': jsonEncode({'color': '#9C27B0', 'icon': 'nights_stay'})
      },
      {
        'id': 'shaban_15',
        'title': 'Laylat al-Bara\'at',
        'title_arabic': 'ليلة البراءة',
        'description': 'The Night of Forgiveness, observed on the 15th night of Sha\'ban with prayers and seeking forgiveness.',
        'description_arabic': 'ليلة المغفرة، تُحيا في الليلة الخامسة عشرة من شعبان بالصلاة وطلب المغفرة.',
        'gregorian_date': DateTime.now().year.toString() + '-02-25',
        'hijri_date': jsonEncode({'day': 15, 'month': 8, 'year': 1445}),
        'type': 'religious',
        'category': 'sunnah_days',
        'is_recurring': 1,
        'recurrence_type': 'hijri_yearly',
        'duration': 1,
        'significances': jsonEncode(['Night of forgiveness', 'Preparation for Ramadan', 'Special mercy from Allah']),
        'practices': jsonEncode(['Night prayers', 'Seeking forgiveness', 'Fasting next day', 'Visiting graves']),
        'has_notification': 1,
        'source': 'Islamic tradition',
        'is_user_created': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'metadata': jsonEncode({'color': '#607D8B', 'icon': 'brightness_3'})
      },
      {
        'id': 'ramadan_start',
        'title': 'Start of Ramadan',
        'title_arabic': 'بداية رمضان',
        'description': 'The beginning of the holy month of fasting, prayer, reflection, and community for Muslims worldwide.',
        'description_arabic': 'بداية الشهر المقدس للصيام والصلاة والتفكر والمجتمع للمسلمين في جميع أنحاء العالم.',
        'gregorian_date': DateTime.now().year.toString() + '-03-11',
        'hijri_date': jsonEncode({'day': 1, 'month': 9, 'year': 1445}),
        'type': 'religious',
        'category': 'ramadan',
        'is_recurring': 1,
        'recurrence_type': 'hijri_yearly',
        'duration': 30,
        'significances': jsonEncode(['Holy month of fasting', 'Month of Quran revelation', 'Spiritual purification']),
        'practices': jsonEncode(['Daily fasting', 'Tarawih prayers', 'Increased Quran recitation', 'Charity (Zakat)']),
        'has_notification': 1,
        'source': 'Quran and Sunnah',
        'is_user_created': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'metadata': jsonEncode({'color': '#4CAF50', 'icon': 'crescent_moon'})
      },
      {
        'id': 'eid_fitr',
        'title': 'Eid al-Fitr',
        'title_arabic': 'عيد الفطر',
        'description': 'The festival of breaking the fast, celebrated at the end of Ramadan with prayers, feasting, and charity.',
        'description_arabic': 'عيد الفطر، يُحتفل به في نهاية رمضان بالصلاة والطعام والصدقة.',
        'gregorian_date': DateTime.now().year.toString() + '-04-10',
        'hijri_date': jsonEncode({'day': 1, 'month': 10, 'year': 1445}),
        'type': 'religious',
        'category': 'eid',
        'is_recurring': 1,
        'recurrence_type': 'hijri_yearly',
        'duration': 3,
        'significances': jsonEncode(['End of Ramadan fasting', 'Celebration of spiritual achievement', 'Community unity']),
        'practices': jsonEncode(['Eid prayers', 'Zakat al-Fitr', 'Family gatherings', 'Gift giving', 'Feasting']),
        'has_notification': 1,
        'source': 'Islamic tradition',
        'is_user_created': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'metadata': jsonEncode({'color': '#FF5722', 'icon': 'celebration'})
      },
      {
        'id': 'hajj_arafat',
        'title': 'Day of Arafat',
        'title_arabic': 'يوم عرفة',
        'description': 'The most important day of Hajj pilgrimage, observed with fasting by non-pilgrims and standing at Arafat by pilgrims.',
        'description_arabic': 'أهم يوم في الحج، يُحتفل به بالصيام لغير الحجاج والوقوف بعرفة للحجاج.',
        'gregorian_date': DateTime.now().year.toString() + '-06-27',
        'hijri_date': jsonEncode({'day': 9, 'month': 12, 'year': 1444}),
        'type': 'religious',
        'category': 'hajj',
        'is_recurring': 1,
        'recurrence_type': 'hijri_yearly',
        'duration': 1,
        'significances': jsonEncode(['Most important day of Hajj', 'Day of forgiveness', 'Completion of religion']),
        'practices': jsonEncode(['Fasting (for non-pilgrims)', 'Standing at Arafat (pilgrims)', 'Dua and supplication']),
        'has_notification': 1,
        'source': 'Quran and Hadith',
        'is_user_created': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'metadata': jsonEncode({'color': '#795548', 'icon': 'terrain'})
      },
      {
        'id': 'eid_adha',
        'title': 'Eid al-Adha',
        'title_arabic': 'عيد الأضحى',
        'description': 'The Festival of Sacrifice, commemorating Ibrahim\'s willingness to sacrifice his son for Allah.',
        'description_arabic': 'عيد الأضحى، إحياء لذكرى استعداد إبراهيم للتضحية بابنه لله.',
        'gregorian_date': DateTime.now().year.toString() + '-06-28',
        'hijri_date': jsonEncode({'day': 10, 'month': 12, 'year': 1444}),
        'type': 'religious',
        'category': 'eid',
        'is_recurring': 1,
        'recurrence_type': 'hijri_yearly',
        'duration': 4,
        'significances': jsonEncode(['Commemoration of Ibrahim sacrifice', 'End of Hajj pilgrimage', 'Ultimate submission to Allah']),
        'practices': jsonEncode(['Eid prayers', 'Animal sacrifice (Qurbani)', 'Distribution of meat', 'Family gatherings']),
        'has_notification': 1,
        'source': 'Quran and Islamic tradition',
        'is_user_created': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'metadata': jsonEncode({'color': '#E91E63', 'icon': 'celebration'})
      }
    ];

    for (final event in events) {
      await db.insert('islamic_events', event);
    }
  }

  // CRUD Operations for Islamic Events
  Future<void> insertEvent(IslamicEvent event) async {
    final db = await database;
    await db.insert(
      'islamic_events',
      event.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertEvents(List<IslamicEvent> events) async {
    final db = await database;
    final batch = db.batch();
    
    for (final event in events) {
      batch.insert(
        'islamic_events',
        event.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  Future<IslamicEvent?> getEventById(String id) async {
    final db = await database;
    final results = await db.query(
      'islamic_events',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return IslamicEvent.fromJson(results.first);
    }
    return null;
  }

  Future<List<IslamicEvent>> getEventsByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final results = await db.query(
      'islamic_events',
      where: 'date(gregorian_date) = ?',
      whereArgs: [dateStr],
      orderBy: 'title ASC',
    );

    return results.map((map) => IslamicEvent.fromJson(map)).toList();
  }

  Future<List<IslamicEvent>> getEventsByMonth(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    
    final results = await db.query(
      'islamic_events',
      where: 'gregorian_date BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0]
      ],
      orderBy: 'gregorian_date ASC',
    );

    return results.map((map) => IslamicEvent.fromJson(map)).toList();
  }

  Future<List<IslamicEvent>> getEventsByCategory(IslamicEventCategory category) async {
    final db = await database;
    final results = await db.query(
      'islamic_events',
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'gregorian_date ASC',
    );

    return results.map((map) => IslamicEvent.fromJson(map)).toList();
  }

  Future<List<IslamicEvent>> searchEvents(String query) async {
    final db = await database;
    final results = await db.query(
      'islamic_events',
      where: 'title LIKE ? OR description LIKE ? OR title_arabic LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'title ASC',
    );

    return results.map((map) => IslamicEvent.fromJson(map)).toList();
  }

  Future<void> updateEvent(IslamicEvent event) async {
    final db = await database;
    await db.update(
      'islamic_events',
      event.toJson(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<void> deleteEvent(String id) async {
    final db = await database;
    await db.delete(
      'islamic_events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hijri Date Cache Operations
  Future<void> cacheHijriDate(DateTime gregorianDate, HijriDate hijriDate) async {
    final db = await database;
    final dateStr = gregorianDate.toIso8601String().split('T')[0];
    
    await db.insert(
      'hijri_date_cache',
      {
        'gregorian_date': dateStr,
        ...hijriDate.toSQLiteMap(),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<HijriDate?> getCachedHijriDate(DateTime gregorianDate) async {
    final db = await database;
    final dateStr = gregorianDate.toIso8601String().split('T')[0];
    
    final results = await db.query(
      'hijri_date_cache',
      where: 'gregorian_date = ?',
      whereArgs: [dateStr],
    );

    if (results.isNotEmpty) {
      return HijriDate.fromSQLiteMap(results.first);
    }
    return null;
  }

  // Daily Reminders Operations
  Future<void> insertDailyReminder(DailyReminder reminder) async {
    final db = await database;
    await db.insert(
      'daily_reminders',
      reminder.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DailyReminder?> getDailyReminder(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final results = await db.query(
      'daily_reminders',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (results.isNotEmpty) {
      return DailyReminder.fromJson(results.first);
    }
    return null;
  }

  // Moon Phase Operations
  Future<void> insertMoonPhase(MoonPhase moonPhase) async {
    final db = await database;
    await db.insert(
      'moon_phases',
      moonPhase.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MoonPhase?> getMoonPhase(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final results = await db.query(
      'moon_phases',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (results.isNotEmpty) {
      return MoonPhase.fromJson(results.first);
    }
    return null;
  }

  // Islamic Month Information
  Future<Map<String, dynamic>?> getIslamicMonthInfo(int monthNumber) async {
    final db = await database;
    final results = await db.query(
      'islamic_months',
      where: 'month_number = ?',
      whereArgs: [monthNumber],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllIslamicMonths() async {
    final db = await database;
    return await db.query(
      'islamic_months',
      orderBy: 'month_number ASC',
    );
  }

  // User Custom Events Operations
  Future<void> insertUserEvent(Map<String, dynamic> event) async {
    final db = await database;
    await db.insert(
      'user_events',
      event,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUserEvents(String userId) async {
    final db = await database;
    return await db.query(
      'user_events',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'gregorian_date ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getUserEventsByDate(String userId, DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    return await db.query(
      'user_events',
      where: 'user_id = ? AND date(gregorian_date) = ?',
      whereArgs: [userId, dateStr],
      orderBy: 'title ASC',
    );
  }

  Future<void> updateUserEvent(String eventId, Map<String, dynamic> event) async {
    final db = await database;
    await db.update(
      'user_events',
      event,
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  Future<void> deleteUserEvent(String eventId) async {
    final db = await database;
    await db.delete(
      'user_events',
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  // Cleanup old cache data
  Future<void> cleanupOldCache() async {
    final db = await database;
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    
    await db.delete(
      'hijri_date_cache',
      where: 'created_at < ?',
      whereArgs: [thirtyDaysAgo.millisecondsSinceEpoch],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }




}
