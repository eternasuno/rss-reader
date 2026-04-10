module Entity.Feed where

import Data.DateTime (DateTime)

newtype FeedId = FeedId String

newtype FeedUrl = FeedUrl String

type FeedConfig =
  { maxUnread :: Int
  , maxRetention :: Int
  }

newtype ScheduleSteps = ScheduleSteps Int

type FeedSchedule =
  { steps :: ScheduleSteps
  , nextFetchAt :: DateTime
  }

type Feed =
  { id :: FeedId
  , title :: String
  , url :: FeedUrl
  , link :: String
  , config :: FeedConfig
  , schedule :: FeedSchedule
  }
