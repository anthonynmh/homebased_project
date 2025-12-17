import 'package:homebased_project/mvp2/menu/menu_data/menu_item_model.dart';
import 'package:image_picker/image_picker.dart';

class MenuItemFormResult {
  final MenuItem item;
  final XFile? photo;

  MenuItemFormResult({required this.item, this.photo});
}
