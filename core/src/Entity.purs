module Entity where

import Data.DateTime (DateTime)
import Data.Maybe (Maybe)
import Data.Time.Duration (Minutes)
import Node.URL (URL)

newtype FolderId = FolderId String

newtype FeedId = FeedId String

newtype ArticleId = ArticleId String 

newtype FeedUrl = FeedUrl URL

newtype ArticleUrl = ArticleUrl URL

data ReadStatus = Read | Unread

data StarStatus = Starred | Unstarred

type ArticleState = { read :: ReadStatus, star :: StarStatus }

type FetchSchedule =
  { currentInterval :: Minutes
  , nextFetchAt :: DateTime
  , unreadThreshold :: Int
  , retentionLimit :: Int
  }

type ContentPayload =
  { title :: String
  , htmlBody :: String
  , textSnippet :: Maybe String
  }

type Folder =
  { id :: FolderId
  , name :: String
  , sortOrder :: Int
  }

type Feed =
  { id :: FeedId
  , folderId :: Maybe FolderId
  , title :: String
  , url :: FeedUrl
  , siteUrl :: String
  , schedule :: FetchSchedule
  }

type Article =
  { id :: ArticleId
  , feedId :: Maybe FeedId
  , url :: ArticleUrl
  , content :: ContentPayload
  , state :: ArticleState
  , publishedAt :: DateTime
  , savedAt :: DateTime
  }
