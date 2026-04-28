module Test.Mock.Data
  ( fixedDateTime
  , mkArticle
  , mkPayload
  , validHTML
  , validHTMLForAuto
  , validHTMLForCSSSelector
  , validSelector
  ) where

import Data.DateTime (DateTime)
import Data.DateTime.Instant (instant, toDateTime)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))
import Entity.Article (Article, ArticleId, ArticlePayload)
import Entity.ValueObject (CSSSelector, ExtractionStrategy, URL)
import Partial.Unsafe (unsafeCrashWith)

validHTMLForAuto :: String
validHTMLForAuto =
  "<html><head><title>Auto Title</title><meta name=\"description\" content=\"Auto Description\"></head><body><article><p>This is a long paragraph for readability extraction. It contains enough text to pass the threshold and should be recognized as article content.</p></article></body></html>"

validHTMLForCSSSelector :: String
validHTMLForCSSSelector =
  "<html><body><main class=\"article-body\"><p>Hello from selector.</p></main><p class=\"summary\">Summary text</p><time class=\"published\">2024-01-02T03:04:05.000Z</time><h1 class=\"title\">Selector Title</h1></body></html>"

validHTML :: String
validHTML =
  "<html><body><main class=\"article-body\"><p>Hello from article usecase test.</p></main><p class=\"summary\">Summary from selector</p><time class=\"published\">2024-01-02T03:04:05.000Z</time><h1 class=\"title\">Article Usecase Title</h1></body></html>"

validSelector :: CSSSelector
validSelector =
  { content: "main.article-body"
  , description: Just ".summary"
  , pubDate: Just ".published"
  , title: Just ".title"
  }

fixedDateTime :: DateTime
fixedDateTime = case instant (Milliseconds 1704164645000.0) of
  Just instantValue -> toDateTime instantValue
  Nothing -> unsafeCrashWith "invalid fixed datetime"

mkPayload :: String -> ArticlePayload
mkPayload title =
  { content: Just "<p>Existing content</p>"
  , description: Just "Existing description"
  , pubDate: fixedDateTime
  , title: title
  }

mkArticle :: ArticleId -> URL -> ExtractionStrategy -> String -> Article
mkArticle articleId url strategy title =
  { id: articleId
  , url: url
  , payload: mkPayload title
  , state: { read: false, starred: false }
  , savedAt: fixedDateTime
  , extractionStrategy: strategy
  }
