// import payment_tracker/router/category_router
import payment_tracker/router/payment_router
import payment_tracker/router/user_router
import payment_tracker/web.{type Context}

import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  case wisp.path_segments(req) {
    ["user"] -> user_router.user(req, ctx)
    ["payment"] -> payment_router.payment(req, ctx)
    ["payments", page, limit] -> payment_router.payments(req, ctx, page, limit)
    // ["categories"] -> category_router.categories(req, ctx)
    _ -> wisp.not_found()
  }
}
