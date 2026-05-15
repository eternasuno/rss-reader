module Usecase.Article
  ( subscribeArticle
  ) where

import Prelude

import Data.Either (Either)
import Data.Maybe (Maybe(..))
import Entity.Article (ArticleId)
import Port.AppError (AppError(..))
import Port.Extractor as Extractor
import Port.Http as HTTP
import Port.Repository as Repository
import Run (AFF, Run)
import Run.Except (EXCEPT, rethrow, runExcept, throw)
import Type.Row (type (+))
import Usecase.Identify (generateArticleId)
import Usecase.URLNormalize (normalizeURL)

validateArticleExist :: forall r. ArticleId -> Run (Repository.REPOSITORY + EXCEPT AppError + r) Unit
validateArticleExist id = do
  articleMaybe <- rethrow =<< Repository.findArticle id
  case articleMaybe of
    Just _ -> throw (ExistError id)
    Nothing -> pure unit

subscribeArticle ∷ forall r. String → Run (Repository.REPOSITORY + Extractor.EXTRACTOR + HTTP.HTTP + AFF + r) (Either AppError Unit)
subscribeArticle rawURL = runExcept do
  url <- rethrow (normalizeURL rawURL)
  id <- generateArticleId url
  validateArticleExist id

  html <- rethrow =<< HTTP.fetchHtml url
  payload <- rethrow =<< Extractor.extract html
  let
    article =
      { id: id
      , url: url
      , payload: payload
      , state: { read: false, starred: true }
      }
  rethrow =<< Repository.saveArticles [ article ]
