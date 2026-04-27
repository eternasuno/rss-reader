module Usecase.Pure.Identify where

import Entity.Article (ArticleId(..))
import Entity.ValueObject (URL(..))

foreign import sha256HexImpl :: String -> String

deriveArticleId :: URL -> ArticleId
deriveArticleId (URL url) = ArticleId (sha256HexImpl url)
