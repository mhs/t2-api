class Api::V1::BaseController < ApplicationController

  def window_start
    return unless header = request.headers['X-Window-Start']
    @window_start ||= Date.parse(header)
  end

  def window_end
    return unless header = request.headers['X-Window-End']
    @window_end ||= Date.parse(header)
  end

end
