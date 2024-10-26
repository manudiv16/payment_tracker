import gleam/option
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
  PaymentNotInserted(message: option.Option(String))
  CategoryNotFoundAndNotInserted
  DecodePaymentType
  CategoryNotInserted
}
