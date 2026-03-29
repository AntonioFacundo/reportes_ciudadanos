# frozen_string_literal: true

module Admin
  class CitizensIndex < RageArch::UseCase::Base
    use_case_symbol :admin_citizens_index
    deps :citizen_repo

    def call(params = {})
      citizens = citizen_repo.list(q: params[:q], status: params[:status])
      total = citizens.count
      success(citizens: citizens, total: total)
    end
  end
end
