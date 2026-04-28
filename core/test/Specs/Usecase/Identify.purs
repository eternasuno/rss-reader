module Test.Specs.Usecase.Identify where

import Prelude

import Entity.ValueObject (URL(..))
import Test.QuickCheck ((===), (/==))
import Test.Spec (Spec, describe, it)
import Test.Spec.QuickCheck (quickCheck)
import Usecase.Identify (deriveArticleId)

spec :: Spec Unit
spec = describe "Test Usecase Identify" do
  describe "Test deriveArticleId" do
    it "should generate same ArticleId for same URL" $ quickCheck \url ->
      deriveArticleId (URL url) === deriveArticleId (URL url)

    it "should generate different ArticleId for different URL" $ quickCheck \url1 url2 ->
      if url1 == url2 then deriveArticleId (URL url1) === deriveArticleId (URL url2)
      else deriveArticleId (URL url1) /== deriveArticleId (URL url2)
