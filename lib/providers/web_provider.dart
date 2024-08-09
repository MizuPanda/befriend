import 'package:flutter/cupertino.dart';

class WebProvider extends ChangeNotifier {
  final FocusNode _focusNode = FocusNode();

  String? _searchTerm;

  String? get searchTerm => _searchTerm;

  FocusNode get focusNode => _focusNode;

  void unfocus() {
    _focusNode.unfocus();
    notifyListeners();
  }

  void toDispose() {
    _focusNode.dispose();
  }

  void onSubmitted(String? value) {
    notifyListeners();
  }

  void onChanged(String? value) {
    _searchTerm = value;
    if (_searchTerm == null || (_searchTerm?.isEmpty ?? false)) {
      notifyListeners();
    }
  }
}
