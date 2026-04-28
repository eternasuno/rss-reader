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
import Port.Http (HTTP, HttpF)
import Port.Repository (REPOSITORY, RepositoryF)
import Port.Time (TIME, TimeF)
import Run (Run)
import Run as Run
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Test.Mock.Data (mkArticle, validHTML, validSelector)
import Test.Mock.Http (handleHttpMock)
import Test.Mock.RepositoryMock (handleRepositoryMock)
import Test.Mock.Time (handleTimeMock)
import Type.Row (type (+))
import Type.Proxy (Proxy(..))
import Usecase.Article (getUnreadArticles, markArticleRead, markArticleStarred, markArticleUnread, markArticleUnstarred, removeArticles, subscribeArticle)
import Usecase.Identify (deriveArticleId)
import Usecase.URLNormalize (normalize)

_repository :: Proxy "repository"
_repository = Proxy

_http :: Proxy "http"
_http = Proxy

_time :: Proxy "time"
_time = Proxy

handleArticleEffects
  :: Ref.Ref (Array Article)
  -> Either AppError String
  -> VariantF (repository :: RepositoryF, http :: HttpF, time :: TimeF) ~> Aff
handleArticleEffects articleRef htmlResult =
  on _repository (handleRepositoryMock articleRef)
    $ on _http (handleHttpMock htmlResult)
    $ on _time handleTimeMock
    $ case_

runArticleProgram
  :: forall a
   . Array Article
  -> Either AppError String
  -> Run (REPOSITORY + HTTP + TIME + ()) a
  -> Aff { result :: a, articles :: Array Article }
runArticleProgram initialArticles htmlResult program = do
  articleRef <- liftEffect $ Ref.new initialArticles
  result <- Run.interpret (handleArticleEffects articleRef htmlResult) program
  articles <- liftEffect $ Ref.read articleRef
  pure { result, articles }

runRepositoryProgram
  :: forall a
   . Array Article
  -> Run (REPOSITORY + ()) a
  -> Aff { result :: a, articles :: Array Article }
runRepositoryProgram initialArticles program = do
  articleRef <- liftEffect $ Ref.new initialArticles
  result <- Run.interpret (on _repository (handleRepositoryMock articleRef) case_) program
  articles <- liftEffect $ Ref.read articleRef
  pure { result, articles }

spec :: Spec Unit
spec = describe "Test Usecase Article" do
  describe "Test subscribeArticle" do
    it "should subscribe article and persist as unread" do
      let strategy = CSSSelector validSelector
      let rawURL = "https://example.com/article?utm_source=newsletter"
      case normalize rawURL of
        Left _ -> fail "normalize should succeed in test setup"
        Right normalizedURL -> do
          output <- runArticleProgram [] (Right validHTML) do
            subscribed <- subscribeArticle strategy rawURL
            unread <- getUnreadArticles
            pure { subscribed, unread }

          case output.result.subscribed of
            Left _ -> fail "subscribeArticle should succeed"
            Right article -> do
              case article.url, normalizedURL of
                URL actualURL, URL expectedURL ->
                  actualURL `shouldEqual` expectedURL
              article.id `shouldEqual` deriveArticleId normalizedURL
              article.state.read `shouldEqual` false
              article.state.starred `shouldEqual` true

          Array.length output.result.unread `shouldEqual` 1
          Array.length output.articles `shouldEqual` 1

    it "should return ExistError when article already exists" do
      let strategy = CSSSelector validSelector
      let rawURL = "https://example.com/existing"
      case normalize rawURL of
        Left _ -> fail "normalize should succeed in test setup"
        Right normalizedURL -> do
          let existingId = deriveArticleId normalizedURL
          let existingArticle = mkArticle existingId normalizedURL strategy "Existing"
          output <- runArticleProgram [ existingArticle ] (Right validHTML) (subscribeArticle strategy rawURL)
          case output.result of
            Left (ExistError articleId) -> articleId `shouldEqual` existingId
            Left _ -> fail "subscribeArticle should return ExistError"
            Right _ -> fail "subscribeArticle should fail when article exists"

    it "should return ParseError for invalid URL" do
      output <- runArticleProgram [] (Right validHTML) (subscribeArticle AutoDetect "not a url")
      case output.result of
        Left (ParseError message) -> message `shouldEqual` "Invalid URL: not a url"
        Left _ -> fail "subscribeArticle should return ParseError"
        Right _ -> fail "subscribeArticle should fail for invalid URL"

  describe "Test repository forwarding functions" do
    it "should update read and starred flags, then remove article" do
      case normalize "https://example.com/flags" of
        Left _ -> fail "normalize should succeed in test setup"
        Right normalizedURL -> do
          let articleId = deriveArticleId normalizedURL
          let initialArticle = mkArticle articleId normalizedURL AutoDetect "Flags"

          output <- runRepositoryProgram [ initialArticle ] do
            readResult <- markArticleRead articleId
            unreadResult <- markArticleUnread articleId
            starredResult <- markArticleStarred articleId
            unstarredResult <- markArticleUnstarred articleId
            unreadBeforeRemove <- getUnreadArticles
            removeResult <- removeArticles [ articleId ]
            unreadAfterRemove <- getUnreadArticles
            pure
              { readResult
              , unreadResult
              , starredResult
              , unstarredResult
              , unreadBeforeRemove
              , removeResult
              , unreadAfterRemove
              }

          case output.result.readResult of
            Right _ -> pure unit
            Left _ -> fail "markArticleRead should succeed"
          case output.result.unreadResult of
            Right _ -> pure unit
            Left _ -> fail "markArticleUnread should succeed"
          case output.result.starredResult of
            Right _ -> pure unit
            Left _ -> fail "markArticleStarred should succeed"
          case output.result.unstarredResult of
            Right _ -> pure unit
            Left _ -> fail "markArticleUnstarred should succeed"
          case output.result.removeResult of
            Right _ -> pure unit
            Left _ -> fail "removeArticles should succeed"
          Array.length output.result.unreadBeforeRemove `shouldEqual` 1
          Array.length output.result.unreadAfterRemove `shouldEqual` 0
          Array.length output.articles `shouldEqual` 0
