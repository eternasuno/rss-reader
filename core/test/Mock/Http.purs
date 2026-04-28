module Test.Mock.Http
  ( handleHttpMock
  ) where

import Prelude

import Data.Either (Either)
import Effect.Aff (Aff)
import Port.AppError (AppError)
import Port.Http (HttpF(..))

handleHttpMock :: Either AppError String -> HttpF ~> Aff
handleHttpMock htmlResult (FetchHtml _ next) = pure $ next htmlResult
