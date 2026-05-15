module Adapter.Codec where

import Prelude

import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Record as CAR
import Data.DateTime.Instant (Instant, instant, unInstant)
import Data.Newtype (unwrap)
import Data.Profunctor (dimap)
import Data.Time.Duration (Milliseconds(..))
import Entity.Article (Article, ArticleId(..), ArticlePayload)
import Entity.ValueObject (URL(..))
import Port.Repository (ArticlePatch)

instantCodec :: CA.JsonCodec Instant
instantCodec = CA.prismaticCodec "Instant" (instant <<< Milliseconds) (unwrap <<< unInstant) CA.number

articleIdCodec :: CA.JsonCodec ArticleId
articleIdCodec = dimap unwrap ArticleId CA.string

urlCodec :: CA.JsonCodec URL
urlCodec = dimap unwrap URL CA.string

articlePayloadCodec :: CA.JsonCodec ArticlePayload
articlePayloadCodec = CA.object "ArticlePayload" $ CAR.record
  { content: CAR.optional CA.string
  , description: CAR.optional CA.string
  , pubDate: instantCodec
  , title: CA.string
  }

articleCodec :: CA.JsonCodec Article
articleCodec = CA.object "Article" $ CAR.record
  { id: articleIdCodec
  , payload: articlePayloadCodec
  , state: CA.object "ArticleState" $ CAR.record
      { read: CA.boolean
      , starred: CA.boolean
      }
  , url: urlCodec
  }

articlePatchCodec :: CA.JsonCodec ArticlePatch
articlePatchCodec = CA.object "ArticlePatch" $ CAR.record
  { state: CA.object "ArticleStatePatch" $ CAR.record
      { read: CAR.optional CA.boolean
      , starred: CAR.optional CA.boolean
      }
  }
