
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:memogenerator/data/models/text_with_position.dart';

part 'meme.g.dart';

@JsonSerializable()
class Meme extends Equatable{
  final String id;
  final String? memePath;
  final List<TextWithPosition> texts;

  Meme({required this.id, required this.texts, this.memePath});

  factory Meme.fromJson(Map<String, dynamic> json) => _$MemeFromJson(json);

  Map<String, dynamic> toJson() => _$MemeToJson(this);

  @override
  List<Object?> get props => [id, texts, memePath];

}