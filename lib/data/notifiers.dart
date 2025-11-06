//Value notfiers for managing state in the application : hold the data
//ValueListenableBuilder is used to listen to changes in the value notifiers: listen to the data (dont need to use setState)

import 'package:flutter/material.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(4);
