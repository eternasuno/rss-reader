module Adapter.HTTP.Fetch where

import Prelude

import Control.Promise (Promise, toAffE)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Encode (encodeJson)
import Data.Tuple (Tuple)
import Effect (Effect)
import Effect.Aff (Aff)
import Entity.ValueObject (URL(..))

foreign import data Response :: Type

foreign import fetchImpl :: String -> Json -> Effect (Promise Response)

foreign import textImpl :: Response -> Effect (Promise String)

type Header = Tuple String String

type RequestInit = { headers :: Array Header }

fetch :: URL -> RequestInit -> Aff Response
fetch (URL url) = toAffE <<< fetchImpl url <<< encodeJson

text :: Response -> Aff String
text = toAffE <<< textImpl
