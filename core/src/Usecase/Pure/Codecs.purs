module Usecase.Pure.Codecs where

import Prelude

import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Record as CAR
import Data.DateTime (DateTime)
import Data.DateTime.Instant (fromDateTime, instant, toDateTime, unInstant)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))
import Entity.Article (ArticlePayload)
import Entity.ValueObject (CSSSelector)

toDateTime' :: Number -> Maybe DateTime
toDateTime' = (map toDateTime) <<< instant <<< Milliseconds

fromDateTime' :: DateTime -> Number
fromDateTime' dateTime = ms
  where
  (Milliseconds ms) = unInstant (fromDateTime dateTime)

foreign import parseDateTimeImpl :: (Number -> Maybe Number) -> Maybe Number -> String -> Maybe Number

parseDateTime :: String -> Maybe DateTime
parseDateTime str = parseDateTimeImpl Just Nothing str >>= toDateTime'

foreign import formatDateTimeImpl :: Number -> String

formatDateTime :: DateTime -> String
formatDateTime = formatDateTimeImpl <<< fromDateTime'

dateTimeCodec :: CA.JsonCodec DateTime
dateTimeCodec = CA.prismaticCodec "DateTime" parseDateTime formatDateTime CA.string

articlePayloadCodec :: CA.JsonCodec ArticlePayload
articlePayloadCodec = CA.object "ArticlePayload" $ CAR.record
  { title: CA.string
  , content: CAR.optional CA.string
  , description: CAR.optional CA.string
  , pubDate: CAR.optional dateTimeCodec
  }

cssSelectorCodec :: CA.JsonCodec CSSSelector
cssSelectorCodec = CA.object "CSSSelector" $ CAR.record
  { title: CAR.optional CA.string
  , description: CAR.optional CA.string
  , content: CA.string
  , pubDate: CAR.optional CA.string
  }
