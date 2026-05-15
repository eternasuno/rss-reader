module Adapter.Extractor.DOM
  ( handleExtract
  ) where

import Prelude

import Adapter.Extractor.Readability as Readability
import Control.Monad.Error.Class (try)
import Control.Monad.Except (ExceptT(..), runExceptT)
import Data.Bifunctor (lmap)
import Data.Either (Either)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Entity.Article (ArticlePayload)
import Port.AppError (AppError(..))
import Port.Extractor (ExtractorF(..), EXTRACTOR, extractorProxy)
import Run (EFFECT, Run, interpret, liftEffect, on, send)
import Type.Row (type (+))

foreign import parseImpl :: String -> Effect Readability.Document

foreign import sanitizeImpl :: String -> Effect String

parse :: String -> Effect (Either AppError Readability.Document)
parse str = lmap (\_ -> ParseError "Failed to parse document") <$> try (parseImpl str)

sanitize :: String -> Effect (Either AppError String)
sanitize str = lmap (\_ -> ExtractorError "Failed to sanitize HTML") <$> try (sanitizeImpl str)

extract ∷ String → Effect (Either AppError ArticlePayload)
extract str = runExceptT do
  document <- ExceptT (parse str)
  payload <- ExceptT (Readability.parse document)
  sanitizedContent <- case payload.content of
    Nothing -> pure Nothing
    Just content -> Just <$> ExceptT (sanitize content)
  pure payload { content = sanitizedContent }

handleExtract :: forall r. Run (EXTRACTOR + EFFECT + r) ~> Run (EFFECT + r)
handleExtract = interpret (on extractorProxy handle send)
  where
  handle :: ExtractorF ~> Run (EFFECT + r)
  handle (Extract string reply) = liftEffect (extract string <#> reply)
