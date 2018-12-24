import 'package:scoped_model/scoped_model.dart';

enum SectionFocus { favorites, all, balanced }

class SectionFocusModel extends Model {
  SectionFocus _focus = SectionFocus.balanced;
  SectionFocus _lastFocus = SectionFocus.balanced;

  SectionFocus get focus => _focus;
  SectionFocus get lastFocus => _lastFocus;
  void changeFocus(SectionFocus newFocus){
    _lastFocus = _focus;
    if(newFocus == _focus){
      _focus = SectionFocus.balanced;
    } else {
      _focus = newFocus;
    }
    notifyListeners();
  }
}