module Entity.Article where

import Data.DateTime (DateTime)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Entity.ValueObject (ExtractionStrategy, URL)

newtype ArticleId = ArticleId String

derive instance newtypeArticleId :: Newtype ArticleId _

type ArticleState =
  { read :: Boolean
  , starred :: Boolean
  }

type ArticlePayload =
  { title :: String
  , description :: Maybe String
  , content :: Maybe String
  , pubDate :: DateTime
  }

type Article =
  { id :: ArticleId
  , url :: URL
  , payload :: ArticlePayload
  , state :: ArticleState
  , extractionStrategy :: ExtractionStrategy
  , savedAt :: DateTime
  }
