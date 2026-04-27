module Entity.ValueObject where

import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)

newtype URL = URL String

derive instance newtypeURL :: Newtype URL _

type CSSSelector =
  { title :: Maybe String
  , description :: Maybe String
  , content :: String
  , pubDate :: Maybe String
  }

data ExtractionStrategy = AutoDetect | CSSSelector CSSSelector
