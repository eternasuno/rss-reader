module Port.AppError where

import Prelude

import Data.Argonaut (class EncodeJson, encodeJson)
import Entity.Article (ArticleId)
import Entity.ValueObject (URL)

data AppError
  = HTTPError URL String
  | ParseError String
  | NotFound String
  | ExtractorError String
  | ExistError ArticleId
  | RepositoryError String

instance showAppError :: Show AppError where
  show (HTTPError url err) = "HTTP error for URL " <> show url <> ": " <> err
  show (ParseError err) = "Parse error: " <> err
  show (NotFound entity) = "Not found: " <> entity
  show (ExtractorError err) = "Extractor error: " <> err
  show (ExistError articleId) = "Article already exists with ID: " <> show articleId
  show (RepositoryError err) = "Repository error: " <> err

instance encodeJsonAppError :: EncodeJson AppError where
  encodeJson = encodeJson <<< show
