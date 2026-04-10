module Usecase.Pure.URLNormalize where

import Prelude

import Data.Either (Either, note)
import Data.Maybe (Maybe(..))
import Entity.Article (ArticleUrl(..))
import Entity.Feed (FeedUrl(..))
import Port.AppError (AppError(..))

foreign import normalizeImpl :: (String -> Maybe String) -> (Maybe String) -> String -> Maybe String

normalize :: String -> Either AppError String
normalize = note ParseError <<< normalizeImpl Just Nothing

normalizeArticleUrl :: String -> Either AppError ArticleUrl
normalizeArticleUrl url = ArticleUrl <$> normalize url

normalizeFeedUrl :: String -> Either AppError FeedUrl
normalizeFeedUrl url = FeedUrl <$> normalize url
