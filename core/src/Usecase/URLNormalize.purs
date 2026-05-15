module Usecase.URLNormalize
  ( normalizeURL
  ) where

import Prelude

import Data.Either (Either, note)
import Data.Maybe (Maybe(..))
import Entity.ValueObject (URL(..))
import Port.AppError (AppError(..))

foreign import normalizeURLImpl :: (String -> Maybe String) -> (Maybe String) -> String -> Maybe String

normalizeURL :: String -> Either AppError URL
normalizeURL rawURL =
  note (ParseError ("Invalid URL: " <> rawURL)) (URL <$> normalizeURLImpl Just Nothing rawURL)
