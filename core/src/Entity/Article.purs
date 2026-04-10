module Entity.Article where

import Data.DateTime (DateTime)
import Data.Maybe (Maybe)
import Entity.Feed (FeedId)
import Entity.ValueObject (ExtractionStrategy)

newtype ArticleId = ArticleId String

newtype ArticleUrl = ArticleUrl String

data ReadStatus = Unread | Read

data StarStatus = Unstarred | Starred

type ArticleState =
  { read :: ReadStatus
  , star :: StarStatus
  }

type ArticlePayload =
  { title :: String
  , description :: Maybe String
  , content :: Maybe String
  , pubDate :: Maybe DateTime
  }

type Article =
  { id :: ArticleId
  , feedId :: Maybe FeedId
  , url :: ArticleUrl
  , payload :: ArticlePayload
  , state :: ArticleState
  , savedAt :: DateTime
  , extractionStrategy :: ExtractionStrategy
  }
