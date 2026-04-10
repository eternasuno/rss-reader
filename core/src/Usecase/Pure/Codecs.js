export const parseDateTimeImpl = (just) => (nothing) => (dateString) => {
  const time = Date.parse(dateString);
  if (Number.isNaN(time)) {
    return nothing;
  }

  return just(time);
};

export const formatDateTimeImpl = (ms) => {
  return new Date(ms).toISOString();
};
