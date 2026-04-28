module Test.Mock.RepositoryMock
  ( handleRepositoryMock
  ) where

import Prelude

import Data.Array as Array
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Ref as Ref
import Entity.Article (Article)
import Port.AppError (AppError(..))
import Port.Repository (ArticleSortOption(..), RepositoryF(..))

handleRepositoryMock :: Ref.Ref (Array Article) -> RepositoryF ~> Aff
handleRepositoryMock articleRef = case _ of
  SaveArticles articles next -> do
    liftEffect $ Ref.modify_ (_ <> articles) articleRef
    pure $ next (Right unit)
  RemoveArticles articleIds next -> do
    liftEffect do
      Ref.modify_
        ( Array.filter \article ->
            not (Array.any (\targetId -> targetId == article.id) articleIds)
        )
        articleRef
    pure $ next (Right unit)
  UpdateArticleStarred starred articleId next -> do
    articles <- liftEffect $ Ref.read articleRef
    if Array.any (\article -> article.id == articleId) articles then do
      liftEffect do
        Ref.modify_
          ( map \article ->
              if article.id == articleId then article { state { starred = starred } }
              else article
          )
          articleRef
      pure $ next (Right unit)
    else
      pure $ next (Left (NotFound "article not found"))
  UpdateArticleRead read articleId next -> do
    articles <- liftEffect $ Ref.read articleRef
    if Array.any (\article -> article.id == articleId) articles then do
      liftEffect do
        Ref.modify_
          ( map \article ->
              if article.id == articleId then article { state { read = read } }
              else article
          )
          articleRef
      pure $ next (Right unit)
    else
      pure $ next (Left (NotFound "article not found"))
  GetArticle articleId next -> do
    articles <- liftEffect $ Ref.read articleRef
    pure $ next (Array.find (\article -> article.id == articleId) articles)
  QueryArticles query next -> do
    articles <- liftEffect $ Ref.read articleRef
    let
      filtered =
        Array.filter
          ( \article ->
              (query.read == Nothing || query.read == Just article.state.read)
                && (query.starred == Nothing || query.starred == Just article.state.starred)
          )
          articles

      sorted = case query.sortBy of
        SortByPubDateAsc -> Array.sortBy (comparing _.payload.pubDate) filtered
        SortByPubDateDesc -> Array.sortBy (flip (comparing _.payload.pubDate)) filtered
    pure $ next sorted
