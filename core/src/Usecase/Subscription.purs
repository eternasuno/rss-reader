module Usecase.Subscription where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.DateTime (adjust)
import Data.List (singleton)
import Data.Time.Duration (Minutes(..))
import Effect.Unsafe (unsafePerformEffect)
import Entity (ArticleId, FeedId(..), FeedUrl(..), ReadStatus(..), StarStatus(..))
import Node.URL as URL
import Port (AppError(..), HTTP, REPO, TIME, fetchHtml, fetchRSS, saveArticles, saveFeed, updateArticleState, deleteFeed, now)
import Run (Run)
import Usecase.PureLogic (extractContent, generateArticleId, normalizeArticleUrl, normalizeFeedUrl)

subscribeFeed
  :: forall r
   . String
  -> Run (REPO (HTTP (TIME r))) (Either AppError FeedId)
subscribeFeed rawFeedUrl
  | not (URL.canParse rawFeedUrl "") = pure (Left ParseError)
  | otherwise = do
      let normalizedFeedUrl@(FeedUrl normalizedFeedUrlValue) = normalizeFeedUrl rawFeedUrl
      probeResult <- fetchRSS normalizedFeedUrl
      case probeResult of
        Left appError -> pure (Left appError)
        Right _ -> do
          currentTime <- now
          let
            generatedFeedId = FeedId ("feed:" <> unsafePerformEffect (URL.href normalizedFeedUrlValue))
            initialSchedule =
              { currentInterval: Minutes 30.0
              , nextFetchAt: fromMaybe currentTime (adjust (Minutes 30.0) currentTime)
              , unreadThreshold: 20
              , retentionLimit: 500
              }
          saveFeed
            { id: generatedFeedId
            , folderId: Nothing
            , title: unsafePerformEffect (URL.href normalizedFeedUrlValue)
            , url: normalizedFeedUrl
            , siteUrl: URL.origin normalizedFeedUrlValue
            , schedule: initialSchedule
            }
          pure (Right generatedFeedId)

unsubscribeFeed :: forall r. FeedId -> Run (REPO r) Unit
unsubscribeFeed feedId = deleteFeed feedId

addBookmarkDirectly
  :: forall r
   . String
  -> Run (REPO (HTTP (TIME r))) (Either AppError ArticleId)
addBookmarkDirectly rawArticleUrl
  | not (URL.canParse rawArticleUrl "") = pure (Left ParseError)
  | otherwise = do
      let normalizedArticleUrl = normalizeArticleUrl rawArticleUrl
      fetchResult <- fetchHtml normalizedArticleUrl
      case fetchResult of
        Left appError -> pure (Left appError)
        Right htmlBody ->
          case extractContent normalizedArticleUrl htmlBody of
            Left appError -> pure (Left appError)
            Right extractedContent -> do
              currentTime <- now
              let generatedArticleId = generateArticleId normalizedArticleUrl
              saveArticles
                ( singleton
                    { id: generatedArticleId
                    , feedId: Nothing
                    , url: normalizedArticleUrl
                    , content: extractedContent
                    , state: { read: Unread, star: Starred }
                    , publishedAt: currentTime
                    , savedAt: currentTime
                    }
                )
              pure (Right generatedArticleId)

toggleReadStatus
  :: forall r
   . ArticleId
  -> Run (REPO (TIME r)) Unit
toggleReadStatus articleId =
  updateArticleState articleId { read: Read, star: Unstarred }

toggleStarStatus
  :: forall r
   . ArticleId
  -> Run (REPO r) Unit
toggleStarStatus articleId =
  updateArticleState articleId { read: Unread, star: Starred }
