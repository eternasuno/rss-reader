module Port.Http where

import Prelude

import Data.Either (Either)
import Entity.Article (ArticleUrl(..))
import Entity.Feed (FeedUrl(..))
import Port.AppError (AppError)
import Run (Run)
import Run as Run
import Type.Proxy (Proxy(..))

data HttpF a = GetText String (Either AppError String -> a)

derive instance functorHttpF :: Functor HttpF

type HTTP r = (http :: HttpF | r)

_http = Proxy :: Proxy "http"

fetchFeed :: forall r. FeedUrl -> Run (HTTP r) (Either AppError String)
fetchFeed (FeedUrl url) = Run.lift _http (GetText url identity)

fetchHtml :: forall r. ArticleUrl -> Run (HTTP r) (Either AppError String)
fetchHtml (ArticleUrl url) = Run.lift _http (GetText url identity)
