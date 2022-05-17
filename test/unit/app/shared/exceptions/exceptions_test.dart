import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_open_access/app/features/search/cubit/search_cubit.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

void main() {
  test(
      'InvalidStateException has invalidState set to name of object passed to exception',
      () {
    SearchState _searchState = SearchInProgress();
    InvalidStateException _exception = InvalidStateException(_searchState);
    expect(_exception, isA<InvalidStateException>());
    expect(_exception.invalidState, 'SearchInProgress()');
  });
}
