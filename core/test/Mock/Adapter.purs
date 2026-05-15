module Test.Mock.Adapter
  ( TestEnvironmentConfig
  , defaultTestEnvironmentConfig
  , runUsecaseWithTestEnvironment
  ) where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe)
import Effect.Aff (Aff)
import Entity.Article (Article, ArticlePayload)
import Port.AppError (AppError)
import Port.Extractor as Extractor
import Port.Http as HTTP
import Port.Repository as Repository
import Run (Run)
import Run as Run
import Test.Mock.Data (mockPayload, validHTML)
import Test.Mock.Adapter.Extractor (handleExtractorMock)
import Test.Mock.Adapter.Http (handleHttpMock)
import Test.Mock.Adapter.Repository (RepositoryMockConfig, defaultRepositoryMockConfig, handleRepositoryMock)

type TestEnvironmentConfig =
  { repositoryMockConfig :: RepositoryMockConfig
  , htmlResult :: Either AppError String
  , payloadResult :: Either AppError ArticlePayload
  }

defaultTestEnvironmentConfig :: Maybe Article -> TestEnvironmentConfig
defaultTestEnvironmentConfig existingArticle =
  { repositoryMockConfig: defaultRepositoryMockConfig existingArticle
  , htmlResult: Right validHTML
  , payloadResult: Right mockPayload
  }

runUsecaseWithTestEnvironment
  :: forall a
   . TestEnvironmentConfig
  -> Run
       ( aff :: Aff
       , extractor :: Extractor.ExtractorF
       , http :: HTTP.HttpF
       , repository :: Repository.RepositoryF
       )
       a
  -> Aff a
runUsecaseWithTestEnvironment testEnvironmentConfig usecase =
  usecase
    # Run.interpret (Run.on Repository.repositoryProxy (handleRepositoryMock testEnvironmentConfig.repositoryMockConfig) Run.send)
    # Run.interpret (Run.on HTTP.httpProxy (handleHttpMock testEnvironmentConfig.htmlResult) Run.send)
    # Run.interpret (Run.on Extractor.extractorProxy (handleExtractorMock testEnvironmentConfig.payloadResult) Run.send)
    # Run.runBaseAff
