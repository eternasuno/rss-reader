module Port.Http where

import Prelude

import Data.Either (Either)
import Entity.ValueObject (URL)
import Port.AppError (AppError)
import Run (Run)
import Run as Run
import Type.Proxy (Proxy(..))

data HttpF a = FetchHtml URL (Either AppError String -> a)

derive instance functorHttpF :: Functor HttpF

type HTTP r = (http :: HttpF | r)

liftHttp :: forall r a. HttpF a -> Run (HTTP r) a
liftHttp = Run.lift (Proxy :: Proxy "http")

fetchHtml :: forall r. URL -> Run (HTTP r) (Either AppError String)
fetchHtml url = liftHttp (FetchHtml url identity)
