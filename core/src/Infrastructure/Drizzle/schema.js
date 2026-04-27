import { index, integer, sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const articles = sqliteTable(
  'articles',
  {
    content: text('content'),
    description: text('description'),
    extras: text('extras', { mode: 'json' }).notNull().default('{}'),
    id: text('id').primaryKey(),
    pubDate: integer('pub_date', { mode: 'timestamp_ms' }).notNull(),
    read: integer('read', { mode: 'boolean' }).notNull().default(0),
    savedAt: integer('saved_at', { mode: 'timestamp_ms' }).notNull(),
    starred: integer('starred', { mode: 'boolean' }).notNull().default(0),
    title: text('title').notNull(),
    url: text('url').notNull().unique(),
  },
  (table) => [index('idx_articles_unread_pub').on(table.read, table.pubDate)]
);
