import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infotree/model/benefit_data.dart';
import 'package:infotree/view/benefit_list_view.dart';
import 'package:provider/provider.dart';
import 'package:infotree/model/data.dart';

class ChannelPage extends StatefulWidget {
  final int channelId;

  const ChannelPage({super.key, required this.channelId});

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  String name = '';
  String description = '';
  List<BenefitData> items = [];
  bool isLoading = true;
  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _loadChannelData();
    _checkSubscription();
  }

  void _checkSubscription() {
    final userChannels = context.read<Data>().user.channel;
    setState(() {
      isSubscribed = userChannels.contains(widget.channelId);
    });
  }

  Future<void> _loadChannelData() async {
    try {
      final channelUri = Uri.parse(
        'http://localhost:3000/channels/${widget.channelId}',
      );
      final benefitUri = Uri.parse(
        'http://localhost:3000/channel/${widget.channelId}/benefits',
      );

      final res1 = await http.get(channelUri);
      final res2 = await http.get(benefitUri);

      if (res1.statusCode == 200 && res2.statusCode == 200) {
        final channelJson = json.decode(res1.body);
        final benefitJson = json.decode(res2.body) as List;

        setState(() {
          name = channelJson['name'] ?? '';
          description = channelJson['description'] ?? '';
          items = benefitJson.map((e) => BenefitData.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        print('서버 응답 오류: ${res1.statusCode}, ${res2.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('채널 데이터 불러오기 실패: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _subscribe() async {
    final userId = context.read<Data>().user.id;
    final url = Uri.parse(
      'http://localhost:3000/channel/$userId/${widget.channelId}',
    );

    final res = await http.post(url);

    if (res.statusCode == 200) {
      setState(() => isSubscribed = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('구독이 완료되었습니다.')));
      await context.read<Data>().fetchUserFromServer();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('구독 실패: ${res.statusCode}')));
    }
  }

  Future<void> _unsubscribe() async {
    final userId = context.read<Data>().user.id;
    final url = Uri.parse(
      'http://localhost:3000/channel/$userId/${widget.channelId}',
    );

    final res = await http.delete(url);

    if (res.statusCode == 200) {
      setState(() => isSubscribed = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('구독이 취소되었습니다.')));
      await context.read<Data>().fetchUserFromServer();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('구독 취소 실패: ${res.statusCode}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<Data>(
        builder: (context, data, child) {
          return Scaffold(
            appBar: AppBar(title: Text(name)),
            body: SafeArea(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
                            child: Text(
                              description,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Divider(),
                          BenefitListView(items: items),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton.icon(
                              icon: Icon(
                                isSubscribed ? Icons.cancel : Icons.add,
                                color: isSubscribed ? Colors.red : Colors.blue,
                              ),
                              label: Text(
                                isSubscribed ? '구독 취소' : '구독하기',
                                style: TextStyle(
                                  color:
                                      isSubscribed ? Colors.red : Colors.blue,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed:
                                  isSubscribed ? _unsubscribe : _subscribe,
                            ),
                          ),
                        ],
                      ),
            ),
          );
        },
      ),
    );
  }
}
