# frozen_string_literal: true

module Admin
  class SnapshotCapture < RageArch::UseCase::Base
    use_case_symbol :admin_snapshot_capture
    deps :snapshot_repo

    def call(params = {})
      snapshot_repo.capture!
      success(captured: true)
    end
  end
end
