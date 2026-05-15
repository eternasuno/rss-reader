module Test.Mock.Data
  ( fixedTimestamp
  , mockPayload
  , validHTML
  ) where

import Data.DateTime.Instant (instant)
import Data.Maybe (Maybe(..), fromJust)
import Data.Time.Duration (Milliseconds(..))
import Entity.Article (ArticlePayload)
import Entity.ValueObject (Timestamp(..))
import Partial.Unsafe (unsafePartial)

fixedTimestamp :: Timestamp
fixedTimestamp =
  unsafePartial (Timestamp (fromJust (instant (Milliseconds 0.0))))

mockPayload :: ArticlePayload
mockPayload =
  { content: Just "<p>Test content</p>"
  , description: Just "Test description"
  , pubDate: fixedTimestamp
  , title: "Test Title"
  }

validHTML :: String
validHTML = "<html><head><title>Test Title</title></head><body><p>Test content</p></body></html>"
