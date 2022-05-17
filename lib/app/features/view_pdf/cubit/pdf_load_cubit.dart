import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../shared/common_imports/common_imports_barrel.dart';

part 'pdf_load_state.dart';

/// Holds the status of loading the article PDF.
class PdfLoadStatusCubit extends Cubit<PdfLoadState> {
  PdfLoadStatusCubit(
      {Future<Uint8List?> Function({required Article article})?
          getArticlePdfFunc})
      : super(PdfLoadInitial()) {
    _getArticlePdf = getArticlePdfFunc ?? articlePdf;
  }

  late final Future<Uint8List?> Function({required Article article})
      _getArticlePdf;

  Future<void> loadPdf({required Article article}) async {
    final pdf = await _getArticlePdf(article: article);
    if (pdf != null) {
      emit(PdfLoadSuccess(pdf));
    } else {
      emit(PdfLoadFailed());
    }
  }

  void loadFailed() {
    emit(PdfLoadFailed());
  }
}
