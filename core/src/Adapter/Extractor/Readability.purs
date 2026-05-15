module Adapter.Extractor.Readability where

import Prelude

import Control.Monad.Error.Class (try)
import Data.Argonaut (Json, decodeJson)
import Data.Bifunctor (lmap)
import Data.Either (Either)
import Effect (Effect)
import Effect.Exception (message)
import Entity.Article (ArticlePayload)
import Port.AppError (AppError(..))

foreign import data Document :: Type

foreign import parseImpl :: Document -> Effect Json

parse ∷ Document → Effect (Either AppError ArticlePayload)
parse document = mapError <$> try do
  json <- parseImpl document
  pure (decodeJson json)
  where
  mapError result = (lmap (\_ -> ParseError "Failed to parse article payload")) =<< (lmap (ExtractorError <<< message) result)
