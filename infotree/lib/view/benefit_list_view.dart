import 'package:flutter/material.dart';
import 'package:infotree/model/benefit_data.dart';
import 'package:infotree/view/pages/benefits_page.dart';
import 'package:infotree/model/data.dart';
import 'package:provider/provider.dart';

class BenefitListView extends StatelessWidget {
  final List<BenefitData> items;
  final int id;

  const BenefitListView({super.key, required this.items, this.id = -1});

  @override
  Widget build(BuildContext context) {
    return Consumer<Data>(
      builder: (context, data, child) {
        var likedIds = data.user.likes;
        return Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, index) {
              final item = items[index];
              final isLiked = likedIds.contains(item.id); // ✅ 좋아요 여부 판단

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      item.image != null
                          ? NetworkImage(item.image!)
                          : const AssetImage('assets/images/default.jpg')
                              as ImageProvider,
                ),
                title: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${item.startDate.year}.${item.startDate.month}.${item.startDate.day} ~ '
                  '${item.endDate.year}.${item.endDate.month}.${item.endDate.day}',
                ),
                trailing: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationPage(notification: item),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
