module Usecase.Article where

import Prelude

import Control.Bind (bindFlipped)
import Control.Monad.Except (ExceptT(..), runExceptT)
import Control.Monad.Trans.Class (lift)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Entity.Article (Article, ArticleId, ArticlePayload, ArticleUrl, ReadStatus(..), StarStatus(..))
import Entity.ValueObject (ExtractionStrategy)
import Port.AppError (AppError(..))
import Port.Http (HTTP, fetchHtml)
import Port.Repository (REPOSITORY, getArticle)
import Port.Time (TIME, now)
import Run (Run)
import Usecase.Pure.HTMLParse (extractHTML)
import Usecase.Pure.Identify (deriveArticleId)
import Usecase.Pure.URLNormalize (normalizeArticleUrl)

prepare :: forall r. String -> Run (REPOSITORY r) (Either AppError (Tuple ArticleId ArticleUrl))
prepare rawURL = case normalizeArticleUrl rawURL of
  Left err -> pure (Left err)
  Right url -> do
    let id = deriveArticleId url
    article <- getArticle id
    pure $ case article of
      Just _ -> Left ExistError
      Nothing -> Right (Tuple id url)

fetchAndExtract :: forall r. ExtractionStrategy -> ArticleUrl -> Run (HTTP r) (Either AppError ArticlePayload)
fetchAndExtract strategy url = bindFlipped (extractHTML strategy) <$> fetchHtml url

subscribeArticle :: forall r. String -> ExtractionStrategy -> Run (REPOSITORY (HTTP (TIME r))) (Either AppError Article)
subscribeArticle rawURL strategy = runExceptT do
  Tuple id url <- ExceptT (prepare rawURL)
  payload <- ExceptT (fetchAndExtract strategy url)
  currentTime <- lift now
  pure
    { id: id
    , feedId: Nothing
    , url: url
    , payload: payload
    , state: { read: Unread, star: Starred }
    , savedAt: currentTime
    , extractionStrategy: strategy
    }
