module Entity.ValueObject where

import Prelude

import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)

newtype URL = URL String

derive instance newtypeURL :: Newtype URL _
derive newtype instance showURL :: Show URL

type CSSSelector =
  { content :: String
  , description :: Maybe String
  , pubDate :: Maybe String
  , title :: Maybe String
  }

data ExtractionStrategy = AutoDetect | CSSSelector CSSSelector
