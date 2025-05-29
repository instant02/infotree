import { fetchsite } from './linkareer.js';
import { saveAllPosts } from './pgdb.js';
import { crawl_club } from './campus_club.js';
import { crawl_activity } from './campus_activity.js';
import { crawl_contest } from './campus_contest.js';
import { krcrawl } from './koreasch.js';
import { crawl_dgujanghak } from './dgujanghak.js';
import { crawl_dgunotice } from './dgunotice.js';

export async function crawl() {
  const number = 5; //크롤링 문서 개수
  const pagenum = 2; //동국대학교 크롤링 페이지 개수
  
  const clubresult = await crawl_club(number);
  await saveAllPosts(clubresult);
  //캠퍼스픽_동아리

  const activityresult = await crawl_activity(number);
  await saveAllPosts(activityresult);
  //캠퍼스픽_대외활동

  const contestresult = await crawl_contest(number);
  await saveAllPosts(contestresult);
  //캠퍼스픽_공모전
  const dgujanghak = await crawl_dgujanghak(pagenum);
  await saveAllPosts(dgujanghak);
  //동국대학교 장학공지  

  const dgugen = await crawl_dgunotice(pagenum);
  await saveAllPosts(dgugen);
  //동국대학교 일반공지  

  const linkresult = await fetchsite();
  await saveAllPosts(linkresult);
  //링커리어

  await krcrawl(number);
  //한국장학재단 공공데이터
}
