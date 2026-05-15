import DOMPurify from 'dompurify';

export const parseImpl = (html) => () => new DOMParser().parseFromString(html, 'text/html');

export const sanitizeImpl = (html) => () => DOMPurify.sanitize(html, { RETURN_DOM: false });
