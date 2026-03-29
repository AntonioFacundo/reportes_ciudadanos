# frozen_string_literal: true

module Admin
  class AuditRepo
    def list_recent
      SystemAuditLog.includes(:actor).recent
    end
  end
end
