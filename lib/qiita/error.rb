module Qiita

  class Error < StandardError; end
  class BadRequestError < Error; end
  class UnauthorizedError < Error; end
  class ForbiddenError < Error; end
  class NotFoundError < Error; end
  class NotAcceptableError < Error; end
  class UnprocessableEntityError < Error; end
  class InternalServerError < Error; end
  class ServiceUnavailableError < Error; end

  ERRORS = {
    400 => BadRequestError,
    401 => UnauthorizedError,
    403 => ForbiddenError,
    404 => NotFoundError,
    406 => NotAcceptableError,
    422 => UnprocessableEntityError,
    500 => InternalServerError,
    503 => ServiceUnavailableError
  }.freeze

end
