
import 'package:flutter/material.dart';


class RotatingMenuItem extends StatefulWidget {
  final int initialIndex;
  final Function(int) onIndexUpdated;
  final List<String> textOptions;

  const RotatingMenuItem({
    super.key,
    required this.initialIndex,
    required this.onIndexUpdated,
    required this.textOptions,
  });

  @override
  State<RotatingMenuItem> createState() => _RotatingMenuItemState();
}

class _RotatingMenuItemState extends State<RotatingMenuItem> {
   late int index;

  @override
  void initState() {
    index = widget.initialIndex;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.textOptions[index]),
      onTap: () {
        setState(() => index = rotateIndex(index));
        widget.onIndexUpdated(index);
      },
    );
  }

  int rotateIndex(int index){
    var newIndex = index + 1;
    if (newIndex == widget.textOptions.length){
      newIndex = 0;
    } 
    return newIndex;
  }
}


int filterToIndex(bool? filter){
  if (filter == null) return 0;
  if (filter == true) return 1;
  return 2;
}

bool? indexToFilter(int index){
  return [null, true, false][index];
}
