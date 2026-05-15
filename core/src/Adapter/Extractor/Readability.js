import { Readability } from '@mozilla/readability';

export const parseImpl = (document) => () => {
  const reader = new Readability(document);
  const article = reader.parse();

  if (!article) {
    throw new Error('Readability failed to parse the article content.');
  }

  return {
    content: article.content,
    description: article.excerpt,
    pubDate: Date.parse(article.publishedTime) || Date.now(),
    title: article.title ?? 'Untitled Article',
  };
};
