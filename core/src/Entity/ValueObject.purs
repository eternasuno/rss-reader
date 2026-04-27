module Entity.ValueObject where

import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)

newtype URL = URL String

derive instance newtypeURL :: Newtype URL _

type CSSSelector =
  { content :: String
  , description :: Maybe String
  , pubDate :: Maybe String
  , title :: Maybe String
  }

data ExtractionStrategy = AutoDetect | CSSSelector CSSSelector
