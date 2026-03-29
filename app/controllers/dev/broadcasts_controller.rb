# frozen_string_literal: true

module Dev
  class BroadcastsController < ActionController::Base
    skip_before_action :verify_authenticity_token

    def report
      head :not_found and return unless Rails.env.development?

      report = Report.find(params[:id])
      stream_name = report.to_gid_param
      ActionCable.server.broadcast(stream_name, '<turbo-stream action="refresh"></turbo-stream>')
      render plain: "Broadcast sent to #{stream_name}. If the report tab refreshed, delivery works."
    end
  end
end
