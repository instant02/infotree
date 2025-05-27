import express from 'express';
import { dirname } from 'path';
import { fileURLToPath } from 'url';
import pg from 'pg';
import { crawl } from './index.js';
import fetch from 'node-fetch';

const { Pool } = pg;
const __dirname = dirname(fileURLToPath(import.meta.url));
const app = express();

app.use(express.json());
app.use(express.static('public'));
app.set('port', process.env.PORT || 3000);
app.set('view engine', 'ejs');
app.set('views', './views');
app.use(express.static('public'));
const modelURL = 'http://localhost:8000';

// PostgreSQL 연결 설정
const pool = new Pool({
  user: 'infotree',
  host: 'localhost',
  database: 'infotree',
  password: 'info1234',
  port: 5432,
});

// 서버 실행
app.listen(app.get('port'), () => {
  console.log('LISTENING AT PORT: ', app.get('port'));
});

// 페이지 렌더

// POST 요청 바디 파싱용 미들웨어 (필수)
app.use(express.urlencoded({ extended: true }));

// 채널 수정 폼 렌더링
app.get('/admin/:channelid', async (req, res) => {
  const channelId = parseInt(req.params.channelid);
  if (isNaN(channelId))
    return res.status(400).send('유효하지 않은 채널 ID입니다.');

  try {
    // 1) 채널 정보
    const channelResult = await pool.query(
      'SELECT * FROM channels WHERE id = $1',
      [channelId]
    );
    if (channelResult.rows.length === 0)
      return res.status(404).send('채널을 찾을 수 없습니다.');
    const channel = channelResult.rows[0];

    // 2) 가입 유저 목록
    let users = [];
    if (channel.users && channel.users.length > 0) {
      const userResult = await pool.query(
        'SELECT id, name, likes FROM users WHERE id = ANY($1::int[]) ORDER BY name',
        [channel.users]
      );
      users = userResult.rows;
    }

    // 3) 혜택 목록
    const benefitsResult = await pool.query(
      'SELECT id, title, start_date, end_date FROM benefits WHERE channel_id = $1 ORDER BY start_date DESC',
      [channelId]
    );
    const benefits = benefitsResult.rows;

    // 4) 카테고리별 가중치 점수 계산 (좋아요 1점 + 로그 0.5점)
    let weightedCategoryStats = [];
    if (users.length > 0) {
      const userIds = users.map((u) => u.id);

      const weightedCategoryQuery = `
        WITH user_likes AS (
          SELECT unnest(likes) AS benefit_id
          FROM users
          WHERE id = ANY($1::int[])
        ),
        user_logs AS (
          SELECT benefit_id, 0.5 AS weight
          FROM logs
          WHERE user_id = ANY($1::int[])
        ),
        all_scores AS (
          SELECT benefit_id, 1.0 AS weight FROM user_likes
          UNION ALL
          SELECT benefit_id, weight FROM user_logs
        ),
        benefit_cats AS (
          SELECT b.id, unnest(b.categories) AS category
          FROM benefits b
        ),
        weighted_cats AS (
          SELECT bc.category, aw.weight
          FROM all_scores aw
          JOIN benefit_cats bc ON aw.benefit_id = bc.id
        )
        SELECT category, SUM(weight) AS score
        FROM weighted_cats
        GROUP BY category
        ORDER BY score DESC
        LIMIT 8;
      `;

      const weightedResult = await pool.query(weightedCategoryQuery, [userIds]);
      weightedCategoryStats = weightedResult.rows;
    }

    res.render('admin', {
      channel,
      users,
      benefits,
      weightedCategoryStats, // 반드시 전달!
    });
  } catch (err) {
    console.error(err);
    res.status(500).send('서버 오류');
  }
});

app.post('/benefits/create', async (req, res) => {
  let { title, description, start_date, end_date, category, channel_id } =
    req.body;

  if (
    !title ||
    !description ||
    !start_date ||
    !end_date ||
    !category ||
    !channel_id
  ) {
    return res.status(400).send('필수 항목이 누락되었습니다.');
  }

  if (!Array.isArray(category)) {
    category = [category]; // 체크박스 1개 선택 시 문자열로 옴
  }

  // 중복 제거 (선택사항)
  category = [...new Set(category)];

  try {
    const query = `
      INSERT INTO benefits
      (title, description, start_date, end_date, categories, channel_id)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id
    `;

    await pool.query(query, [
      title,
      description,
      start_date,
      end_date,
      category,
      channel_id,
    ]);

    res.redirect(`/admin/${channel_id}`);
  } catch (err) {
    console.error(err);
    res.status(500).send('혜택 등록 중 오류가 발생했습니다.');
  }
});

// 채널 정보 수정 처리
app.post('/admin/:channelid/update', async (req, res) => {
  const channelId = parseInt(req.params.channelid);
  const { name, description, flowers } = req.body;

  if (isNaN(channelId)) {
    return res.status(400).send('유효하지 않은 채널 ID입니다.');
  }

  if (!name || !description) {
    return res.status(400).send('이름과 설명은 필수입니다.');
  }

  try {
    await pool.query(
      `
      UPDATE channels
      SET name = $1,
          description = $2,
          flowers = $3
      WHERE id = $4
      `,
      [name, description, parseInt(flowers) || 0, channelId]
    );

    res.redirect(`/admin/${channelId}`);
  } catch (err) {
    console.error(err);
    res.status(500).send('채널 정보 수정 중 오류가 발생했습니다.');
  }
});

app.get('/crawl', async (req, res) => {
  await crawl();
});

app.get('/users/:id', async (req, res) => {
  const userId = req.params.id;

  try {
    const result = await pool.query('SELECT * FROM users WHERE id = $1', [
      userId,
    ]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    //console.log(result.rows[0]);
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

app.get('/recommend/:user_id', async (req, res) => {
  const userId = req.params.user_id;

  try {
    // 1. FastAPI 모델 서버에서 추천 결과 받아오기
    const response = await fetch(`${modelURL}/recommend/${userId}`);
    if (!response.ok) {
      return res.status(response.status).json({ error: '모델 서버 오류' });
    }

    const result = await response.json();

    if (!result.recommendations || result.recommendations.length === 0) {
      return res.status(404).json({ error: '추천 결과 없음' });
    }

    // 2. 추천 ID 배열 (숫자 배열) 그대로 사용
    const benefitIds = result.recommendations;

    // 3. PostgreSQL에서 혜택 정보 조회
    const query = `
      SELECT *
      FROM benefits
      WHERE id = ANY($1::int[])
      ORDER BY array_position($1::int[], id)
    `;

    const dbResult = await pool.query(query, [benefitIds]);

    // 4. DB 컬럼명을 BenefitData JSON 구조에 맞게 변환
    const benefits = dbResult.rows.map((row) => ({
      id: row.id,
      title: row.title,
      start_date: row.start_date.toISOString(),
      end_date: row.end_date.toISOString(),
      description: row.description,
      owner_id: row.channel_id, // DB는 channel_id → Dart는 ownerId
      private: row.private ?? false,
      categories: row.categories || [],
      channel_id: row.channel_id,
      image: row.image,
      link: row.link,
      latitude: row.latitude !== null ? parseFloat(row.latitude) : null,
      longitude: row.longitude !== null ? parseFloat(row.longitude) : null,
      likes: row.likes ?? 0,
    }));

    // 5. 최종 응답
    res.json({
      user_id: userId,
      recommended_benefits: benefits,
    });
  } catch (err) {
    console.error('추천 오류:', err);
    res.status(500).json({ error: '내부 서버 오류' });
  }
});

// GET /demographic_recommend/:user_id
app.get('/demographic_recommend/:user_id', async (req, res) => {
  const userId = req.params.user_id;

  try {
    // 1. FastAPI 서버에서 추천 결과 가져오기
    const response = await fetch(`${modelURL}/demographic_recommend/${userId}`);
    const result = await response.json();

    if (!result.recommendations || result.recommendations.length === 0) {
      return res.status(404).json({ error: '추천 결과 없음' });
    }

    // 2. benefit_id만 추출
    const benefitIds = result.recommendations.map((r) => r.benefit_id);

    // 3. PostgreSQL에서 해당 혜택 정보 조회
    const query = `
      SELECT *
      FROM benefits
      WHERE id = ANY($1::int[])
    `;
    const dbResult = await pool.query(query, [benefitIds]);

    // 선택적으로: 순서를 FastAPI 추천 순서대로 정렬
    const benefitMap = new Map(dbResult.rows.map((b) => [b.id, b]));
    const orderedBenefits = benefitIds
      .map((id) => benefitMap.get(id))
      .filter(Boolean);

    res.json({
      user_id: userId,
      recommended_benefits: orderedBenefits,
    });
  } catch (err) {
    console.error('Demographic 추천 오류:', err);
    res.status(500).json({ error: '내부 서버 오류' });
  }
});

// 공지 ID로 공지 정보 불러오기
app.get('/benefit/:id', async (req, res) => {
  const notiId = req.params.id;

  try {
    const result = await pool.query(
      'SELECT * FROM benefits WHERE id = $1 AND end_date >= NOW()',
      [notiId]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Notification not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// GET /channels/:id
app.get('/channels/:id', async (req, res) => {
  const channelId = req.params.id;
  //console.log(channelId);
  try {
    const result = await pool.query('SELECT * FROM channels WHERE id = $1', [
      channelId,
    ]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Channel not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// 특정 채널의 혜택 목록 불러오기
app.get('/channel/:id/benefits', async (req, res) => {
  const channelId = req.params.id;

  try {
    const result = await pool.query(
      'SELECT * FROM benefits WHERE channel_id = $1 AND end_date >= NOW() ORDER BY id DESC',
      [channelId]
    );
    //console.log(result.rows);
    if (result.rows.length === 0) {
      return res
        .status(404)
        .json({ error: 'No valid benefits found for this channel' });
    }
    res.json(result.rows);
  } catch (err) {
    console.error('DB Error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

app.post('/like/:userid/:benefitid', async (req, res) => {
  const userId = parseInt(req.params.userid);
  const benefitId = parseInt(req.params.benefitid);
  if (isNaN(userId) || isNaN(benefitId)) {
    return res
      .status(400)
      .json({ error: '유효하지 않은 userId 또는 benefitId 입니다.' });
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    await client.query(
      `
      UPDATE users
      SET likes = array_append(likes, $2)
      WHERE id = $1 AND NOT ($2 = ANY(likes))
      `,
      [userId, benefitId]
    );
    await client.query(
      `
      UPDATE benefits
      SET likes = likes + 1
      WHERE id = $1
      `,
      [benefitId]
    );
    await client.query('COMMIT');
    res.json({ message: '좋아요가 정상 처리되었습니다.' });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('좋아요 처리 오류:', err);
    res.status(500).json({ error: '좋아요 처리 중 오류가 발생했습니다.' });
  } finally {
    client.release();
  }
});

app.post('/dislike/:userid/:benefitid', async (req, res) => {
  const userId = parseInt(req.params.userid);
  const benefitId = parseInt(req.params.benefitid);

  if (isNaN(userId) || isNaN(benefitId)) {
    return res
      .status(400)
      .json({ error: '유효하지 않은 userId 또는 benefitId 입니다.' });
  }

  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    await client.query(
      `
      UPDATE users
      SET likes = array_remove(likes, $2)
      WHERE id = $1
      `,
      [userId, benefitId]
    );
    await client.query(
      `
      UPDATE benefits
      SET likes = GREATEST(likes - 1, 0)
      WHERE id = $1
      `,
      [benefitId]
    );
    await client.query('COMMIT');
    res.json({ message: '좋아요 취소가 정상 처리되었습니다.' });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('좋아요 취소 처리 오류:', err);
    res.status(500).json({ error: '좋아요 취소 처리 중 오류가 발생했습니다.' });
  } finally {
    client.release();
  }
});

app.post('/channels/names', async (req, res) => {
  const ids = req.body.ids;

  if (!Array.isArray(ids) || ids.length === 0) {
    return res.status(400).json({ error: '채널 ID 배열이 필요합니다.' });
  }

  try {
    const query = `
      SELECT id, name
      FROM channels
      WHERE id = ANY($1::int[])
    `;
    const result = await pool.query(query, [ids]);

    const channelMap = {};
    for (const row of result.rows) {
      channelMap[row.id] = row.name;
    }

    res.json({ channels: channelMap });
  } catch (err) {
    console.error('DB 오류:', err);
    res.status(500).json({ error: '데이터베이스 오류' });
  }
});

// POST /benefits/liked id를 주면 해당하는 benfit 전체를 리턴
app.post('/benefits/liked', async (req, res) => {
  const ids = req.body.ids;

  if (!Array.isArray(ids) || ids.length === 0) {
    return res.status(400).json({ error: 'likes 배열이 필요합니다' });
  }

  try {
    const result = await pool.query(
      'SELECT * FROM benefits WHERE id = ANY($1::int[]) AND end_date >= NOW()',
      [ids]
    );

    res.json(result.rows);
  } catch (err) {
    console.error('DB 오류:', err);
    res.status(500).json({ error: '데이터베이스 오류' });
  }
});

// POST /benefits/category
app.post('/benefits/category', async (req, res) => {
  const { category } = req.body;

  if (!category) {
    return res.status(400).json({ error: '카테고리 이름이 필요합니다.' });
  }

  try {
    const now = new Date().toISOString();
    const query = `
      SELECT * FROM benefits
      WHERE $1 = ANY(categories)
      AND end_date >= $2
      AND private = false
      ORDER BY end_date ASC
    `;

    const result = await pool.query(query, [category, now]);

    res.json(result.rows);
  } catch (err) {
    console.error('DB Error:', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.post('/benefits/search', async (req, res) => {
  const { searchTerm } = req.body;

  if (!searchTerm) {
    return res.status(400).json({ error: '검색어가 필요합니다.' });
  }

  try {
    const now = new Date().toISOString();
    const query = `
      SELECT * FROM benefits
      WHERE (title ILIKE $1 OR description ILIKE $1)
      AND end_date >= $2
      AND private = false
      ORDER BY end_date ASC
    `;
    const result = await pool.query(query, [`%${searchTerm}%`, now]);

    res.json(result.rows);
  } catch (err) {
    console.error('DB Error:', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.post('/channels/search', async (req, res) => {
  const { searchTerm } = req.body;

  if (!searchTerm) {
    return res.status(400).json({ error: '검색어가 필요합니다.' });
  }

  try {
    const query = `
      SELECT * FROM channels
      WHERE name ILIKE $1 OR description ILIKE $1
      ORDER BY name ASC
    `;
    const result = await pool.query(query, [`%${searchTerm}%`]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: '검색된 채널이 없습니다.' });
    }

    res.json(result.rows);
  } catch (err) {
    console.error('DB Error:', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.delete('/channel/:userid/:channelid', async (req, res) => {
  const userId = parseInt(req.params.userid);
  const channelId = parseInt(req.params.channelid);
  console.log(userId);
  if (isNaN(userId) || isNaN(channelId)) {
    return res
      .status(400)
      .json({ error: '유효하지 않은 userId 또는 channelId 입니다.' });
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(
      `
      UPDATE users
      SET channel = array_remove(channel, $2)
      WHERE id = $1
      `,
      [userId, channelId]
    );
    await client.query(
      `
      UPDATE channels
      SET users = array_remove(users, $1)
      WHERE id = $2
      `,
      [userId, channelId]
    );
    await client.query('COMMIT');
    res.json({ message: '구독 채널이 정상적으로 해지되었습니다.' });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('구독 해지 오류:', err);
    res.status(500).json({ error: '구독 해지 중 오류가 발생했습니다.' });
  } finally {
    client.release();
  }
});

app.post('/channel/:userid/:channelid', async (req, res) => {
  const userId = parseInt(req.params.userid);
  const channelId = parseInt(req.params.channelid);
  if (isNaN(userId) || isNaN(channelId)) {
    return res
      .status(400)
      .json({ error: '유효하지 않은 userId 또는 channelId 입니다.' });
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(
      `
      UPDATE users
      SET channel = CASE
        WHEN NOT ($2 = ANY(channel)) THEN array_append(channel, $2)
        ELSE channel
      END
      WHERE id = $1
      `,
      [userId, channelId]
    );
    await client.query(
      `
      UPDATE channels
      SET users = CASE
        WHEN NOT ($1 = ANY(users)) THEN array_append(users, $1)
        ELSE users
      END
      WHERE id = $2
      `,
      [userId, channelId]
    );
    await client.query('COMMIT');
    res.json({ message: '채널 구독이 정상 처리되었습니다.' });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('구독 처리 오류:', err);
    res.status(500).json({ error: '구독 처리 중 오류가 발생했습니다.' });
  } finally {
    client.release();
  }
});

app.get('/visit/:user_id/:benefit_id', async (req, res) => {
  const userId = parseInt(req.params.user_id);
  const benefitId = parseInt(req.params.benefit_id);

  if (isNaN(userId) || isNaN(benefitId)) {
    return res
      .status(400)
      .json({ error: '유효하지 않은 user_id 또는 benefit_id입니다.' });
  }

  try {
    const query = `
      INSERT INTO logs (user_id, benefit_id) 
      VALUES ($1, $2)
      ON CONFLICT ON CONSTRAINT logs_user_benefit_unique DO NOTHING
    `;
    await pool.query(query, [userId, benefitId]);

    res.json({ message: '방문 로그가 정상 추가되었거나 이미 존재합니다.' });
  } catch (err) {
    console.error('로그 추가 오류:', err);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
});
