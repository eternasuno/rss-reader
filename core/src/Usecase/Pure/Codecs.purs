module Usecase.Pure.Codecs where

import Prelude

import Data.Argonaut.Core (jsonNull, isNull)
import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Record as CAR
import Data.DateTime (DateTime)
import Data.DateTime.Instant (fromDateTime, instant, toDateTime, unInstant)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.Profunctor (dimap)
import Data.Time.Duration (Milliseconds(..))
import Entity.Article (ArticleId(..), ArticlePayload, Article)
import Entity.ValueObject (CSSSelector, ExtractionStrategy(..), URL(..))
import Port.Repository (ArticleSortOption(..), ArticleQuery)

toDateTime' :: Number -> Maybe DateTime
toDateTime' = (map toDateTime) <<< instant <<< Milliseconds

fromDateTime' :: DateTime -> Number
fromDateTime' dateTime = ms
  where
  (Milliseconds ms) = unInstant (fromDateTime dateTime)

foreign import parseDateTimeImpl :: (Number -> Maybe Number) -> Maybe Number -> String -> Maybe Number

parseDateTime :: String -> Maybe DateTime
parseDateTime str = parseDateTimeImpl Just Nothing str >>= toDateTime'

foreign import formatDateTimeImpl :: Number -> String

formatDateTime :: DateTime -> String
formatDateTime = formatDateTimeImpl <<< fromDateTime'

dateTimeCodec :: CA.JsonCodec DateTime
dateTimeCodec = CA.prismaticCodec "DateTime" parseDateTime formatDateTime CA.string

articlePayloadCodec :: CA.JsonCodec ArticlePayload
articlePayloadCodec = CA.object "ArticlePayload" $ CAR.record
  { title: CA.string
  , content: CAR.optional CA.string
  , description: CAR.optional CA.string
  , pubDate: dateTimeCodec
  }

cssSelectorCodec :: CA.JsonCodec CSSSelector
cssSelectorCodec = CA.object "CSSSelector" $ CAR.record
  { title: CAR.optional CA.string
  , description: CAR.optional CA.string
  , content: CA.string
  , pubDate: CAR.optional CA.string
  }

extractionStrategyCodec :: CA.JsonCodec ExtractionStrategy
extractionStrategyCodec = CA.codec decode encode
  where
  encode AutoDetect = jsonNull
  encode (CSSSelector selector) = CA.encode cssSelectorCodec selector
  decode json
    | isNull json = Right AutoDetect
    | otherwise = CSSSelector <$> CA.decode cssSelectorCodec json

articleIdCodec :: CA.JsonCodec ArticleId
articleIdCodec = dimap unwrap ArticleId CA.string

urlCodec :: CA.JsonCodec URL
urlCodec = dimap unwrap URL CA.string

type ArticleExtras = { extractionStrategy :: ExtractionStrategy }

extrasCodec :: CA.JsonCodec ArticleExtras
extrasCodec = CA.object "ArticleExtras" $ CAR.record
  { extractionStrategy: extractionStrategyCodec
  }

type ArticleDBSchema =
  { content :: Maybe String
  , description :: Maybe String
  , extras :: ArticleExtras
  , id :: ArticleId
  , pubDate :: DateTime
  , read :: Boolean
  , savedAt :: DateTime
  , starred :: Boolean
  , title :: String
  , url :: URL
  }

articleDBSchemaCodec :: CA.JsonCodec ArticleDBSchema
articleDBSchemaCodec = CA.object "ArticleDBSchema" $ CAR.record
  { content: CAR.optional CA.string
  , description: CAR.optional CA.string
  , extras: extrasCodec
  , id: articleIdCodec
  , pubDate: dateTimeCodec
  , read: CA.boolean
  , savedAt: dateTimeCodec
  , starred: CA.boolean
  , title: CA.string
  , url: urlCodec
  }

toArticle :: ArticleDBSchema -> Article
toArticle schema =
  { id: schema.id
  , url: schema.url
  , payload:
      { title: schema.title
      , description: schema.description
      , content: schema.content
      , pubDate: schema.pubDate
      }
  , state:
      { read: schema.read
      , starred: schema.starred
      }
  , extractionStrategy: schema.extras.extractionStrategy
  , savedAt: schema.savedAt
  }

fromArticle :: Article -> ArticleDBSchema
fromArticle article =
  { id: article.id
  , url: article.url
  , title: article.payload.title
  , description: article.payload.description
  , content: article.payload.content
  , pubDate: article.payload.pubDate
  , read: article.state.read
  , starred: article.state.starred
  , savedAt: article.savedAt
  , extras: { extractionStrategy: article.extractionStrategy }
  }

articleCodec :: CA.JsonCodec Article
articleCodec = dimap fromArticle toArticle articleDBSchemaCodec

articleSortOptionCodec :: CA.JsonCodec ArticleSortOption
articleSortOptionCodec = CA.prismaticCodec "ArticleSortOption" decode encode CA.string
  where
  encode SortByPubDateDesc = "pub_date_desc"
  encode SortByPubDateAsc = "pub_date_asc"
  decode "pub_date_desc" = Just SortByPubDateDesc
  decode "pub_date_asc" = Just SortByPubDateAsc
  decode _ = Nothing

articleQueryCodec :: CA.JsonCodec ArticleQuery
articleQueryCodec = CA.object "ArticleQuery" $ CAR.record
  { read: CAR.optional CA.boolean
  , start: CAR.optional CA.boolean
  , sortBy: articleSortOptionCodec
  }
