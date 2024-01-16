import 'package:flutter/cupertino.dart';

import 'category_tile_widget.dart';
import 'loading_list_item_widget.dart';

class PersonalDeckListWidget extends StatelessWidget {
  final Future<List<CategoryTileWidget>> Function() fetchLocalDecks;

  PersonalDeckListWidget({Key? key, required this.fetchLocalDecks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryTileWidget>>(
      future: fetchLocalDecks(),
      builder: (BuildContext context, AsyncSnapshot<List<CategoryTileWidget>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, i) => LoadingListItemWidget(),
            itemCount: 8,
            separatorBuilder: (BuildContext context, int index) => SizedBox(height: 8),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Data has Error. ${snapshot.error.toString()}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available.'));
        } else {
          final reversedData = snapshot.data?.reversed.toList();
          return ListView.builder(
            itemCount: reversedData?.length,
            itemBuilder: (BuildContext context, int index) => reversedData?[index] ?? Container(),
          );
        }
      },
    );
  }
}
