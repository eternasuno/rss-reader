module Test.Mock.Data
  ( fixedInstant
  , mockPayload
  , validHTML
  ) where

import Data.DateTime.Instant (Instant, instant)
import Data.Maybe (Maybe(..), fromJust)
import Data.Time.Duration (Milliseconds(..))
import Entity.Article (ArticlePayload)
import Partial.Unsafe (unsafePartial)

fixedInstant :: Instant
fixedInstant =
  unsafePartial (fromJust (instant (Milliseconds 0.0)))

mockPayload :: ArticlePayload
mockPayload =
  { content: Just "<p>Test content</p>"
  , description: Just "Test description"
  , pubDate: fixedInstant
  , title: "Test Title"
  }

validHTML :: String
validHTML = "<html><head><title>Test Title</title></head><body><p>Test content</p></body></html>"
