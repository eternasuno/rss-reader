module Adapter.Http where

import Prelude

import Control.Promise (Promise, toAff)
import Data.Bifunctor (lmap)
import Data.Either (Either)
import Effect.Aff (Aff, try)
import Entity.ValueObject (URL(..))
import Port.AppError (AppError(..))
import Port.Http (HttpF(..))

foreign import fetchHtmlImpl :: String -> Promise String

fetchHtml :: URL -> Aff (Either AppError String)
fetchHtml (URL url) = lmap (const NetworkError) <$> try (toAff (fetchHtmlImpl url))

handleHttp :: HttpF ~> Aff
handleHttp (FetchHtml url next) = fetchHtml url <#> next
