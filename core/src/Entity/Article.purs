module Entity.Article where

import Prelude

import Data.DateTime.Instant (Instant)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Entity.ValueObject (URL)

newtype ArticleId = ArticleId String

derive instance newtypeArticleId :: Newtype ArticleId _
derive instance eqArticleId :: Eq ArticleId
instance showArticleId :: Show ArticleId where
  show (ArticleId id) = id

type ArticleState =
  { read :: Boolean
  , starred :: Boolean
  }

type ArticlePayload =
  { content :: Maybe String
  , description :: Maybe String
  , pubDate :: Instant
  , title :: String
  }

type Article =
  { id :: ArticleId
  , payload :: ArticlePayload
  , state :: ArticleState
  , url :: URL
  }
