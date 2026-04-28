module Test.Specs.Usecase.URLNormalize where

import Prelude

import Data.Either (Either(..))
import Entity.ValueObject (URL(..))
import Port.AppError (AppError(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Usecase.URLNormalize (normalize)

spec :: Spec Unit
spec = describe "Test Usecase URLNormalize" do
  describe "Test normalize" do
    it "should remove tracking parameters and hash" do
      let rawURL = "https://example.com/article?id=42&utm_source=newsletter&gclid=abc#section"
      case normalize rawURL of
        Left _ -> fail "normalize should succeed for a valid URL"
        Right (URL normalizedURL) ->
          normalizedURL `shouldEqual` "https://example.com/article?id=42"

    it "should return ParseError for invalid URL" do
      let rawURL = "not a url"
      case normalize rawURL of
        Left (ParseError message) ->
          message `shouldEqual` "Invalid URL: not a url"
        Left _ -> fail "normalize should return ParseError for invalid URL"
        Right _ -> fail "normalize should fail for invalid URL"
