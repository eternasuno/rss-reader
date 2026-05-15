import { getDB } from '../../Infrastructure/RxDB/DB';

export const saveArticlesImpl = (articles) => async () => {
  const db = await getDB();

  await db.articles.bulkInsert(articles);
};

export const removeArticlesImpl = (ids) => async () => {
  const db = await getDB();

  await db.articles.bulkRemove(ids);
};

export const patchArticlesImpl = (ids) => (patch) => async () => {
  const db = await getDB();

  await db.articles.find({ selector: { id: { $in: ids } } }).patch(patch);
};

export const findArticleImpl = (id) => async () => {
  const db = await getDB();

  const article = await db.articles.findOne(id).exec();

  return article ? article.toJSON() : null;
};

export const observeArticlesImpl = (query) => async () => {
  const db = await getDB();

  const selector = query.onlyUnread ? { 'state.read': false } : null;

  return db.articles.find({
    selector,
    sort: [{ 'payload.pubDate': query.sortPubDateDesc ? 'desc' : 'asc' }],
  }).$;
};
