module Port.AppError where

import Entity.Article (ArticleId)
import Entity.ValueObject (URL)

data AppError
  = NetworkError URL String
  | ParseError String
  | NotFound String
  | ExtractError String
  | ExistError ArticleId
  | RepositoryError String
