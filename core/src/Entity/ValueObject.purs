module Entity.ValueObject where

import Data.Maybe (Maybe)

type CSSSelector =
  { title :: Maybe String
  , description :: Maybe String
  , content :: String
  , pubDate :: Maybe String
  }

data ExtractionStrategy = AutoDetect | CSSSelector CSSSelector
