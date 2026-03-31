module Main where

import Prelude

import Effect (Effect)
import Effect.Class.Console (logShow)
import Effect.Console (log)

main ∷ Effect Unit
main = do
  log "🍝"
  logShow (1 + 2)
