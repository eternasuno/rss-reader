import type { Observable } from 'rxjs';

type Result<T> = { tag: 'success'; value: T } | { tag: 'error'; message: string };

type ArticlePayload = {
  content: string | null;
  description: string | null;
  pubDate: number;
  title: string;
};

type ArticleState = {
  read: boolean;
  starred: boolean;
};

type Article = {
  id: string;
  payload: ArticlePayload;
  state: ArticleState;
  url: string;
};

type ArticleQuery = {
  onlyUnread: boolean;
  sortPubDateDesc: boolean;
};

type ArticlePatch = {
  state: { read?: boolean; starred?: boolean };
};

export function subscribeArticle(
  key: string | null
): (rawURL: string) => () => Promise<Result<void>>;

export function patchArticles(
  ids: string[]
): (patch: ArticlePatch) => () => Promise<Result<void>>;

export function removeArticles(ids: string[]): () => Promise<Result<void>>;

export function observeArticles(
  query: ArticleQuery
): () => Promise<Result<Observable<ReadonlyArray<Article>>>>;
