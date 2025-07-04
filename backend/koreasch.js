import axios from 'axios';
import pg from 'pg';

const { Pool } = pg;
const pool = new Pool({
  user: 'infotree',
  host: 'localhost',
  database: 'infotree',
  password: 'info1234',
  port: 5432,
});

const API_KEY =
  'p+NSi/0FEcz13gHVg+bgaW50z9w92LYW/cNFAA4OuGCF2fU6i8NNdBpHq2y1XjRmGTIGL5mO9OSkAC6mTqcyHQ==';
//한국장학재단 공공데이터 api

const url =
  'https://api.odcloud.kr/api/15028252/v1/uddi:c7637c78-fbdd-481d-a59d-c6c12ce51a13';
//명세서 url



async function getScholarships(number) {
  // API 요청 파라미터 설정
const params = {
  serviceKey: API_KEY,
  page: '1',
  perPage: String(number),
  returnType: 'JSON',
};
  try {
    const response = await axios.get(url, { params });
    return response.data.data;
  } catch (error) {
    console.error('Error fetching data:', error);
  }
}

// 저장 함수
async function savePostToBenefits(post) {
  const query = `
    INSERT INTO benefits (
      title, start_date, end_date, description,
      private, categories, channel_id,
      image, link, latitude, longitude
    ) VALUES (
      $1, $2, $3, $4,
      $5, $6, $7,
      $8, $9, $10, $11
    )
    ON CONFLICT (link) DO NOTHING;
  `;
  const values = [
    `${post['운영기관명']} 장학`,
    post['모집시작일'],
    post['모집종료일'],
    post['자격제한'],
    false, // private (공개)
    ['장학'], // TEXT[] 배열
    0, // channel_id
    post.image || null,
    post['홈페이지주소'] || null,
    null, // latitude
    null, // longitude
  ];

  try {
    await pool.query(query, values);
    console.log(`✅ 저장됨: ${post['운영기관명']}`);
  } catch (err) {
    console.error(`❌ -- 저장 오류: ${post['운영기관명']} --`, err.message);
  }
}

// 전체 저장 처리
async function saveAllPosts(posts) {
  for (const post of posts) {
    await savePostToBenefits(post);
  }
}

export async function krcrawl(number) {
  const data = await getScholarships(number);
  await saveAllPosts(data);
}
