part of 'pdf_search_status_cubit.dart';

abstract class PdfSearchStatus extends Equatable {
  const PdfSearchStatus();

  @override
  List<Object> get props => [];
}

class Loading extends PdfSearchStatus {}

class Initial extends PdfSearchStatus {}

class InProgress extends PdfSearchStatus {}

class Complete extends PdfSearchStatus {}
