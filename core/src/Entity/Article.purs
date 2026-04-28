module Entity.Article where

import Prelude

import Data.DateTime (DateTime)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Entity.ValueObject (ExtractionStrategy, URL)

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
  , pubDate :: DateTime
  , title :: String
  }

type Article =
  { extractionStrategy :: ExtractionStrategy
  , id :: ArticleId
  , payload :: ArticlePayload
  , savedAt :: DateTime
  , state :: ArticleState
  , url :: URL
  }
