module Gateway.Web where

import Prelude

import Adapter.Extractor.DOM (handleExtract)
import Adapter.HTTP.Jina (handleHttp)
import Adapter.Repository.RxDB (handleRepository)
import Control.Promise (Promise, fromAff)
import Data.Argonaut (Json, decodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, null, toMaybe, toNullable)
import Effect (Effect)
import Entity.Article (ArticleId)
import Port.AppError (AppError(..))
import Port.Repository (ArticleQuery, ObservableArticles)
import Port.Repository as Repository
import Run (runBaseAff, runBaseAff')
import Usecase.Article (subscribeArticle) as Article

newtype Result a = Result { tag :: String, value :: Nullable a, message :: String }

toResult ∷ forall a. Either AppError a → Result a
toResult e = Result case e of
  Left appError -> { tag: "error", value: null, message: show appError }
  Right value -> { tag: "success", value: toNullable (Just value), message: "" }

subscribeArticle ∷ Nullable String → String → Effect (Promise (Result Unit))
subscribeArticle key rawURL = fromAff $ run (Article.subscribeArticle rawURL <#> toResult)
  where
  run = runBaseAff' <<< handleRepository <<< handleHttp (toMaybe key) <<< handleExtract

patchArticles :: Array ArticleId → Json → Effect (Promise (Result Unit))
patchArticles ids json = fromAff $ run (result <#> toResult)
  where
  run = runBaseAff <<< handleRepository
  result = case decodeJson json of
    Left _ -> pure $ Left (ParseError "Failed to parse patch JSON")
    Right patch -> Repository.patchArticles ids patch

removeArticles :: Array ArticleId -> Effect (Promise (Result Unit))
removeArticles ids = fromAff $ run (Repository.removeArticles ids <#> toResult)
  where
  run = runBaseAff <<< handleRepository

observeArticles :: ArticleQuery -> Effect (Promise (Result ObservableArticles))
observeArticles query = fromAff $ run (Repository.observeArticles query <#> toResult)
  where
  run = runBaseAff <<< handleRepository
