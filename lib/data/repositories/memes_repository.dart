import 'dart:convert';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/repositories/list_with_ids_reactive_repository.dart';
import 'package:memogenerator/data/shared_preference_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

class MemesRepository extends ListWithIdsReactiveRepository<Meme>{
  final update = PublishSubject<Null>();
  final SharedPreferenceData spData;

  static MemesRepository? _instance;

  factory MemesRepository.getInstance() =>
      _instance ??
      MemesRepository._internal(SharedPreferenceData.getInstance());

  MemesRepository._internal(this.spData);

  @override
  Meme convertFromString(String rawItem) {
    return Meme.fromJson(json.decode(rawItem));
  }

  @override
  String convertToString(Meme item) {
    return json.encode(item.toJson());
  }

  @override
  dynamic getId(Meme item) {
    return item.id;
  }

  @override
  Future<List<String>> getRawData() {
    return spData.getMemes();
  }

  @override
  Future<bool> saveRawData(List<String> items) {
    return spData.setMemes(items);
  }

}
