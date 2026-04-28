module Usecase.Codecs.DateTime where

import Prelude

import Data.Codec.Argonaut as CA
import Data.DateTime (DateTime)
import Data.DateTime.Instant (fromDateTime, instant, toDateTime, unInstant)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))

toDateTime' :: Number -> Maybe DateTime
toDateTime' = (map toDateTime) <<< instant <<< Milliseconds

foreign import parseDateTimeImpl :: (Number -> Maybe Number) -> Maybe Number -> String -> Maybe Number

parseDateTime :: String -> Maybe DateTime
parseDateTime str = parseDateTimeImpl Just Nothing str >>= toDateTime'

fromDateTime' :: DateTime -> Number
fromDateTime' dateTime = ms
  where
  (Milliseconds ms) = unInstant (fromDateTime dateTime)

foreign import formatDateTimeImpl :: Number -> String

formatDateTime :: DateTime -> String
formatDateTime = formatDateTimeImpl <<< fromDateTime'

dateTimeCodec :: CA.JsonCodec DateTime
dateTimeCodec = CA.prismaticCodec "DateTime" parseDateTime formatDateTime CA.string
