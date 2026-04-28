module Entity.ValueObject where

import Prelude

import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)

newtype URL = URL String

derive instance newtypeURL :: Newtype URL _
derive instance eqURL :: Eq URL
instance showURL :: Show URL where
  show (URL url) = url

type CSSSelector =
  { content :: String
  , description :: Maybe String
  , pubDate :: Maybe String
  , title :: Maybe String
  }

data ExtractionStrategy = AutoDetect | CSSSelector CSSSelector
