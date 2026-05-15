module Adapter.Extractor.Readability where

import Prelude

import Adapter.Codec (articlePayloadCodec)
import Control.Monad.Error.Class (try)
import Data.Argonaut (Json)
import Data.Bifunctor (lmap)
import Data.Codec.Argonaut as CA
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
  pure (CA.decode articlePayloadCodec json)
  where
  mapError result = (lmap (\_ -> ParseError "Failed to parse article payload")) =<< (lmap (ExtractorError <<< message) result)
