module Usecase.Article where

import Prelude

import Control.Bind (bindFlipped)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Entity.Article (Article, ArticleId)
import Entity.ValueObject (ExtractionStrategy)
import Port.AppError (AppError(..))
import Port.Http (HTTP, fetchHtml)
import Port.Repository as Repository
import Port.Time (TIME, now)
import Run (Run)
import Run.Except (rethrow, runExcept)
import Type.Row (type (+))
import Usecase.HTMLExtract (extractHTML)
import Usecase.Identify (deriveArticleId)
import Usecase.URLNormalize (normalize)

vaildateArticleExist :: forall r. ArticleId -> Run (Repository.REPOSITORY r) (Either AppError Unit)
vaildateArticleExist id = do
  article <- Repository.getArticle id
  pure case article of
    Just _ -> Left (ExistError id)
    Nothing -> Right unit

subscribeArticle :: forall r. ExtractionStrategy -> String -> Run (Repository.REPOSITORY + HTTP + TIME + r) (Either AppError Article)
subscribeArticle strategy rawURL = runExcept do
  url <- rethrow (normalize rawURL)
  let id = deriveArticleId url
  rethrow =<< vaildateArticleExist id
  payload <- rethrow =<< bindFlipped (extractHTML strategy) <$> fetchHtml url
  currentTime <- now
  let
    article =
      { id: id
      , url: url
      , payload: payload
      , state: { read: false, starred: true }
      , savedAt: currentTime
      , extractionStrategy: strategy
      }
  rethrow =<< Repository.saveArticles [ article ]
  pure article

getUnreadArticles :: forall r. Run (Repository.REPOSITORY r) (Array Article)
getUnreadArticles = Repository.queryArticles { read: Just false, starred: Nothing, sortBy: Repository.SortByPubDateDesc }

markArticleRead ∷ forall r. ArticleId → Run (Repository.REPOSITORY r) (Either AppError Unit)
markArticleRead = Repository.updateArticleRead true

markArticleUnread ∷ forall r. ArticleId → Run (Repository.REPOSITORY r) (Either AppError Unit)
markArticleUnread = Repository.updateArticleRead false

markArticleStarred ∷ forall r. ArticleId → Run (Repository.REPOSITORY r) (Either AppError Unit)
markArticleStarred = Repository.updateArticleStarred true

markArticleUnstarred ∷ forall r. ArticleId → Run (Repository.REPOSITORY r) (Either AppError Unit)
markArticleUnstarred = Repository.updateArticleStarred false

removeArticles ∷ forall r. Array ArticleId → Run (Repository.REPOSITORY r) (Either AppError Unit)
removeArticles = Repository.removeArticles
