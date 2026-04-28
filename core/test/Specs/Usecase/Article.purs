module Test.Specs.Usecase.Article where

import Prelude

import Data.Array as Array
import Data.Either (Either(..))
import Data.Functor.Variant (VariantF, case_, on)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Ref as Ref
import Entity.Article (Article)
import Entity.ValueObject (ExtractionStrategy(..), URL(..))
import Port.AppError (AppError(..))
import Port.Http (HttpF, httpProxy)
import Port.Repository (RepositoryF, repositoryProxy)
import Port.Time (TimeF, timeProxy)
import Run as Run
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Test.Mock.Data (mkArticle, validHTML, validSelector)
import Test.Mock.Http (handleHttpMock)
import Test.Mock.RepositoryMock (handleRepositoryMock)
import Test.Mock.Time (handleTimeMock)
import Usecase.Article (getUnreadArticles, markArticleRead, markArticleStarred, markArticleUnread, markArticleUnstarred, removeArticles, subscribeArticle)
import Usecase.Identify (deriveArticleId)

handleArticleEffects
  :: Ref.Ref (Array Article)
  -> Either AppError String
  -> VariantF (repository :: RepositoryF, http :: HttpF, time :: TimeF) ~> Aff
handleArticleEffects articleRef htmlResult =
  on repositoryProxy (handleRepositoryMock articleRef)
    $ on httpProxy (handleHttpMock htmlResult)
    $ on timeProxy handleTimeMock
    $ case_

spec :: Spec Unit
spec = describe "Test Usecase Article" do
  describe "subscribeArticle" do
    it "should add one article" do
      let strategy = CSSSelector validSelector
      let rawURL = "https://example.com/article?utm_source=newsletter"
      articleRef <- liftEffect $ Ref.new []
      _ <- Run.interpret (handleArticleEffects articleRef (Right validHTML)) (subscribeArticle strategy rawURL)
      articles <- liftEffect $ Ref.read articleRef

      Array.length articles `shouldEqual` 1

    it "should return ExistError when article already exists" do
      let strategy = CSSSelector validSelector
      let rawURL = "https://example.com/existing"
      let normalizedURL = URL rawURL
      let existingId = deriveArticleId normalizedURL
      let existingArticle = mkArticle existingId normalizedURL strategy "Existing"
      articleRef <- liftEffect $ Ref.new [ existingArticle ]
      result <- Run.interpret (handleArticleEffects articleRef (Right validHTML)) (subscribeArticle strategy rawURL)

      case result of
        Left (ExistError articleId) -> articleId `shouldEqual` existingId
        Left _ -> fail "subscribeArticle should return ExistError"
        Right _ -> fail "subscribeArticle should fail when article exists"

    it "should return ParseError for invalid URL" do
      articleRef <- liftEffect $ Ref.new []
      result <- Run.interpret (handleArticleEffects articleRef (Right validHTML)) (subscribeArticle AutoDetect "not a url")

      case result of
        Left (ParseError message) -> message `shouldEqual` "Invalid URL: not a url"
        Left _ -> fail "subscribeArticle should return ParseError"
        Right _ -> fail "subscribeArticle should fail for invalid URL"

  describe "markArticleRead" do
    it "should mark an article as read" do
      let url = URL "https://example.com/read"
      let articleId = deriveArticleId url
      let initialArticle = mkArticle articleId url AutoDetect "Read"
      articleRef <- liftEffect $ Ref.new [ initialArticle ]
      _ <- Run.interpret (on repositoryProxy (handleRepositoryMock articleRef) case_) (markArticleRead articleId)
      articles <- liftEffect $ Ref.read articleRef

      Array.length articles `shouldEqual` 1

  describe "markArticleUnread" do
    it "should mark an article as unread" do
      let url = URL "https://example.com/unread"
      let articleId = deriveArticleId url
      let initialArticle = mkArticle articleId url AutoDetect "Unread"
      articleRef <- liftEffect $ Ref.new [ initialArticle ]
      result <- Run.interpret (on repositoryProxy (handleRepositoryMock articleRef) case_) (markArticleUnread articleId)

      case result of
        Left _ -> fail "markArticleUnread should succeed"
        Right _ -> pure unit

  describe "markArticleStarred" do
    it "should mark an article as starred" do
      let url = URL "https://example.com/starred"
      let articleId = deriveArticleId url
      let initialArticle = mkArticle articleId url AutoDetect "Starred"
      articleRef <- liftEffect $ Ref.new [ initialArticle ]
      result <- Run.interpret (on repositoryProxy (handleRepositoryMock articleRef) case_) (markArticleStarred articleId)

      case result of
        Left _ -> fail "markArticleStarred should succeed"
        Right _ -> pure unit

  describe "markArticleUnstarred" do
    it "should mark an article as unstarred" do
      let url = URL "https://example.com/unstarred"
      let articleId = deriveArticleId url
      let initialArticle = mkArticle articleId url AutoDetect "Unstarred"
      articleRef <- liftEffect $ Ref.new [ initialArticle ]
      result <- Run.interpret (on repositoryProxy (handleRepositoryMock articleRef) case_) (markArticleUnstarred articleId)

      case result of
        Left _ -> fail "markArticleUnstarred should succeed"
        Right _ -> pure unit

  describe "getUnreadArticles" do
    it "should return unread articles" do
      let url = URL "https://example.com/unread-list"
      let articleId = deriveArticleId url
      let initialArticle = mkArticle articleId url AutoDetect "Unread List"
      articleRef <- liftEffect $ Ref.new [ initialArticle ]
      result <- Run.interpret (on repositoryProxy (handleRepositoryMock articleRef) case_) getUnreadArticles

      Array.length result `shouldEqual` 1

  describe "removeArticles" do
    it "should remove an article by id" do
      let url = URL "https://example.com/remove"
      let articleId = deriveArticleId url
      let initialArticle = mkArticle articleId url AutoDetect "Remove"
      articleRef <- liftEffect $ Ref.new [ initialArticle ]
      _ <- Run.interpret (on repositoryProxy (handleRepositoryMock articleRef) case_) (removeArticles [ articleId ])
      articles <- liftEffect $ Ref.read articleRef

      Array.length articles `shouldEqual` 0
