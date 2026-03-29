# frozen_string_literal: true

module Admin
  class AuditLogsIndex < RageArch::UseCase::Base
    use_case_symbol :admin_audit_logs_index
    deps :audit_repo

    def call(params = {})
      logs = audit_repo.list_recent
      success(logs: logs)
    end
  end
end
