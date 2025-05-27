import 'package:flutter/material.dart';
import 'package:infotree/view/benefit_list_view.dart';
import 'package:provider/provider.dart';
import '../header_slidebar.dart';
import 'package:infotree/model/dummy/dummy_benefits.dart';
import 'package:infotree/model/data.dart';
import 'package:infotree/view/utils.dart';
import 'package:infotree/model/benefit_data.dart';
import 'package:infotree/view/pages/channel_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  List<String> filters = ['좋아요'];
  String selectedFilter = '좋아요';
  bool isLoading = true;
  List<BenefitData> likedItems = [];

  String selectedChannelName = '';
  String selectedChannelDescription = '';
  List<BenefitData> selectedChannelBenefits = [];

  @override
  void initState() {
    super.initState();
    _loadFilters();
    context.read<Data>().fetchUserFromServer();
  }

  Future<void> _loadFilters() async {
    final data = Provider.of<Data>(context, listen: false);
    final channelNames = await getChannelNames(data.user.channel);
    likedItems = await fetchLikedBenefits(data.user.likes);
    setState(() {
      filters = ['좋아요', ...channelNames];
      isLoading = false;
    });
  }

  Future<void> _loadChannelContent(String channelName, int channelId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final channelRes = await http.get(
        Uri.parse('http://localhost:3000/channels/$channelId'),
      );
      final benefitRes = await http.get(
        Uri.parse('http://localhost:3000/channel/$channelId/benefits'),
      );

      if (channelRes.statusCode == 200 && benefitRes.statusCode == 200) {
        final channelJson = json.decode(channelRes.body);
        final benefitJson = json.decode(benefitRes.body);

        setState(() {
          selectedChannelName = channelJson['name'] ?? '';
          selectedChannelDescription = channelJson['description'] ?? '';
          selectedChannelBenefits =
              (benefitJson as List)
                  .map((e) => BenefitData.fromJson(e))
                  .toList();
        });
      }
    } catch (e) {
      print('채널 로딩 실패: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Data>(
      builder: (context, data, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('구독')),
          body: SafeArea(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderSlidebar(
                          selected: selectedFilter,
                          filters: filters,
                          onTap: (selected) async {
                            if (selected == '좋아요') {
                              setState(() => selectedFilter = selected);
                            } else {
                              final index = filters.indexOf(selected) - 1;
                              final channelId = data.user.channel[index];
                              await _loadChannelContent(selected, channelId);
                              setState(() => selectedFilter = selected);
                            }
                          },
                        ),
                        const Divider(),
                        if (selectedFilter == '좋아요')
                          BenefitListView(items: likedItems)
                        else
                          Builder(
                            builder: (_) {
                              final index = filters.indexOf(selectedFilter) - 1;
                              final channelId = data.user.channel[index];
                              final items = data.benefitGroups[channelId] ?? [];
                              return BenefitListView(items: items);
                            },
                          ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}
