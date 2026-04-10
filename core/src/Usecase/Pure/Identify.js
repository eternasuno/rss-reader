import { createHash } from 'node:crypto';

export const sha256HexImpl = (rawString) => {
  return createHash('sha256').update(rawString).digest('hex');
};
