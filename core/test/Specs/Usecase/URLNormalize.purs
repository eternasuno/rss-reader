module Test.Specs.Usecase.URLNormalize where

import Prelude

import Data.Array.NonEmpty as NEA
import Data.Either (Either(..))
import Data.Foldable (intercalate)
import Entity.ValueObject (URL(..))
import Port.AppError (AppError(..))
import Test.QuickCheck ((===), (<?>))
import Test.QuickCheck.Arbitrary (arbitrary)
import Test.QuickCheck.Gen (Gen, arrayOf1, elements)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Test.Spec.QuickCheck (quickCheck)
import Usecase.URLNormalize (normalizeURL)

trackingKeys :: NEA.NonEmptyArray String
trackingKeys = NEA.cons' "utm_source"
  [ "utm_medium"
  , "utm_campaign"
  , "mc_eid"
  , "pd_rd_r"
  , "spm"
  , "fbclid"
  , "gclid"
  , "dclid"
  , "gbraid"
  , "wbraid"
  , "msclkid"
  , "igshid"
  , "_hsenc"
  , "_hsmi"
  , "mkt_tok"
  , "ref"
  , "ref_src"
  , "ref_url"
  , "smid"
  ]

genTrackingParams ∷ Gen String
genTrackingParams = intercalate "&" <$> arrayOf1 ado
  key <- elements trackingKeys
  value <- arbitrary :: Gen Int
  in key <> "=" <> show value

spec :: Spec Unit
spec = describe "Test Usecase URLNormalize" do
  describe "normalize" do
    it "should remove multiple tracking parameters" $ quickCheck do
      params <- genTrackingParams
      let rawURL = "https://example.com/article?id=42&" <> params <> "#section"
      pure case normalizeURL rawURL of
        Left _ -> false <?> "normalize should succeed for generated valid URL"
        Right (URL normalizedURL) -> normalizedURL === "https://example.com/article?id=42"

    it "should return ParseError for invalid URL" do
      let rawURL = "not a url"
      case normalizeURL rawURL of
        Left (ParseError message) -> message `shouldEqual` "Invalid URL: not a url"
        Left _ -> fail "normalize should return ParseError for invalid URL"
        Right _ -> fail "normalize should fail for invalid URL"
