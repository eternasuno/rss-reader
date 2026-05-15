module Entity.Article where

import Prelude

import Data.Argonaut (class DecodeJson, class EncodeJson)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Entity.ValueObject (Timestamp, URL)

newtype ArticleId = ArticleId String

derive instance newtypeArticleId :: Newtype ArticleId _
derive instance eqArticleId :: Eq ArticleId
derive newtype instance showArticleId :: Show ArticleId
derive newtype instance encodeJsonArticleId :: EncodeJson ArticleId
derive newtype instance decodeJsonArticleId :: DecodeJson ArticleId

type ArticleState =
  { read :: Boolean
  , starred :: Boolean
  }

type ArticlePayload =
  { content :: Maybe String
  , description :: Maybe String
  , pubDate :: Timestamp
  , title :: String
  }

type Article =
  { id :: ArticleId
  , payload :: ArticlePayload
  , state :: ArticleState
  , url :: URL
  }
