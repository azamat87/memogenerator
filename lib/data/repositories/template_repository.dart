
import 'dart:convert';
import 'package:memogenerator/data/models/template.dart';
import 'package:memogenerator/data/shared_preference_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

class TemplatesRepository {
  final update = PublishSubject<Null>();
  final SharedPreferenceData spData;

  static TemplatesRepository? _instance;

  factory TemplatesRepository.getInstance() =>
      _instance ??
          TemplatesRepository._internal(SharedPreferenceData.getInstance());

  TemplatesRepository._internal(this.spData);

  Future<bool> addToTemplates(final Template newTemplate) async {
    final templates = await getTemplates();
    final templateIndex = templates.indexWhere((element) => newTemplate.id == element.id);
    if (templateIndex == -1) {
      templates.add(newTemplate);
    } else {
      templates.removeAt(templateIndex);
      templates.insert(templateIndex, newTemplate);
    }
    return _setTemplates(templates);
  }

  Future<bool> removeFromTemplates(final String id) async {
    final templates = await getTemplates();
    templates.removeWhere((element) => element.id == id);

    return _setTemplates(templates);
  }

  Future<Template?> getTemplate(final String id) async {
    final templates = await getTemplates();

    return templates.firstWhereOrNull((template) => template.id == id);
  }

  Future<List<Template>> getTemplates() async {
    final rawTemplates = await spData.getTemplates();
    return rawTemplates
        .map((rawTemplate) => Template.fromJson(json.decode(rawTemplate)))
        .toList();
  }

  Stream<List<Template>> observeTemplates() async* {
    yield await getTemplates();
    await for (final _ in update) {
      yield await getTemplates();
    }
  }

  Future<bool> _setTemplates(final List<Template> templates) async {
    final rawTemplates = templates.map((e) => json.encode(e.toJson())).toList();
    return _setRawTemplates(rawTemplates);
  }

  Future<bool> _setRawTemplates(List<String> rawTemplates) async {
    update.add(null);
    return spData.setTemplates(rawTemplates);
  }

  Future<List<String>> _getRawTemplates() async {
    return spData.getTemplates();
  }
}
