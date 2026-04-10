import { Readability } from '@paoramen/cheer-reader';
import { load } from 'cheerio';

export const extractAutoImpl = (htmlString) => {
  try {
    const $ = load(htmlString);
    const reader = new Readability($, { charThreshold: 50, maxElemsToParse: 50000 });
    const article = reader.parse();

    if (!article.content) {
      return null;
    }

    return {
      content: article.content,
      description: article.excerpt,
      pubDate: article.publishedTime,
      title: article.title || 'Untitled',
    };
  } catch {
    return null;
  }
};

export const extractCSSSelectorImpl = (selectors) => (htmlString) => {
  try {
    const $ = load(htmlString);
    const $content = $(selectors.content);
    if ($content.length === 0) return null;

    return {
      content: $content.html(),
      description: selectors.description ? $(selectors.description).text().trim() : null,
      pubDate: selectors.publishedAt ? $(selectors.publishedAt).text().trim() : null,
      title: selectors.title ? $(selectors.title).text().trim() : 'Untitled',
    };
  } catch {
    return null;
  }
};
