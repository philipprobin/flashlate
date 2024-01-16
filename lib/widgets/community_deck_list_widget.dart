import 'package:flutter/cupertino.dart';

import 'category_tile_widget.dart';
import 'loading_list_item_widget.dart';

class CommunityDeckListWidget extends StatelessWidget {
  final Future<List<CategoryTileWidget>> Function() fetchCommunityDecks;

  CommunityDeckListWidget({Key? key, required this.fetchCommunityDecks})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryTileWidget>>(
      future: fetchCommunityDecks(),
      builder: (BuildContext context,
          AsyncSnapshot<List<CategoryTileWidget>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, i) => LoadingListItemWidget(),
            itemCount: 8,
            separatorBuilder: (BuildContext context, int index) =>
                SizedBox(height: 8),
          );
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Data has Error. ${snapshot.error.toString()}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available.'));
        } else {
          final reversedData = snapshot.data?.reversed.toList();
          return ListView.builder(
            itemCount: reversedData?.length,
            itemBuilder: (BuildContext context, int index) =>
                reversedData?[index] ?? Container(),
          );
        }
      },
    );
  }
}
