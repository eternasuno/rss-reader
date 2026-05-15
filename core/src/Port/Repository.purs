module Port.Repository where

import Prelude

import Data.Either (Either)
import Data.Maybe (Maybe)
import Entity.Article (Article, ArticleId)
import Port.AppError (AppError)
import Run (Run)
import Run as Run
import Type.Proxy (Proxy(..))

foreign import data ObservableArticles :: Type

type ArticlePatch =
  { state ::
      { read :: Maybe Boolean
      , starred :: Maybe Boolean
      }
  }

type ArticleQuery =
  { onlyUnread :: Boolean
  , sortPubDateDesc :: Boolean
  }

data RepositoryF a
  = SaveArticles (Array Article) (Either AppError Unit -> a)
  | RemoveArticles (Array ArticleId) (Either AppError Unit -> a)
  | PatchArticles (Array ArticleId) ArticlePatch (Either AppError Unit -> a)
  | FindArticle ArticleId (Either AppError (Maybe Article) -> a)
  | ObserveArticles ArticleQuery (Either AppError ObservableArticles -> a)

derive instance functorRepositoryF :: Functor RepositoryF

type REPOSITORY r = (repository :: RepositoryF | r)

repositoryProxy = Proxy :: Proxy "repository"

liftRepo :: forall r a. RepositoryF a -> Run (REPOSITORY r) a
liftRepo = Run.lift repositoryProxy

saveArticles :: forall r. Array Article -> Run (REPOSITORY r) (Either AppError Unit)
saveArticles articles = liftRepo (SaveArticles articles identity)

removeArticles :: forall r. Array ArticleId -> Run (REPOSITORY r) (Either AppError Unit)
removeArticles articleIds = liftRepo (RemoveArticles articleIds identity)

patchArticles :: forall r. (Array ArticleId) -> ArticlePatch -> Run (REPOSITORY r) (Either AppError Unit)
patchArticles ids patch = liftRepo (PatchArticles ids patch identity)

findArticle :: forall r. ArticleId -> Run (REPOSITORY r) (Either AppError (Maybe Article))
findArticle articleId = liftRepo (FindArticle articleId identity)

observeArticles :: forall r. ArticleQuery -> Run (REPOSITORY r) (Either AppError ObservableArticles)
observeArticles query = liftRepo (ObserveArticles query identity)
