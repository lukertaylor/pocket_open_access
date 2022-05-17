part of 'pdf_load_cubit.dart';

abstract class PdfLoadState extends Equatable {
  const PdfLoadState();

  @override
  List<Object> get props => [];
}

class PdfLoadInitial extends PdfLoadState {}

class PdfLoadSuccess extends PdfLoadState {
  final Uint8List pdf;

  const PdfLoadSuccess(this.pdf);
}

class PdfLoadFailed extends PdfLoadState {}
