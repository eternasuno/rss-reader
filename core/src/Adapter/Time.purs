module Server.Adapter.Time where

import Prelude

import Data.DateTime.Instant (toDateTime)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Now as Now
import Port.Time (TimeF(..))

handleTime :: TimeF ~> Aff
handleTime (Now next) = liftEffect Now.now <#> toDateTime <#> next
