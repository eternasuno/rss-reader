module Test.Mock.Adapter.Http
  ( handleHttpMock
  ) where

import Prelude

import Data.Either (Either)
import Port.AppError (AppError)
import Port.Http (HttpF(..))
import Run (Run)

handleHttpMock :: forall r a. Either AppError String -> HttpF a -> Run r a
handleHttpMock htmlResult (FetchHtml _ next) = pure (next htmlResult)
