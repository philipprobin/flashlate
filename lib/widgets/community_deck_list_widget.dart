import 'package:flashlate/widgets/custom_expansion_tile_widget.dart';
import 'package:flutter/material.dart';
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
      builder: (BuildContext context, AsyncSnapshot<List<CategoryTileWidget>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingListView();
        } else if (snapshot.hasError) {
          return _errorView(snapshot.error);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _emptyDataView();
        } else {
          final reversedData = snapshot.data?.reversed.toList();
          final groupedData = _groupData(reversedData);
          return _groupedListView(groupedData);
        }
      },
    );
  }

  Widget _loadingListView() {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, i) => LoadingListItemWidget(),
      itemCount: 8,
      separatorBuilder: (BuildContext context, int index) => SizedBox(height: 8),
    );
  }

  Widget _errorView(dynamic error) {
    return Center(child: Text('Data has Error. ${error.toString()}'));
  }

  Widget _emptyDataView() {
    return Center(child: Text('Coming soon!.'));
  }

  Map<String, List<CategoryTileWidget>> _groupData(List<CategoryTileWidget>? data) {
    Map<String, List<CategoryTileWidget>> groupedData = {};
    data?.forEach((categoryTile) {
      String groupName = categoryTile.categoryName.split(' ')[0]; // Split by space and take the first word
      groupedData.putIfAbsent(groupName, () => []).add(categoryTile);
    });
    return groupedData;
  }

  Widget _groupedListView(Map<String, List<CategoryTileWidget>> groupedData) {
    return ListView.builder(
      itemCount: groupedData.keys.length,
      itemBuilder: (BuildContext context, int index) {
        String key = groupedData.keys.elementAt(index);
        List<CategoryTileWidget> items = groupedData[key]!;

        return CustomExpansionTileWidget(
          title: key,
          children: items.map((item) => item).toList(),
        );
      },
    );
  }

}
