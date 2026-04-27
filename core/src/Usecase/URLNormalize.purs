module Usecase.URLNormalize where

import Prelude

import Data.Either (Either, note)
import Data.Maybe (Maybe(..))
import Entity.ValueObject (URL(..))
import Port.AppError (AppError(..))

foreign import normalizeImpl :: (String -> Maybe String) -> (Maybe String) -> String -> Maybe String

normalize :: String -> Either AppError URL
normalize rawURL =
  map URL <<< note (ParseError ("Invalid URL: " <> rawURL)) <<< normalizeImpl Just Nothing $ rawURL
