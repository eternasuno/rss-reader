module Usecase.Syncing where

import Prelude

import Data.DateTime (adjust)
import Data.Either (Either(..))
import Data.Foldable (traverse_)
import Data.List (List(..), any, foldl, null)
import Data.Maybe (Maybe(..), fromMaybe)
import Entity (FeedId)
import Port (AppError(..), HTTP, REPO, TIME, fetchRSS, getActiveFeeds, getArticlesByFeed, getFeed, now, saveArticles, saveFeed, deleteOldArticles)
import Run (Run)
import Usecase.PureLogic (calculateNextSchedule, calculateSyncDiff, collectArticlesToPersist, countUnread, isInsertAction)

syncSingleFeed
  :: forall r
   . FeedId
  -> Run (REPO (HTTP (TIME r))) (Either AppError Unit)
syncSingleFeed feedId = do
  maybeFeed <- getFeed feedId
  case maybeFeed of
    Nothing -> pure (Left NotFound)
    Just feed -> do
      fetchResult <- fetchRSS feed.url
      case fetchResult of
        Left appError -> pure (Left appError)
        Right _ -> do
          currentTime <- now
          existingArticles <- getArticlesByFeed feed.id
          let
            fetchedArticles = Nil
            syncActions = calculateSyncDiff existingArticles fetchedArticles
            articlesToPersist = collectArticlesToPersist syncActions
            hasNewContent = any isInsertAction syncActions
            unreadArticleCount = foldl countUnread 0 existingArticles
            nextInterval =
              calculateNextSchedule
                feed.schedule.currentInterval
                hasNewContent
                unreadArticleCount
                feed.schedule.unreadThreshold
            nextFetchAt = fromMaybe currentTime (adjust nextInterval currentTime)
          if null articlesToPersist then
            pure unit
          else
            saveArticles articlesToPersist
          saveFeed
            ( feed
                { schedule =
                    feed.schedule
                      { currentInterval = nextInterval
                      , nextFetchAt = nextFetchAt
                      }
                }
            )
          enforceRetentionPolicy feed.id
          pure (Right unit)

fetchDueFeeds
  :: forall r
   . Run (REPO (HTTP (TIME r))) Unit
fetchDueFeeds = do
  currentTime <- now
  dueFeeds <- getActiveFeeds currentTime
  traverse_ (syncSingleFeed <<< _.id) dueFeeds

enforceRetentionPolicy
  :: forall r
   . FeedId
  -> Run (REPO r) Unit
enforceRetentionPolicy feedId = do
  maybeFeed <- getFeed feedId
  case maybeFeed of
    Nothing -> pure unit
    Just feed -> deleteOldArticles feedId feed.schedule.retentionLimit
