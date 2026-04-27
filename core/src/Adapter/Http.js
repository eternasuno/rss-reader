export const fetchHtmlImpl = (url) =>
  fetch(url).then((res) => {
    if (!res.ok) {
      throw new Error(`HTTP Error: ${res.status}`);
    }

    return res.text();
  });
