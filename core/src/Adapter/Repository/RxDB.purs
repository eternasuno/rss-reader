module Adapter.Repository.RxDB where

import Prelude

import Control.Promise (Promise, toAffE)
import Data.Argonaut (Json, decodeJson, encodeJson)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toMaybe)
import Effect (Effect)
import Effect.Aff (Aff, attempt, message)
import Entity.Article (Article, ArticleId)
import Port.AppError (AppError(..))
import Port.Repository (ArticlePatch, ArticleQuery, ObservableArticles, REPOSITORY, RepositoryF(..), repositoryProxy)
import Run (AFF, Run, interpret, liftAff, on, send)
import Type.Row (type (+))

toAffE' ∷ forall a. Effect (Promise a) → Aff (Either AppError a)
toAffE' ep = lmap (RepositoryError <<< message) <$> attempt (toAffE ep)

foreign import saveArticlesImpl :: Array Json -> Effect (Promise Unit)

saveArticles :: Array Article -> Aff (Either AppError Unit)
saveArticles = toAffE' <<< saveArticlesImpl <<< map encodeJson

foreign import removeArticlesImpl :: Array ArticleId -> Effect (Promise Unit)

removeArticles :: Array ArticleId -> Aff (Either AppError Unit)
removeArticles = toAffE' <<< removeArticlesImpl

foreign import patchArticlesImpl :: Array ArticleId -> Json -> Effect (Promise Unit)

patchArticles :: Array ArticleId -> ArticlePatch -> Aff (Either AppError Unit)
patchArticles articleIds = toAffE' <<< patchArticlesImpl articleIds <<< encodeJson

foreign import findArticleImpl :: ArticleId -> Effect (Promise (Nullable Json))

findArticle :: ArticleId -> Aff (Either AppError (Maybe Article))
findArticle id = do
  result <- toAffE' (findArticleImpl id)
  pure $ result >>= \nullableJson -> case toMaybe nullableJson of
    Nothing -> Right Nothing
    Just json -> case decodeJson json of
      Left _ -> Left (RepositoryError "Failed to decode article JSON")
      Right article -> Right (Just article)

foreign import observeArticlesImpl :: ArticleQuery -> Effect (Promise (ObservableArticles))

observeArticles :: ArticleQuery -> Aff (Either AppError ObservableArticles)
observeArticles = toAffE' <<< observeArticlesImpl

handleRepository :: forall r. Run (REPOSITORY + AFF + r) ~> Run (AFF + r)
handleRepository = interpret (on repositoryProxy handle send)
  where
  handle :: RepositoryF ~> Run (AFF + r)
  handle (SaveArticles articles reply) = liftAff (saveArticles articles <#> reply)
  handle (RemoveArticles articleIds reply) = liftAff (removeArticles articleIds <#> reply)
  handle (PatchArticles articleIds patch reply) = liftAff (patchArticles articleIds patch <#> reply)
  handle (FindArticle articleId reply) = liftAff (findArticle articleId <#> reply)
  handle (ObserveArticles query reply) = liftAff (observeArticles query <#> reply)
