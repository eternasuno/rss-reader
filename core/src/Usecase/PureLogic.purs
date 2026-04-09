module Usecase.PureLogic where

import Prelude

import Data.Either (Either(..))
import Data.Foldable (foldr)
import Data.List (List(..), any, filter)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Minutes(..))
import Effect.Unsafe (unsafePerformEffect)
import Entity (Article, ArticleId(..), ArticleUrl(..), ContentPayload, FeedUrl(..), ReadStatus(..))
import Node.URL as URL
import Port (AppError(..))

normalizeFeedUrl :: String -> FeedUrl
normalizeFeedUrl rawUrl = FeedUrl (normalizeUrl rawUrl)

normalizeArticleUrl :: String -> ArticleUrl
normalizeArticleUrl rawUrl = ArticleUrl (normalizeUrl rawUrl)

generateArticleId :: ArticleUrl -> ArticleId
generateArticleId (ArticleUrl articleUrl) =
  ArticleId ("article:" <> unsafePerformEffect (URL.href articleUrl))

extractContent :: ArticleUrl -> String -> Either AppError ContentPayload
extractContent (ArticleUrl articleUrl) htmlBody =
  if htmlBody == "" then
    Left ExtractError
  else
    Right
      { title: unsafePerformEffect (URL.href articleUrl)
      , htmlBody
      , textSnippet: Nothing
      }

data SyncAction
  = ToInsert Article
  | ToUpdate Article
  | ToDelete ArticleId

calculateSyncDiff :: List Article -> List Article -> List SyncAction
calculateSyncDiff existingArticles fetchedArticles =
  let
    insertActions = map ToInsert (filter (isNewArticle existingArticles) fetchedArticles)
    updateActions = map ToUpdate (filter (isExistingArticle existingArticles) fetchedArticles)
    deleteActions = map (ToDelete <<< _.id) (filter (isDeletedArticle fetchedArticles) existingArticles)
  in
    insertActions <> updateActions <> deleteActions

calculateNextSchedule :: Minutes -> Boolean -> Int -> Int -> Minutes
calculateNextSchedule (Minutes currentInterval) hasNewContent unreadCount unreadThreshold =
  let
    minimumInterval = 5.0
    maximumInterval = 240.0
    nextInterval
      | hasNewContent = max minimumInterval (currentInterval / 2.0)
      | unreadCount >= unreadThreshold = min maximumInterval (currentInterval * 1.5)
      | otherwise = min maximumInterval (currentInterval * 1.2)
  in
    Minutes nextInterval

normalizeUrl :: String -> URL.URL
normalizeUrl rawUrl = unsafePerformEffect do
  let defaultUrl = "https://localhost/"
  parsedUrl <- if URL.canParse rawUrl "" then URL.new rawUrl else URL.new defaultUrl
  URL.setHash "" parsedUrl
  URL.setSearch "" parsedUrl
  pure parsedUrl

articleIdToString :: ArticleId -> String
articleIdToString (ArticleId rawArticleId) = rawArticleId

isNewArticle :: List Article -> Article -> Boolean
isNewArticle existingArticles fetchedArticle =
  not (any (hasSameArticleId fetchedArticle.id) existingArticles)

isExistingArticle :: List Article -> Article -> Boolean
isExistingArticle existingArticles fetchedArticle =
  any (hasSameArticleId fetchedArticle.id) existingArticles

isDeletedArticle :: List Article -> Article -> Boolean
isDeletedArticle fetchedArticles existingArticle =
  not (any (hasSameArticleId existingArticle.id) fetchedArticles)

hasSameArticleId :: ArticleId -> Article -> Boolean
hasSameArticleId targetArticleId article =
  articleIdToString targetArticleId == articleIdToString article.id

collectArticlesToPersist :: List SyncAction -> List Article
collectArticlesToPersist = foldr collectActionArticle Nil
  where
  collectActionArticle syncAction collectedArticles =
    case syncAction of
      ToInsert article -> Cons article collectedArticles
      ToUpdate article -> Cons article collectedArticles
      ToDelete _ -> collectedArticles

isInsertAction :: SyncAction -> Boolean
isInsertAction syncAction =
  case syncAction of
    ToInsert _ -> true
    _ -> false

countUnread :: Int -> Article -> Int
countUnread unreadCount article =
  case article.state.read of
    Unread -> unreadCount + 1
    Read -> unreadCount
