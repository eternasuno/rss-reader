module Test.Specs.Usecase.HTMLExtract where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Entity.ValueObject (ExtractionStrategy(..))
import Port.AppError (AppError(..))
import Test.Mock.Data (validHTMLForAuto, validHTMLForCSSSelector, validSelector)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Usecase.HTMLExtract (extractAuto, extractCSSSelector, extractHTML)

extractErrorMessage :: forall a. Either AppError a -> Maybe String
extractErrorMessage result = case result of
  Left (ExtractError message) -> Just message
  _ -> Nothing

spec :: Spec Unit
spec = describe "Test Usecase HTMLExtract" do
  describe "extractAuto" do
    it "should extract payload from valid HTML" do
      case extractAuto validHTMLForAuto of
        Left _ -> fail "extractAuto should succeed for valid HTML"
        Right payload ->
          payload.title `shouldEqual` "Auto Title"

    it "should return ExtractError for invalid HTML" do
      let result = extractAuto ""
      extractErrorMessage result `shouldEqual` Just "failed to extract article from HTML"

  describe "extractCSSSelector" do
    it "should extract payload by CSS selectors" do
      case extractCSSSelector validSelector validHTMLForCSSSelector of
        Left _ -> fail "extractCSSSelector should succeed for valid selectors"
        Right payload -> do
          payload.content `shouldEqual` Just "<p>Hello from selector.</p>"
          payload.description `shouldEqual` Just "Summary text"
          payload.title `shouldEqual` "Selector Title"

    it "should return ExtractError when content selector does not match" do
      let
        selector =
          { content: ".not-exist"
          , description: Nothing
          , pubDate: Nothing
          , title: Nothing
          }
      let result = extractCSSSelector selector validHTMLForCSSSelector
      extractErrorMessage result `shouldEqual` Just "failed to extract article from HTML"

  describe "extractHTML" do
    it "should use extractAuto for AutoDetect strategy" do
      let resultFromStrategy = extractHTML AutoDetect validHTMLForAuto
      let resultFromDirect = extractAuto validHTMLForAuto
      case resultFromStrategy, resultFromDirect of
        Right fromStrategy, Right fromDirect ->
          fromStrategy.title `shouldEqual` fromDirect.title
        Left (ExtractError message1), Left (ExtractError message2) ->
          message1 `shouldEqual` message2
        _, _ -> fail "extractHTML AutoDetect should behave like extractAuto"

    it "should use extractCSSSelector for CSSSelector strategy" do
      let resultFromStrategy = extractHTML (CSSSelector validSelector) validHTMLForCSSSelector
      let resultFromDirect = extractCSSSelector validSelector validHTMLForCSSSelector
      case resultFromStrategy, resultFromDirect of
        Right fromStrategy, Right fromDirect -> do
          fromStrategy.content `shouldEqual` fromDirect.content
          fromStrategy.description `shouldEqual` fromDirect.description
          fromStrategy.title `shouldEqual` fromDirect.title
        Left (ExtractError message1), Left (ExtractError message2) ->
          message1 `shouldEqual` message2
        _, _ -> fail "extractHTML CSSSelector should behave like extractCSSSelector"
