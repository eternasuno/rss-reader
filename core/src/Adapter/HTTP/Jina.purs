module Adapter.HTTP.Jina
  ( handleHttp
  ) where

import Prelude

import Adapter.HTTP.Fetch (Header, fetch, text)
import Data.Bifunctor (lmap)
import Data.Either (Either)
import Data.Maybe (Maybe, maybe)
import Data.Tuple (Tuple(..))
import Effect.Aff (Aff, message, try)
import Entity.ValueObject (URL(..))
import Port.AppError (AppError(..))
import Port.Http (HTTP, HttpF(..), httpProxy)
import Run (AFF, Run, interpret, liftAff, on, send)
import Type.Row (type (+))

mkHeaders :: Maybe String -> Array Header
mkHeaders key = authHeader <> baseHeaders
  where
  authHeader = maybe [] (\k -> [ Tuple "Authorization" ("Bearer " <> k) ]) key
  baseHeaders =
    [ Tuple "X-Return-Format" "html"
    , Tuple "X-Remove-Selector" "script, style, noscript, nav, footer, header, form, .ad, .ads, .advertisement, .social-share, .cookie-banner, .cookie-consent, .modal, .popup, #comments, .comments, #disqus_thread, #carbonads"
    ]

fetchHtml :: Maybe String -> URL -> Aff (Either AppError String)
fetchHtml key target@(URL u) = lmap (\err -> HTTPError target (message err)) <$> try do
  let url = URL ("https://r.jina.ai/" <> u)
  let headers = mkHeaders key
  response <- fetch url { headers }
  text response

handleHttp :: forall r. Maybe String -> Run (HTTP + AFF + r) ~> Run (AFF + r)
handleHttp key = interpret (on httpProxy handle send)
  where
  handle :: HttpF ~> Run (AFF + r)
  handle (FetchHtml url reply) = liftAff (fetchHtml key url <#> reply)
