export const fetchImpl = (url) => (init) => async () => {
  const response = await fetch(url, init);
  if (!response.ok) {
    throw new Error(`[${response.status}] ${response.statusText}`);
  }

  return response;
};

export const textImpl = (response) => () => response.text();
