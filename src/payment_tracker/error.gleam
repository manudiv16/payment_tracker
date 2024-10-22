import sqlight

pub type AppError {
  NotFound
  MethodNotAllowed
  UserNotFound
  CategoryNotFound
  PaymentNotFound
  BadRequest
  UnprocessableEntity
  ContentRequired
  SqlightError(sqlight.Error)
  UserAlreadyExists
  PaymentNotInserted
  CategoryNotFoundAndNotInserted
  DecodePaymentType
}
