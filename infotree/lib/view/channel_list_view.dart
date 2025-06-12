import 'package:flutter/material.dart';
import 'package:infotree/model/channel_data.dart'; // Assuming you have a ChannelData model
import 'package:infotree/view/pages/channel_page.dart'; // Assuming you have a page for channel details

class ChannelListView extends StatelessWidget {
  final List<ChannelData> channels;

  const ChannelListView({super.key, required this.channels});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: channels.length,
        itemBuilder: (_, index) {
          final channel = channels[index];

          return ListTile(
            leading: CircleAvatar(radius: 24, backgroundColor: Colors.white),
            title: Text(
              channel.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              channel.description, // Channel description
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () {
              // Navigate to the channel page when tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChannelPage(channelId: channel.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
