-- USERS
INSERT INTO users (id, name, school, email, phone, major, channel, categories, likes, year, gender, grade)
VALUES (
  1,
  '김동국',
  '동국대학교',
  'dongguk@example.com',
  '010-1234-5678',
  ARRAY['컴퓨터공학과'],
  ARRAY[1, 2],
  ARRAY['컴퓨터', '창업', '마케팅'],
  ARRAY[1, 2, 3, 4],
  2002,  -- 연도
  'male', -- 성별
  3       -- 학년
);


-- CHANNELS
INSERT INTO channels (id, name, description,  flowers, benefit_id, users)
VALUES (
  1,
  'DGU COM',
  '동국대 컴퓨터 공학과 체널입니다',
  24,
  ARRAY[1, 2, 3],
  ARRAY[1]
);

INSERT INTO channels (id, name, description,  flowers, benefit_id, users)
VALUES (
  2,
  'CAPS',
  '동국대 중앙동아리 CAPS입니다',
  24,
  ARRAY[4,5],
  ARRAY[1]
);

INSERT INTO channels (id, name, description,  flowers, benefit_id, users)
VALUES (
  3,
  'DGU',
  '동국대학교 공지사항입니다',
  24,
  ARRAY[]::INTEGER[],
  ARRAY[]::INTEGER[]
);

-- BENEFITS
INSERT INTO benefits (
  id, title, start_date, end_date, description,
  private, categories, channel_id,
  image, link, latitude, longitude, likes
) VALUES
(1,
 '[★동국대학교 X 에듀윌 쉬운 토익 공식 얼리버드 프로모션★]',
 '2025-04-08', '2025-04-20',
 '동국대 첨단융합대학 학생회를 통해 에듀윌X시원스쿨 토익 얼리버드 혜택 제공!',
 true, ARRAY['교육', '창업'], 1,
 'https://yt3.googleusercontent.com/HwcqRjByAr2qW33Z1UDjUTg-1vKH-NG1S9S7Cdw-O7CSrN0mfYEx5TmB-q3JoUMnLod3OAXNrA=s900-c-k-c0x00ffffff-no-rj',
 'https://forms.gle/jLS9kFPZGA3JwrSNA',
 NULL, NULL, 42
),
(2,
 '[📢 2025학년도 1학기 국가장학금 2차 신청 안내]',
 '2025-04-01', '2025-04-18',
 '국가장학금 2차 신청 대상: 재학생, 복학생, 신입생, 편입생.',
  true, ARRAY['교육'], 1,
 'https://yt3.googleusercontent.com/HwcqRjByAr2qW33Z1UDjUTg-1vKH-NG1S9S7Cdw-O7CSrN0mfYEx5TmB-q3JoUMnLod3OAXNrA=s900-c-k-c0x00ffffff-no-rj',
 'https://www.kosaf.go.kr',
 NULL, NULL, 17
),
(3,
 '[🍜 동국대 학생증 제시 시 제휴 음식점 할인 안내]',
 '2025-04-05', '2025-06-30',
 '학생증 제시 시 제휴 음식점에서 다양한 할인 제공!',
 true, ARRAY['음식'], 1,
 'https://yt3.googleusercontent.com/HwcqRjByAr2qW33Z1UDjUTg-1vKH-NG1S9S7Cdw-O7CSrN0mfYEx5TmB-q3JoUMnLod3OAXNrA=s900-c-k-c0x00ffffff-no-rj',
 NULL,
 37.5563, 126.9996,
 63
),
(4,
 'CAPS 아메리카노 10% 할인',
 NOW(), NOW() + INTERVAL '10 days',
 '빨리 오세요',
  true, ARRAY['카페', '음식'], 2,
 'https://yt3.googleusercontent.com/HwcqRjByAr2qW33Z1UDjUTg-1vKH-NG1S9S7Cdw-O7CSrN0mfYEx5TmB-q3JoUMnLod3OAXNrA=s900-c-k-c0x00ffffff-no-rj',
 'https://forms.gle/...',
 37.5573, 126.9986,
 42
),

(5,
 '사물인터넷 하계 교류 계절학기 신청 안내',
 '2025-06-01 00:00:00', '2025-06-30 23:59:59',
 '사물인터넷 혁신융합대학사업단에서 하계 계절학기 신청을 받습니다.',
  true, ARRAY['컴퓨터', '교육'], 2,
 NULL, NULL, NULL, NULL, 0
);

INSERT INTO benefits (
  id, title, start_date, end_date, description,
  private, categories, channel_id,
  image, link, latitude, longitude, likes
) VALUES
(6,
 '[그린컴퓨터아카데미] [스마트웹&콘텐츠개발]UI/UX & 프론트엔드(반응형웹,피그마,리엑트,SQL)개발자 양성

대학생 대외활동 공모전 채용 사이트 링커리어 https://linkareer.com/',
 '2025-04-08', '2025-08-25',
 '[그린컴퓨터아카데미] [스마트웹&콘텐츠개발]UI/UX & 프론트엔드(반응형웹,피그마,리엑트,SQL)개발자 양성

대학생 대외활동 공모전 채용 사이트 링커리어 https://linkareer.com/',
 false, ARRAY['컴퓨터', '디자인'], 0,
 'https://yt3.googleusercontent.com/HwcqRjByAr2qW33Z1UDjUTg-1vKH-NG1S9S7Cdw-O7CSrN0mfYEx5TmB-q3JoUMnLod3OAXNrA=s900-c-k-c0x00ffffff-no-rj',
 'https://forms.gle/jLS9kFPZGA3JwrSNA',
 NULL, NULL, 42
)

-- LOGS
INSERT INTO logs (user_id, benefit_id)
VALUES 
  (1, 1),
  (1, 2),
  (1, 3),
  (1, 4);


