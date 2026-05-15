module Port.Extractor where

import Prelude

import Data.Either (Either)
import Entity.Article (ArticlePayload)
import Port.AppError (AppError)
import Run (Run)
import Run as Run
import Type.Proxy (Proxy(..))

data ExtractorF a = Extract String (Either AppError ArticlePayload -> a)

derive instance functorExtractorF :: Functor ExtractorF

type EXTRACTOR r = (extractor :: ExtractorF | r)

extractorProxy = Proxy :: Proxy "extractor"

liftExtractor :: forall r a. ExtractorF a -> Run (EXTRACTOR r) a
liftExtractor = Run.lift extractorProxy

extract :: forall r. String -> Run (EXTRACTOR r) (Either AppError ArticlePayload)
extract html = liftExtractor (Extract html identity)
