export const sha256HexImpl = async (rawString) => {
  const webCrypto = globalThis.crypto;
  if (!webCrypto?.subtle) {
    throw new Error('Web Crypto API is not available in this environment.');
  }

  const encoder = new TextEncoder();
  const data = encoder.encode(rawString);

  const hashBuffer = await webCrypto.subtle.digest('SHA-256', data);

  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hexString = hashArray.map((b) => b.toString(16).padStart(2, '0')).join('');

  return hexString;
};
