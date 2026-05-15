export const articleSchema = {
  indexes: ['payload.pubDate', 'state.read', 'state.starred'],
  primaryKey: 'id',
  properties: {
    id: { maxLength: 100, type: 'string' },
    payload: {
      properties: {
        content: { type: ['string', 'null'] },
        description: { type: ['string', 'null'] },
        pubDate: { type: 'number' },
        title: { type: 'string' },
      },
      required: ['title', 'pubDate'],
      type: 'object',
    },
    state: {
      properties: {
        read: { type: 'boolean' },
        starred: { type: 'boolean' },
      },
      required: ['read', 'starred'],
      type: 'object',
    },
    url: { type: 'string' },
  },
  required: ['id', 'url', 'state', 'payload'],
  type: 'object',
  version: 0,
};
