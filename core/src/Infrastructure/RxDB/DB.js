import { createRxDatabase } from 'rxdb/plugins/core';
import { getRxStorageDexie } from 'rxdb/plugins/storage-dexie';
import { articleSchema } from './Schema';

let dbPromise = null;

const createDBPromise = async () => {
  const db = await createRxDatabase({
    name: 'reader_db',
    storage: getRxStorageDexie(),
  });

  await db.addCollections({
    articles: { schema: articleSchema },
  });

  return db;
};

export const getDB = () => {
  if (!dbPromise) {
    dbPromise = createDBPromise();
  }

  return dbPromise;
};
