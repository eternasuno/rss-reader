module Usecase.Identify
  ( generateArticleId
  , sha256Hex
  ) where

import Prelude

import Control.Promise (Promise, toAff)
import Effect.Aff (Aff)
import Entity.Article (ArticleId(..))
import Entity.ValueObject (URL(..))
import Run (AFF, Run, liftAff)
import Type.Row (type (+))

foreign import sha256HexImpl :: String -> Promise String

sha256Hex :: String -> Aff String
sha256Hex = toAff <<< sha256HexImpl

generateArticleId :: forall r. URL -> Run (AFF + r) ArticleId
generateArticleId (URL url) = liftAff (ArticleId <$> sha256Hex url)
