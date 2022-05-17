import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'pdf_search_status.dart';

class PdfSearchStatusCubit extends Cubit<PdfSearchStatus> {
  PdfSearchStatusCubit() : super(Loading());

  void readyToSearch() => emit(Initial());

  void cancelSearch() => emit(Initial());

  void searchInProgress() => emit(InProgress());

  void searchComplete() => emit(Complete());
}
