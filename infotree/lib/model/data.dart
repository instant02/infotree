import 'package:flutter/material.dart';
import 'package:infotree/model/user.dart';
import 'package:infotree/model/user_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:infotree/model/benefit_data.dart';

void printBenefitGroups(Map<int, List<BenefitData>> benefitGroups) {
  for (var entry in benefitGroups.entries) {
    final channelId = entry.key;
    final benefits = entry.value;

    print('🔹 채널 ID: $channelId (${benefits.length}개 혜택)');
    for (var benefit in benefits) {
      print('  - [${benefit.id}] ${benefit.title} (${benefit.likes} ❤️)');
    }
  }
}

class Data extends ChangeNotifier {
  UserData user = UserData(
    id: 0,
    name: '',
    school: '',
    email: 'email',
    phone: 'phone',
    major: [],
    channel: [],
    categories: [],
    likes: [],
    gender: 'male',
    grade: 3,
    year: 2002,
  );

  Map<int, List<BenefitData>> benefitGroups = {};

  Future<void> fetchUserFromServer() async {
    final uri = Uri.parse('http://localhost:3000/users/${user.id}'); // 주소 수정 가능

    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        user = UserData.fromJson(jsonData); // ✅ 갱신
        notifyListeners(); // ✅ 리스너에게 알림
        fetchBenefitsForUserChannels();
      } else {
        throw Exception('서버 오류: ${res.statusCode}');
      }
    } catch (e) {
      user = mainUser;
      print('유저 데이터 가져오기 실패: $e');
    }
  }

  Future<void> fetchBenefitsForUserChannels() async {
    benefitGroups.clear();

    for (int channelId in user.channel) {
      final uri = Uri.parse(
        'http://localhost:3000/channel/$channelId/benefits',
      );

      try {
        final res = await http.get(uri);
        if (res.statusCode == 200) {
          final List<dynamic> jsonList = json.decode(res.body);

          final List<BenefitData> benefits =
              jsonList
                  .map((jsonItem) => BenefitData.fromJson(jsonItem))
                  .toList();

          benefitGroups[channelId] = benefits;
        } else {
          print('채널 $channelId 불러오기 실패: ${res.statusCode}');
          benefitGroups[channelId] = [];
        }
      } catch (e) {
        print('채널 $channelId 요청 중 오류: $e');
        benefitGroups[channelId] = [];
      }
    }

    notifyListeners();
  }
}
