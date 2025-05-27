import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils.dart';
import 'package:infotree/model/benefit_data.dart';
import 'package:infotree/model/user.dart';
import 'package:infotree/model/data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  final BenefitData notification;

  const NotificationPage({super.key, required this.notification});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late int likes;
  late bool liked;

  @override
  void initState() {
    super.initState();
    likes = widget.notification.likes;
    liked = context.read<Data>().user.likes.contains(widget.notification.id);
    context.read<Data>().fetchUserFromServer();
    sendVisitLog(context, widget.notification.id);
  }

  Future<void> sendVisitLog(BuildContext context, int benefitId) async {
    final userId = context.read<Data>().user.id;
    final url = Uri.parse('http://localhost:3000/visit/$userId/$benefitId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('Visit log sent successfully');
      } else {
        print('Failed to send visit log: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending visit log: $e');
    }
  }

  Future<void> sendLike(bool isLike) async {
    final userId = context.read<Data>().user.id;
    final benefitId = widget.notification.id;
    final url = Uri.parse(
      'http://localhost:3000/${isLike ? 'like' : 'dislike'}/$userId/$benefitId',
    );

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        print('${isLike ? '좋아요' : '좋아요 취소'} 성공');
      } else {
        print('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('네트워크 오류: $e');
    }
  }

  void toggleLike() {
    setState(() {
      liked = !liked;
      likes += liked ? 1 : -1;
    });

    sendLike(liked);
  }

  @override
  Widget build(BuildContext context) {
    final noti = widget.notification;

    return Scaffold(
      appBar: AppBar(title: Text('공지 상세')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (noti.image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    noti.image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              noti.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (noti.link != null)
                  Row(
                    children: [
                      Icon(Icons.link, color: Colors.blue),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: () {
                          // 링크 열기 로직 필요 시 여기에 추가
                        },
                        child: const Text('자세히 보기'),
                      ),
                    ],
                  ),
                const Spacer(),
                Column(
                  children: [
                    IconButton(
                      iconSize: 28,
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? Colors.red : Colors.grey,
                      ),
                      onPressed: toggleLike,
                    ),
                    Text('$likes', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${formatDate(noti.startDate)} ~ ${formatDate(noti.endDate)}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(noti.description, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
