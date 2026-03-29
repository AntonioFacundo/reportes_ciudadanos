# frozen_string_literal: true

module Sessions
  class SessionRepo
    def find(id)
      Session.find_by(id: id)
    end

    def create_for_user(user, user_agent:, ip_address:)
      user.sessions.create!(user_agent: user_agent, ip_address: ip_address)
    end

    def destroy(session)
      session.destroy
    end
  end
end
