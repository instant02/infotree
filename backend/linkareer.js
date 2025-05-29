import axios from 'axios';
import { load } from 'cheerio';
import xml2js from 'xml2js';
import { classifyText } from './llm.js';

export async function fetchsite(number) {
  const response = await axios.get(
    'https://linkareer.com/sitemap/activities/114.xml'
  );
  const parser = new xml2js.Parser();
  const sitemapData = await parser.parseStringPromise(response.data);
  const urls = sitemapData.urlset.url.map((url) => url.loc[0]);

  const lasturls = urls.slice(-49, -49 + number); // 크롤링 개수 조절
  const result = [];

  for (const url of lasturls) {
    const data = await detailsite(url);
    result.push(data);
  }

  return result;
}

async function detailsite(link) {
  const response = await axios.get(link);
  const $ = load(response.data); // 이 위치에서만 사용

  const title = $('section h1').text();
  const rawtext = $('.activity-detail-content').text();
  const cleantext = rawtext.replace(/<[^>]*>/g, '');
  const cleanedtext = cleantext.replace(/\s+/g, ' ').trim();

  const result = await classifyText(cleanedtext, link);
  return result;
}
