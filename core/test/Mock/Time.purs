module Test.Mock.Time
  ( handleTimeMock
  ) where

import Prelude

import Effect.Aff (Aff)
import Port.Time (TimeF(..))
import Test.Mock.Data (fixedDateTime)

handleTimeMock :: TimeF ~> Aff
handleTimeMock (Now next) = pure $ next fixedDateTime
