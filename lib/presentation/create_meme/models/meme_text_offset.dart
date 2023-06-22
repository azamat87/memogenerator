
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text.dart';

class MemeTextOffset extends Equatable {

  final String id;
  final Offset offset;

  MemeTextOffset({required this.id, required this.offset});

  @override
  List<Object?> get props => [id, offset];
}