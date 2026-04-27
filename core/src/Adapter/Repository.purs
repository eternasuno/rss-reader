module Adapter.Repository where

import Prelude

import Control.Promise (Promise, toAff)
import Data.Argonaut.Core (Json)
import Data.Array (mapMaybe)
import Data.Bifunctor (lmap)
import Data.Codec.Argonaut as CA
import Data.Either (Either, hush)
import Data.Maybe (Maybe)
import Data.Newtype (unwrap)
import Data.Nullable (Nullable, toMaybe)
import Effect.Aff (Aff, try)
import Entity.Article (Article, ArticleId)
import Port.AppError (AppError(..))
import Port.Repository (ArticleQuery, RepositoryF(..))
import Usecase.Pure.Codecs (articleCodec, articleQueryCodec)

foreign import saveArticlesImpl :: Array Json -> Promise Unit
foreign import removeArticlesImpl :: Array String -> Promise Unit
foreign import updateArticleStarredImpl :: Boolean -> String -> Promise Unit
foreign import updateArticleReadImpl :: Boolean -> String -> Promise Unit
foreign import getArticleImpl :: String -> Promise (Nullable Json)
foreign import queryArticlesImpl :: Json -> Promise (Array Json)

toAff' :: forall a. Promise a -> Aff (Either AppError a)
toAff' promise = lmap (const RepositoryError) <$> try (toAff promise)

decodeArticle :: Json -> Maybe Article
decodeArticle = hush <<< CA.decode articleCodec

saveArticles :: Array Article -> Aff (Either AppError Unit)
saveArticles articles = toAff' (saveArticlesImpl json)
  where
  json = CA.encode articleCodec <$> articles

removeArticles :: Array ArticleId -> Aff (Either AppError Unit)
removeArticles articleIds = toAff' (removeArticlesImpl (unwrap <$> articleIds))

updateArticleStarred :: Boolean -> ArticleId -> Aff (Either AppError Unit)
updateArticleStarred starred articleId = toAff' (updateArticleStarredImpl starred (unwrap articleId))

updateArticleRead :: Boolean -> ArticleId -> Aff (Either AppError Unit)
updateArticleRead read articleId = toAff' (updateArticleReadImpl read (unwrap articleId))

getArticle :: ArticleId -> Aff (Maybe Article)
getArticle articleId = do
  articleJson <- toAff (getArticleImpl (unwrap articleId))
  pure (toMaybe articleJson >>= decodeArticle)

queryArticles :: ArticleQuery -> Aff (Array Article)
queryArticles articleQuery = do
  let json = CA.encode articleQueryCodec articleQuery
  articleJsonArray <- toAff (queryArticlesImpl json)
  pure (mapMaybe decodeArticle articleJsonArray)

handleRepository :: RepositoryF ~> Aff
handleRepository = case _ of
  SaveArticles articles next -> saveArticles articles <#> next
  RemoveArticles articleIds next -> removeArticles articleIds <#> next
  UpdateArticleStarred starred articleId next -> updateArticleStarred starred articleId <#> next
  UpdateArticleRead read articleId next -> updateArticleRead read articleId <#> next
  GetArticle articleId next -> getArticle articleId <#> next
  QueryArticles articleQuery next -> queryArticles articleQuery <#> next
