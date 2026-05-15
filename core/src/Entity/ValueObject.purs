module Entity.ValueObject where

import Prelude

import Data.Argonaut (class DecodeJson, class EncodeJson, JsonDecodeError(..), encodeJson)
import Data.Argonaut.Decode.Decoders (decodeNumber)
import Data.DateTime.Instant (Instant, instant, unInstant)
import Data.Either (note)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Data.Time.Duration (Milliseconds(..))

newtype URL = URL String

derive instance newtypeURL :: Newtype URL _
derive newtype instance showURL :: Show URL
derive newtype instance encodeJsonURL :: EncodeJson URL
derive newtype instance decodeJsonURL :: DecodeJson URL

newtype Timestamp = Timestamp Instant

derive instance newtypeTimestamp :: Newtype Timestamp _
derive newtype instance showTimestamp :: Show Timestamp

instance encodeJsonTimestamp :: EncodeJson Timestamp where
  encodeJson (Timestamp timestamp) = unInstant timestamp # (\(Milliseconds ms) -> encodeJson ms)

instance decodeJsonTimestamp :: DecodeJson Timestamp where
  decodeJson json = decodeNumber json <#> toTimestamp >>= note (UnexpectedValue json)
    where
    toTimestamp num = Timestamp <$> instant (Milliseconds num)

type CSSSelector =
  { content :: String
  , description :: Maybe String
  , pubDate :: Maybe String
  , title :: Maybe String
  }

data ExtractionStrategy = AutoDetect | CSSSelector CSSSelector
