module Port.Repository where

import Prelude

import Data.Either (Either)
import Data.Maybe (Maybe)
import Entity.Article (Article, ArticleId)
import Port.AppError (AppError)
import Run (Run)
import Run as Run
import Type.Proxy (Proxy(..))

data ArticleSortOption = SortByPubDateDesc | SortByPubDateAsc

instance showArticleSortOption :: Show ArticleSortOption where
  show SortByPubDateDesc = "pub_date_desc"
  show SortByPubDateAsc = "pub_date_asc"

type ArticleQuery =
  { read :: Maybe Boolean
  , start :: Maybe Boolean
  , sortBy :: ArticleSortOption
  }

data RepositoryF a
  = SaveArticles (Array Article) (Either AppError Unit -> a)
  | RemoveArticles (Array ArticleId) (Either AppError Unit -> a)
  | UpdateArticleStarred Boolean ArticleId (Either AppError Unit -> a)
  | UpdateArticleRead Boolean ArticleId (Either AppError Unit -> a)
  | GetArticle ArticleId (Maybe Article -> a)
  | QueryArticles ArticleQuery (Array Article -> a)

derive instance functorRepositoryF :: Functor RepositoryF

type REPOSITORY r = (repository :: RepositoryF | r)

liftRepo :: forall r a. RepositoryF a -> Run (REPOSITORY r) a
liftRepo = Run.lift (Proxy :: Proxy "repository")

saveArticles :: forall r. Array Article -> Run (REPOSITORY r) (Either AppError Unit)
saveArticles articles = liftRepo (SaveArticles articles identity)

removeArticles :: forall r. Array ArticleId -> Run (REPOSITORY r) (Either AppError Unit)
removeArticles articleIds = liftRepo (RemoveArticles articleIds identity)

updateArticleStarred :: forall r. Boolean -> ArticleId -> Run (REPOSITORY r) (Either AppError Unit)
updateArticleStarred starred articleId =
  liftRepo (UpdateArticleStarred starred articleId identity)

updateArticleRead :: forall r. Boolean -> ArticleId -> Run (REPOSITORY r) (Either AppError Unit)
updateArticleRead read articleId =
  liftRepo (UpdateArticleRead read articleId identity)

getArticle :: forall r. ArticleId -> Run (REPOSITORY r) (Maybe Article)
getArticle articleId = liftRepo (GetArticle articleId identity)

queryArticles :: forall r. ArticleQuery -> Run (REPOSITORY r) (Array Article)
queryArticles articleQuery = liftRepo (QueryArticles articleQuery identity)
