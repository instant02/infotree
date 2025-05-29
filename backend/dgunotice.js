import axios from 'axios';
import { load } from 'cheerio';
const {classifyText}  =  require('./llm.js');

async function detailsite(title, link) {
    const response = await axios.get(link);
    const $ = load(response.data);
    const rawtext = $('body').text();
    const result = await classifyText(rawtext, link);
    return result;
}

async function crawlSingleSite(num, checker) {
    const url = `https://www.dongguk.edu/article/HAKSANOTICE/list?pageIndex=${num}`;
    const response = await axios.get(url);
    const $ = load(response.data);
    const result = [];
    const elements = $('div.board_list > ul > li').toArray();

    for (const el of elements)
    {
        const onclick = $(el).find('a').attr('onclick'); // "goDetail('k')"
        const match = onclick?.match(/goDetail\((\d+)\)/);
        const k = match ? match[1] : null;

        $(el).find('div.top > p.tit > span').remove();
        const title = $(el).find('div.top > p.tit').text().replace(/\s+/g, ' ').trim();
        const link = k ? `https://www.dongguk.edu/article/HAKSANOTICE/list?pageIndex=${k}` : null;
        if (!checker.has(k))
        {
            const data = await detailsite(title, link);
            checker.add(k);
            result.push(data);
        }
    }
    return result;
}

export async function crawl_dgunotice(pagenum) {
    let nownum = 1;
    let allresults = [];
    let checker = new Set();
    while (nownum < pagenum) {
        const data = await crawlSingleSite(nownum, checker);
        allresults = allresults.concat(data);
        nownum++;
    }
   
    return allresults;
}
