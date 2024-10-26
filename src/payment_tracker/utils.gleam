import gleam/list
import gleam/pgo.{type Returned}

pub fn get_if_not_empty_entity(
  query: Result(Returned(a), _),
  error: c,
  f: fn(a) -> Result(b, _),
) -> List(Result(b, c)) {
  case query {
    Ok(pgo.Returned(count, rows)) ->
      case count < 1 {
        True -> [Error(error)]
        False ->
          rows
          |> list.map(f)
      }
    _ -> [Error(error)]
  }
}

pub fn get_id_entity(
  query: Result(Returned(a), _),
  error: c,
  f: fn(a) -> Result(b, _),
) -> List(Result(b, c)) {
  case query {
    Ok(pgo.Returned(_, rows)) ->
      rows
      |> list.map(f)
    _ -> [Error(error)]
  }
}

pub fn get_entity(
  query: Result(Returned(a), _),
  error: c,
  f: fn(a) -> b,
) -> Result(List(b), c) {
  case query {
    Ok(pgo.Returned(count, rows)) ->
      case count < 1 {
        True -> Error(error)
        False ->
          rows
          |> list.map(f)
          |> Ok
      }
    _ -> Error(error)
  }
}
