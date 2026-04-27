import { and, asc, desc, eq, inArray } from 'drizzle-orm';
import { db } from '../Infrastructure/Drizzle/db';
import { articles } from '../Infrastructure/Drizzle/schema';

export const saveArticlesImpl = async (articlesArray) => {
  if (!articlesArray || articlesArray.length === 0) {
    return;
  }

  await db.insert(articles).values(articlesArray).onConflictDoNothing({
    target: articles.id,
  });
};

export const removeArticlesImpl = async (articleIds) => {
  if (!articleIds || articleIds.length === 0) {
    return;
  }

  await db.delete(articles).where(inArray(articles.id, articleIds));
};

export const updateArticleStarredImpl = (starred) => async (articleId) => {
  await db.update(articles).set({ starred }).where(eq(articles.id, articleId));
};

export const updateArticleReadImpl = (read) => async (articleId) => {
  await db.update(articles).set({ read }).where(eq(articles.id, articleId));
};

export const getArticleImpl = async (articleId) => {
  const rows = await db.select().from(articles).where(eq(articles.id, articleId)).limit(1);

  return rows.at(0);
};

export const queryArticlesImpl = async (articleQuery) => {
  const filters = [];

  if (articleQuery.read !== null && articleQuery.read !== undefined) {
    filters.push(eq(articles.read, articleQuery.read));
  }

  if (articleQuery.start !== null && articleQuery.start !== undefined) {
    filters.push(eq(articles.starred, articleQuery.start));
  }

  const orderByPubDate =
    articleQuery.sortBy === 'pub_date_asc' ? asc(articles.pubDate) : desc(articles.pubDate);

  const baseQuery = db.select().from(articles);
  const filteredQuery = filters.length > 0 ? baseQuery.where(and(...filters)) : baseQuery;

  return await filteredQuery.orderBy(orderByPubDate);
};
