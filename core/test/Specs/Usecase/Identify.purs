module Test.Specs.Usecase.Identify where

import Prelude

import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Usecase.Identify (sha256Hex)

spec :: Spec Unit
spec = describe "Test Usecase Identify" do
  describe "sha256Hex" do
    it "should correctly handle empty strings" do
      result <- sha256Hex ""
      result `shouldEqual` "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

    it "should correctly handle standard short string 'abc'" do
      result <- sha256Hex "abc"
      result `shouldEqual` "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"

    it "should correctly handle long sentences (The quick brown fox...)" do
      result <- sha256Hex "The quick brown fox jumps over the lazy dog"
      result `shouldEqual` "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"

    it "should produce the same output for the same input (determinism check)" do
      let input = "purescript-is-fun"
      res1 <- sha256Hex input
      res2 <- sha256Hex input
      res1 `shouldEqual` res2
