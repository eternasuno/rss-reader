module Usecase.Pure.Identify where

import Entity.Article (ArticleId(..), ArticleUrl(..))

foreign import sha256HexImpl :: String -> String

deriveArticleId :: ArticleUrl -> ArticleId
deriveArticleId (ArticleUrl cleanUrl) = ArticleId hashHex
  where
  hashHex = sha256HexImpl cleanUrl
