module Port.AppError where

data AppError
  = NetworkError
  | ParseError
  | NotFound
  | ExtractError
  | ExistError
  | RepositoryError
