import 'package:bloc/bloc.dart';

class AdvancedSearchCubit extends Cubit<bool> {
  AdvancedSearchCubit() : super(false);

  void switchToAdvancedSearch() => emit(true);

  void switchToSimpleSearch() => emit(false);
}
