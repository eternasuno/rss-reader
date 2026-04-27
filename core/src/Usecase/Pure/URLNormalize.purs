module Usecase.Pure.URLNormalize where

import Prelude

import Data.Either (Either, note)
import Data.Maybe (Maybe(..))
import Entity.ValueObject (URL(..))
import Port.AppError (AppError(..))

foreign import normalizeImpl :: (String -> Maybe String) -> (Maybe String) -> String -> Maybe String

normalize :: String -> Either AppError URL
normalize = map URL <<< note ParseError <<< normalizeImpl Just Nothing
