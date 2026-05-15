module Test.Mock.Adapter.Extractor
  ( handleExtractorMock
  ) where

import Prelude

import Data.Either (Either)
import Entity.Article (ArticlePayload)
import Port.AppError (AppError)
import Port.Extractor (ExtractorF(..))
import Run (Run)

handleExtractorMock :: forall r a. Either AppError ArticlePayload -> ExtractorF a -> Run r a
handleExtractorMock payloadResult (Extract _ next) = pure (next payloadResult)
