const TRACKING_PREFIXES = ['utm_', 'mc_', 'pd_rd_', 'spm'];

const TRACKING_PARAMS = new Set([
  'fbclid',
  'gclid',
  'dclid',
  'gbraid',
  'wbraid',
  'msclkid',
  'igshid',
  '_hsenc',
  '_hsmi',
  'mkt_tok',
  'ref',
  'ref_src',
  'ref_url',
  'smid',
]);

export const normalizeImpl = (just) => (nothing) => (raw) => {
  try {
    const url = new URL(raw.trim());

    const keysToDelete = [];
    for (const key of url.searchParams.keys()) {
      const lowerKey = key.toLowerCase();

      const matchesPrefix = TRACKING_PREFIXES.some((prefix) => lowerKey.startsWith(prefix));

      if (matchesPrefix || TRACKING_PARAMS.has(lowerKey)) {
        keysToDelete.push(key);
      }
    }

    keysToDelete.forEach((k) => {
      url.searchParams.delete(k);
    });

    url.hash = '';

    return just(url.href);
  } catch {
    return nothing;
  }
};
