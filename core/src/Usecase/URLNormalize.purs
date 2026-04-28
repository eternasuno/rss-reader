module Usecase.URLNormalize
  ( normalize
  ) where

import Prelude

import Data.Either (Either, note)
import Data.Maybe (Maybe(..))
import Entity.ValueObject (URL(..))
import Port.AppError (AppError(..))

foreign import normalizeImpl :: (String -> Maybe String) -> (Maybe String) -> String -> Maybe String

normalize :: String -> Either AppError URL
normalize rawURL =
  note (ParseError ("Invalid URL: " <> rawURL)) $ URL <$> normalizeImpl Just Nothing rawURL
