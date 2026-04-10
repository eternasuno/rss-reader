module Port.Time where

import Prelude

import Data.DateTime (DateTime)
import Run (Run)
import Run as Run
import Type.Proxy (Proxy(..))

data TimeF a = Now (DateTime -> a)

derive instance functorTimeF :: Functor TimeF

type TIME r = (time :: TimeF | r)

liftTime :: forall r a. TimeF a -> Run (TIME r) a
liftTime = Run.lift (Proxy :: Proxy "time")

now :: forall r. Run (TIME r) DateTime
now = liftTime (Now identity)
