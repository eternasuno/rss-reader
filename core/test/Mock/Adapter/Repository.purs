module Test.Mock.Adapter.Repository
  ( handleRepositoryMock
  , defaultRepositoryMockConfig
  , RepositoryMockConfig
  ) where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe)
import Entity.Article (Article)
import Port.AppError (AppError(..))
import Port.Repository (RepositoryF(..))
import Run (Run)

type RepositoryMockConfig =
  { findArticleResult :: Either AppError (Maybe Article)
  , saveArticlesResult :: Either AppError Unit
  , patchArticleResult :: Either AppError Unit
  , removeArticlesResult :: Either AppError Unit
  }

defaultRepositoryMockConfig :: Maybe Article -> RepositoryMockConfig
defaultRepositoryMockConfig existingArticle =
  { findArticleResult: Right existingArticle
  , saveArticlesResult: Right unit
  , patchArticleResult: Right unit
  , removeArticlesResult: Right unit
  }

handleRepositoryMock :: forall r a. RepositoryMockConfig -> RepositoryF a -> Run r a
handleRepositoryMock repositoryMockConfig = case _ of
  SaveArticles _ next -> pure (next repositoryMockConfig.saveArticlesResult)
  RemoveArticles _ next -> pure (next repositoryMockConfig.removeArticlesResult)
  PatchArticles _ _ next -> pure (next repositoryMockConfig.patchArticleResult)
  FindArticle _ next -> pure (next repositoryMockConfig.findArticleResult)
  ObserveArticles _ next -> pure (next (Left (RepositoryError "ObserveArticles is not supported in repository tests")))
