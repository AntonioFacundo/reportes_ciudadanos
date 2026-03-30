# frozen_string_literal: true

# Register your app's deps here. Deps are grouped by module (e.g. app/deps/posts/post_repo.rb → Posts::PostRepo).
# Use RageArch.register(:symbol, ClassName.new) or RageArch.register_ar(:symbol, Model) for AR-backed deps.

Rails.application.config.after_initialize do
  RageArch.register(:user_repo, Users::UserRepo.new)
  RageArch.register(:session_repo, Sessions::SessionRepo.new)
  RageArch.register(:report_repo, Reports::ReportRepo.new)
  RageArch.register(:report_broadcaster, Reports::ReportBroadcaster.new)
  RageArch.register(:alcaldia_repo, Admin::AlcaldiaRepo.new)
  RageArch.register(:category_repo, Admin::CategoryRepo.new)
  RageArch.register(:citizen_repo, Admin::CitizenRepo.new)
  RageArch.register(:snapshot_repo, Admin::SnapshotRepo.new)
  RageArch.register(:analytics_repo, Admin::AnalyticsRepo.new)
  RageArch.register(:dashboard_repo, Admin::DashboardRepo.new)
  RageArch.register(:audit_repo, Admin::AuditRepo.new)
  RageArch.register(:state_repo, Admin::StateRepo.new)
  RageArch.register(:notification_repo, Notifications::NotificationRepo.new)
  RageArch.register(:subscription_repo, Push::SubscriptionRepo.new)
  RageArch.register(:conversation_repo, Whatsapp::ConversationRepo.new)
  RageArch.register(:whatsapp_citizen_repo, Whatsapp::CitizenRepo.new)

  publisher = RageArch::EventPublisher.new
  RageArch::UseCase::Base.wire_subscriptions_to(publisher)
  RageArch.register(:event_publisher, publisher)
end
