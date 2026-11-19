import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

const appVersion = '0.1';
const appCredits = '2026 Designed & Developed by Serg. Rosario OLIVERI Vers. $appVersion';

class Store extends ChangeNotifier {
  late Directory _dir;
  late File _file;

  List<Athlete> athletes = [];
  List<Result> results = [];
  List<Session> sessions = [];
  Club club = Club();
  List<Specialty> customSpecialties = [];
  List<String> customTypes = [];
  String? currentAthleteId;

  List<Specialty> get specialties => [...defaultSpecialties, ...customSpecialties];
  List<String> get trainingTypes => [...defaultTrainingTypes, ...customTypes];

  Specialty specialtyOf(String name) => specialties.firstWhere(
        (s) => s.name == name,
        orElse: () => Specialty(name, Kind.dist),
      );

  Athlete? get currentAthlete {
    if (athletes.isEmpty) return null;
    return athletes.firstWhere((a) => a.id == currentAthleteId,
        orElse: () => athletes.first);
  }

  Future<void> load() async {
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString('diario_atletica_data');
        if (raw != null && raw.isNotEmpty) {
          _fromJson(jsonDecode(raw));
        }
      } catch (e) {
        debugPrint('Errore lettura dati web: $e');
      }
      notifyListeners();
      return;
    }

    _dir = await getApplicationDocumentsDirectory();
    await Directory('${_dir.path}/images').create(recursive: true);
    _file = File('${_dir.path}/data.json');
    if (await _file.exists()) {
      try {
        _fromJson(jsonDecode(await _file.readAsString()));
      } catch (e) {
        debugPrint('Errore lettura dati: $e');
      }
    }
    notifyListeners();
  }

  Map<String, dynamic> _toJson() => {
        'version': appVersion,
        'athletes': athletes.map((a) => a.toJson()).toList(),
        'results': results.map((r) => r.toJson()).toList(),
        'sessions': sessions.map((s) => s.toJson()).toList(),
        'club': club.toJson(),
        'customSpecialties': customSpecialties.map((s) => s.toJson()).toList(),
        'customTypes': customTypes,
        'currentAthleteId': currentAthleteId,
      };

  List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) f) =>
      ((raw ?? []) as List).map((e) => f(Map<String, dynamic>.from(e))).toList();

  void _fromJson(Map<String, dynamic> j) {
    athletes = _list(j['athletes'], Athlete.fromJson);
    results = _list(j['results'], Result.fromJson);
    sessions = _list(j['sessions'], Session.fromJson);
    club = j['club'] == null
        ? Club()
        : Club.fromJson(Map<String, dynamic>.from(j['club']));
    customSpecialties = _list(j['customSpecialties'], Specialty.fromJson);
    customTypes = List<String>.from(j['customTypes'] ?? []);
    currentAthleteId = j['currentAthleteId'];
  }

  Future<void> save() async {
    final encoded = jsonEncode(_toJson());
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('diario_atletica_data', encoded);
      notifyListeners();
      return;
    }
    await _file.writeAsString(encoded);
    notifyListeners();
  }

  // ---- Atleti
  Future<void> upsertAthlete(Athlete a) async {
    final i = athletes.indexWhere((x) => x.id == a.id);
    if (i >= 0) {
      athletes[i] = a;
    } else {
      athletes.add(a);
    }
    currentAthleteId ??= a.id;
    athletes.sort((x, y) => x.fullName.compareTo(y.fullName));
    await save();
  }

  Future<void> deleteAthlete(String id) async {
    athletes.removeWhere((a) => a.id == id);
    results.removeWhere((r) => r.athleteId == id);
    sessions.removeWhere((s) => s.athleteId == id);
    if (currentAthleteId == id) currentAthleteId = null;
    await save();
  }

  Future<void> selectAthlete(String id) async {
    currentAthleteId = id;
    await save();
  }

  // ---- Gare
  Future<void> upsertResult(Result r) async {
    final i = results.indexWhere((x) => x.id == r.id);
    if (i >= 0) {
      results[i] = r;
    } else {
      results.add(r);
    }
    await save();
  }

  Future<void> deleteResult(String id) async {
    results.removeWhere((r) => r.id == id);
    await save();
  }

  // ---- Allenamenti
  Future<void> upsertSession(Session s) async {
    final i = sessions.indexWhere((x) => x.id == s.id);
    if (i >= 0) {
      sessions[i] = s;
    } else {
      sessions.add(s);
    }
    await save();
  }

  Future<void> deleteSession(String id) async {
    sessions.removeWhere((s) => s.id == id);
    await save();
  }

  Future<void> addSpecialty(Specialty s) async {
    if (specialties.any((x) => x.name.toLowerCase() == s.name.toLowerCase())) return;
    customSpecialties.add(s);
    await save();
  }

  Future<void> addTrainingType(String t) async {
    if (trainingTypes.any((x) => x.toLowerCase() == t.toLowerCase())) return;
    customTypes.add(t);
    await save();
  }

  Future<void> setClub(Club c) async {
    club = c;
    await save();
  }

  // ---- Immagini
  String imagePath(String name) => kIsWeb ? name : '${_dir.path}/images/$name';

  Future<String> importImage(XFile x) async {
    if (kIsWeb) return x.path;
    final ext = x.path.contains('.') ? x.path.split('.').last : 'jpg';
    final name = '${newId()}.$ext';
    await File(x.path).copy(imagePath(name));
    return name;
  }

  // ---- Export / Import
  Future<File> exportZip() async {
    if (kIsWeb) {
      throw Exception('Esportazione ZIP non disponibile nella versione Web.');
    }
    final a = Archive();
    final data = utf8.encode(jsonEncode(_toJson()));
    a.addFile(ArchiveFile('data.json', data.length, data));
    final imgDir = Directory('${_dir.path}/images');
    if (await imgDir.exists()) {
      for (final f in imgDir.listSync().whereType<File>()) {
        final bytes = await f.readAsBytes();
        final name = f.path.split(Platform.pathSeparator).last;
        a.addFile(ArchiveFile('images/$name', bytes.length, bytes));
      }
    }
    final out = ZipEncoder().encode(a)!;
    final now = DateTime.now();
    final stamp = '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}';
    final tmp = await getTemporaryDirectory();
    final file = File('${tmp.path}/diario_atletica_$stamp.zip');
    await file.writeAsBytes(out);
    return file;
  }

  /// replace = true: sostituisce tutto. false: unisce per id (l'importato vince).
  Future<void> importZip(String path, {required bool replace}) async {
    if (kIsWeb) {
      throw Exception('Importazione ZIP non disponibile nella versione Web.');
    }
    final archive = ZipDecoder().decodeBytes(await File(path).readAsBytes());
    Map<String, dynamic>? json;
    for (final f in archive) {
      if (!f.isFile) continue;
      final bytes = f.content as List<int>;
      if (f.name == 'data.json') {
        json = jsonDecode(utf8.decode(bytes));
      } else if (f.name.startsWith('images/')) {
        final name = f.name.substring('images/'.length);
        if (name.isEmpty || name.contains('..') || name.contains('/')) continue;
        await File(imagePath(name)).writeAsBytes(bytes);
      }
    }
    if (json == null) throw Exception('File non valido: data.json mancante');

    if (replace) {
      _fromJson(json);
    } else {
      final other = Store();
      other._fromJson(json);
      athletes = _merge(athletes, other.athletes, (a) => a.id);
      results = _merge(results, other.results, (r) => r.id);
      sessions = _merge(sessions, other.sessions, (s) => s.id);
      for (final s in other.customSpecialties) {
        if (!specialties.any((x) => x.name == s.name)) customSpecialties.add(s);
      }
      for (final t in other.customTypes) {
        if (!trainingTypes.contains(t)) customTypes.add(t);
      }
      if (club.nome.isEmpty) club = other.club;
      athletes.sort((x, y) => x.fullName.compareTo(y.fullName));
    }
    await save();
  }

  List<T> _merge<T>(List<T> mine, List<T> theirs, String Function(T) id) {
    final map = {for (final x in mine) id(x): x};
    for (final x in theirs) {
      map[id(x)] = x;
    }
    return map.values.toList();
  }
}

final store = Store();
