module Test.Specs.Usecase.Article where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Entity.Article (ArticleId(..))
import Entity.ValueObject (URL(..))
import Port.AppError (AppError(..))
import Test.Mock.Data (mockPayload)
import Test.Mock.Adapter (defaultTestEnvironmentConfig, runUsecaseWithTestEnvironment)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail)
import Usecase.SaveArticle (subscribeArticle)

spec :: Spec Unit
spec = describe "Test Usecase Article" do
  describe "subscribeArticle" do
    it "should return unit on success" do
      result <- runUsecaseWithTestEnvironment (defaultTestEnvironmentConfig Nothing) (subscribeArticle "https://example.com/article")
      case result of
        Right unit -> pure unit
        other -> fail ("Expected success but got: " <> show other)

    it "should return ExistError if the article already exists" do
      let
        existingArticle =
          { id: ArticleId "some-id"
          , url: URL "https://example.com/article"
          , payload: mockPayload
          , state: { read: false, starred: true }
          }
      result <- runUsecaseWithTestEnvironment (defaultTestEnvironmentConfig (Just existingArticle)) (subscribeArticle "https://example.com/article")
      case result of
        Left (ExistError _) -> pure unit
        other -> fail ("Expected ExistError but got: " <> show other)

    it "should return HTTPError when the HTTP fetch fails" do
      let httpError = HTTPError (URL "https://example.com/article") "connection refused"
      let
        defaultEnvironmentConfig = defaultTestEnvironmentConfig Nothing
        testEnvironmentConfig = defaultEnvironmentConfig { htmlResult = Left httpError }
      result <- runUsecaseWithTestEnvironment testEnvironmentConfig (subscribeArticle "https://example.com/article")
      case result of
        Left (HTTPError _ _) -> pure unit
        other -> fail ("Expected HTTPError but got: " <> show other)

    it "should return ExtractorError when extraction fails" do
      let extractError = ExtractorError "failed to parse content"
      let
        defaultEnvironmentConfig = defaultTestEnvironmentConfig Nothing
        testEnvironmentConfig = defaultEnvironmentConfig { payloadResult = Left extractError }
      result <- runUsecaseWithTestEnvironment testEnvironmentConfig (subscribeArticle "https://example.com/article")
      case result of
        Left (ExtractorError _) -> pure unit
        other -> fail ("Expected ExtractorError but got: " <> show other)

    it "should return ParseError for an invalid URL" do
      result <- runUsecaseWithTestEnvironment (defaultTestEnvironmentConfig Nothing) (subscribeArticle "not a url")
      case result of
        Left (ParseError _) -> pure unit
        other -> fail ("Expected ParseError but got: " <> show other)
