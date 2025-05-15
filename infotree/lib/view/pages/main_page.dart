import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import 'package:infotree/model/data.dart';
import 'package:infotree/model/benefit_data.dart';
import 'package:infotree/view/pages/search_page.dart';
import 'package:infotree/view/pages/category_page.dart';
import 'package:infotree/view/pages/benefits_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Map<String, IconData> categoryIcons = {
    '교육': Icons.school,
    '공모': Icons.campaign,
    '경제': Icons.attach_money,
    '미디어': Icons.movie,
    '건강': Icons.health_and_safety,
    '환경': Icons.eco,
    '창업': Icons.lightbulb,
    '음식': Icons.restaurant,
    '과학': Icons.science,
    '뷰티': Icons.brush,
    '쇼핑': Icons.shopping_bag,
    '인턴': Icons.work,
    '대회': Icons.emoji_events,
    '카페': Icons.local_cafe,
    '여행': Icons.flight,
    '마케팅': Icons.campaign_outlined,
    '컴퓨터': Icons.computer,
    '디자인': Icons.design_services,
  };

  List<BenefitData> popularBenefits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPopularBenefits();
  }

  Future<void> fetchPopularBenefits() async {
    try {
      final userId = Provider.of<Data>(context, listen: false).user.id;
      final url = Uri.parse(
        'http://localhost:3000/demographic_recommend/$userId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final list =
            (jsonData['recommended_benefits'] as List)
                .map((e) => BenefitData.fromJson(e))
                .toList();

        setState(() {
          popularBenefits = list;
          isLoading = false;
        });
      } else {
        print('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = categoryIcons.entries.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Info Tree'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 검색창
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
              child: AbsorbPointer(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 📂 카테고리 제목
            const Text(
              '카테고리',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 🧭 카테고리 리스트 (2줄 + 가로 스크롤)
            SizedBox(
              height: 300,
              child: GridView.count(
                crossAxisCount: 3,
                scrollDirection: Axis.horizontal,
                mainAxisSpacing: 6,
                crossAxisSpacing: 30,
                childAspectRatio: 1,
                children:
                    categories
                        .map(
                          (entry) => _buildCategoryItem(entry.key, entry.value),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 20),

            // 🔥 인기
            const Text(
              '인기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 180,
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: popularBenefits.length,
                        itemBuilder: (context, index) {
                          final noti = popularBenefits[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          NotificationPage(notification: noti),
                                ),
                              );
                            },
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    noti.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    noti.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.favorite,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${noti.likes}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryBenefitPage(category: label),
          ),
        );
      },
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              child: Icon(icon, size: 24, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
