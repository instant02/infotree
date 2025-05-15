import 'package:flutter/material.dart';
import 'package:infotree/view/benefit_list_view.dart';
import 'package:provider/provider.dart';
import '../header_slidebar.dart';
import '../../model/benefit_data.dart';
import '../../model/user_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:infotree/model/data.dart';

class RecommandPage extends StatefulWidget {
  RecommandPage({super.key});

  @override
  State<RecommandPage> createState() => _RecommandPageState();
}

class _RecommandPageState extends State<RecommandPage> {
  List<BenefitData> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    final userId = Provider.of<Data>(context, listen: false).user.id;
    final url = Uri.parse('http://localhost:3000/recommend/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final benefits =
            (jsonData['recommended_benefits'] as List)
                .map((item) => BenefitData.fromJson(item))
                .toList();

        setState(() {
          items = benefits;
          isLoading = false;
        });
      } else {
        print('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('네트워크 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Data>(
      builder: (context, data, child) {
        return Scaffold(
          appBar: AppBar(title: Text('혜택 추천')),

          body: SafeArea(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: Row(
                            children: [
                              Text('${data.user.name}님을 위한 추천 혜택을 모아봤어요'),
                            ],
                          ),
                        ),
                        Divider(),
                        BenefitListView(items: items),
                      ],
                    ),
          ),
        );
      },
    );
  }
}
