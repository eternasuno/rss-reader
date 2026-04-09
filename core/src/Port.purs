module Port where

import Prelude

import Data.DateTime (DateTime)
import Data.Either (Either)
import Data.List (List)
import Data.Maybe (Maybe)
import Entity as Entity
import Run (Run)
import Run as Run
import Type.Proxy (Proxy(..))

data AppError
  = NetworkError
  | ParseError
  | NotFound
  | ExtractError

data RepoF a
  = SaveFeed Entity.Feed a
  | DeleteFeed Entity.FeedId a
  | GetFeed Entity.FeedId (Maybe Entity.Feed -> a)
  | GetActiveFeeds DateTime (List Entity.Feed -> a)
  | SaveArticles (List Entity.Article) a
  | GetArticlesByFeed Entity.FeedId (List Entity.Article -> a)
  | UpdateArticleState Entity.ArticleId Entity.ArticleState a
  | DeleteOldArticles Entity.FeedId Int a

derive instance functorRepoF :: Functor RepoF

type REPO r = (repo :: RepoF | r)

data HttpF a
  = FetchRSS Entity.FeedUrl (Either AppError String -> a)
  | FetchHtml Entity.ArticleUrl (Either AppError String -> a)

derive instance functorHttpF :: Functor HttpF

type HTTP r = (http :: HttpF | r)

data TimeF a = Now (DateTime -> a)

derive instance functorTimeF :: Functor TimeF

type TIME r = (time :: TimeF | r)

_repo :: Proxy "repo"
_repo = Proxy

_http :: Proxy "http"
_http = Proxy

_time :: Proxy "time"
_time = Proxy

liftRepo :: forall r a. RepoF a -> Run (REPO r) a
liftRepo = Run.lift _repo

liftHttp :: forall r a. HttpF a -> Run (HTTP r) a
liftHttp = Run.lift _http

liftTime :: forall r a. TimeF a -> Run (TIME r) a
liftTime = Run.lift _time

saveFeed :: forall r. Entity.Feed -> Run (REPO r) Unit
saveFeed feed = liftRepo (SaveFeed feed unit)

deleteFeed :: forall r. Entity.FeedId -> Run (REPO r) Unit
deleteFeed feedId = liftRepo (DeleteFeed feedId unit)

getFeed :: forall r. Entity.FeedId -> Run (REPO r) (Maybe Entity.Feed)
getFeed feedId = liftRepo (GetFeed feedId identity)

getActiveFeeds :: forall r. DateTime -> Run (REPO r) (List Entity.Feed)
getActiveFeeds currentTime = liftRepo (GetActiveFeeds currentTime identity)

saveArticles :: forall r. List Entity.Article -> Run (REPO r) Unit
saveArticles articles = liftRepo (SaveArticles articles unit)

getArticlesByFeed :: forall r. Entity.FeedId -> Run (REPO r) (List Entity.Article)
getArticlesByFeed feedId = liftRepo (GetArticlesByFeed feedId identity)

updateArticleState :: forall r. Entity.ArticleId -> Entity.ArticleState -> Run (REPO r) Unit
updateArticleState articleId articleState =
  liftRepo (UpdateArticleState articleId articleState unit)

deleteOldArticles :: forall r. Entity.FeedId -> Int -> Run (REPO r) Unit
deleteOldArticles feedId retentionLimit =
  liftRepo (DeleteOldArticles feedId retentionLimit unit)

fetchRSS :: forall r. Entity.FeedUrl -> Run (HTTP r) (Either AppError String)
fetchRSS feedUrl = liftHttp (FetchRSS feedUrl identity)

fetchHtml :: forall r. Entity.ArticleUrl -> Run (HTTP r) (Either AppError String)
fetchHtml articleUrl = liftHttp (FetchHtml articleUrl identity)

now :: forall r. Run (TIME r) DateTime
now = liftTime (Now identity)
