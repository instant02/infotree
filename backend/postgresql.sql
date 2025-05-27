CREATE TABLE users (
  id SERIAL PRIMARY KEY,               -- 고유 ID (자동 증가)
  name TEXT NOT NULL,                  -- 이름
  school TEXT NOT NULL,                -- 학교
  email TEXT NOT NULL UNIQUE,          -- 이메일 (중복 금지)
  phone TEXT NOT NULL,                 -- 전화번호
  major TEXT[] DEFAULT '{}',           -- 전공 (문자열 배열, null 허용)
  channel INTEGER[] DEFAULT '{}',      -- 구독 채널 (정수 배열, null 허용)
  categories TEXT[] DEFAULT '{}',      -- 관심 키워드
  likes INTEGER[] DEFAULT '{}',        -- 좋아요한 공지 ID
  year INTEGER,                        -- 연도
  grade INTEGER,                       -- 학년
  gender TEXT                          -- 성별
);



CREATE TABLE benefits (
  id SERIAL PRIMARY KEY,                -- 공지 ID (자동 증가)
  title TEXT NOT NULL UNIQUE,           -- 제목 (중복 불가)
  start_date TIMESTAMP NOT NULL,        -- 시작일
  end_date TIMESTAMP NOT NULL,          -- 종료일
  description TEXT NOT NULL,            -- 설명
  private BOOLEAN,                      -- 비공개 여부
  categories TEXT[] NOT NULL,           -- 카테고리 (문자열 배열)
  channel_id INTEGER NOT NULL,          -- 소속 채널 ID
  image TEXT,                           -- 이미지 링크 (nullable)
  link TEXT UNIQUE,                     -- 외부 링크 (중복 불가)
  latitude DOUBLE PRECISION,            -- 위도 (nullable)
  longitude DOUBLE PRECISION,           -- 경도 (nullable)
  likes INTEGER DEFAULT 0               -- 좋아요 수 (기본 0)
);




CREATE TABLE logs (
  id SERIAL PRIMARY KEY,           -- 로그 고유 ID (자동 증가)
  user_id INTEGER NOT NULL,        -- 로그를 생성한 사용자 ID
  benefit_id INTEGER NOT NULL,     -- 관련된 혜택(Benefit) ID
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- 생성 시각 (기본 현재시간)
);

ALTER TABLE logs
ADD CONSTRAINT logs_user_benefit_unique UNIQUE(user_id, benefit_id);


CREATE TABLE channels (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,             
  flowers INTEGER DEFAULT 0,
  benefit_id INTEGER[] DEFAULT '{}',
  users INTEGER[] DEFAULT '{}'
);