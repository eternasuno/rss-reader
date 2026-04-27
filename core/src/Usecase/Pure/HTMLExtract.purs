module Usecase.Pure.HTMLParse where

import Prelude

import Data.Argonaut.Core (Json)
import Data.Bifunctor (class Bifunctor, lmap)
import Data.Codec.Argonaut as CA
import Data.Either (Either)
import Entity.Article (ArticlePayload)
import Entity.ValueObject (CSSSelector, ExtractionStrategy(..))
import Port.AppError (AppError(..))
import Usecase.Pure.Codecs (articlePayloadCodec, cssSelectorCodec)

mapExtractError ∷ forall f a b. Bifunctor f ⇒ f a b → f AppError b
mapExtractError = lmap (const ExtractError)

foreign import extractAutoImpl :: String -> Json

extractAuto ∷ String → Either AppError ArticlePayload
extractAuto htmlString = mapExtractError $ CA.decode articlePayloadCodec (extractAutoImpl htmlString)

foreign import extractCSSSelectorImpl :: Json -> String -> Json

extractCSSSelector ∷ CSSSelector → String → Either AppError ArticlePayload
extractCSSSelector cssSelector htmlString = mapExtractError result
  where
  selectors = CA.encode cssSelectorCodec cssSelector
  result = CA.decode articlePayloadCodec (extractCSSSelectorImpl selectors htmlString)

extractHTML :: ExtractionStrategy -> String -> Either AppError ArticlePayload
extractHTML AutoDetect = extractAuto
extractHTML (CSSSelector cssSelector) = extractCSSSelector cssSelector
