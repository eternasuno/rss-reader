module Port.Repository where

import Prelude

import Data.DateTime (DateTime)
import Data.Maybe (Maybe)
import Entity.Article (Article, ArticleId, ArticleState)
import Entity.Feed (Feed, FeedId)
import Run (Run)
import Run as Run
import Type.Proxy (Proxy(..))

data RepositoryF a
  = SaveFeed Feed a
  | DeleteFeed FeedId a
  | GetFeed FeedId (Maybe Feed -> a)
  | GetActiveFeeds DateTime (Array Feed -> a)
  | SaveArticles (Array Article) a
  | GetArticle ArticleId (Maybe Article -> a)
  | GetArticlesByFeed FeedId (Array Article -> a)
  | UpdateArticleState ArticleId ArticleState a
  | DeleteOldArticles FeedId Int a

derive instance functorRepositoryF :: Functor RepositoryF

type REPOSITORY r = (repository :: RepositoryF | r)

liftRepo :: forall r a. RepositoryF a -> Run (REPOSITORY r) a
liftRepo = Run.lift (Proxy :: Proxy "repository")

saveFeed :: forall r. Feed -> Run (REPOSITORY r) Unit
saveFeed feed = liftRepo (SaveFeed feed unit)

deleteFeed :: forall r. FeedId -> Run (REPOSITORY r) Unit
deleteFeed feedId = liftRepo (DeleteFeed feedId unit)

getFeed :: forall r. FeedId -> Run (REPOSITORY r) (Maybe Feed)
getFeed feedId = liftRepo (GetFeed feedId identity)

getActiveFeeds :: forall r. DateTime -> Run (REPOSITORY r) (Array Feed)
getActiveFeeds currentTime = liftRepo (GetActiveFeeds currentTime identity)

saveArticles :: forall r. Array Article -> Run (REPOSITORY r) Unit
saveArticles articles = liftRepo (SaveArticles articles unit)

getArticle :: forall r. ArticleId -> Run (REPOSITORY r) (Maybe Article)
getArticle articleId = liftRepo (GetArticle articleId identity)

getArticlesByFeed :: forall r. FeedId -> Run (REPOSITORY r) (Array Article)
getArticlesByFeed feedId = liftRepo (GetArticlesByFeed feedId identity)

updateArticleState :: forall r. ArticleId -> ArticleState -> Run (REPOSITORY r) Unit
updateArticleState articleId articleState =
  liftRepo (UpdateArticleState articleId articleState unit)

deleteOldArticles :: forall r. FeedId -> Int -> Run (REPOSITORY r) Unit
deleteOldArticles feedId retentionLimit =
  liftRepo (DeleteOldArticles feedId retentionLimit unit)
