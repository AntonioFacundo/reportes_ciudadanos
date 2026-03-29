# frozen_string_literal: true

module Reports
  class Broadcaster
    def self.broadcast_report_updated(report)
      Turbo::StreamsChannel.broadcast_refresh_to(report)
      Turbo::StreamsChannel.broadcast_refresh_to(:inbox)
      Turbo::StreamsChannel.broadcast_refresh_to(:reports)
    end

    def self.broadcast_and_notify(report, event:)
      broadcast_report_updated(report)
      notify_push(report, event)
      notify_in_app(report, event)
    end

    def self.notify_push(report, event)
      case event
      when :read
        notify_reporter_read(report)
      when :assigned
        notify_assignee(report)
        notify_reporter_assigned(report)
      when :resolved
        notify_reporter(report)
      when :rejected
        notify_assignee_rejected(report)
      when :created
        notify_inbox_new_report(report)
      end
    end

    def self.notify_in_app(report, event)
      case event
      when :read
        create_in_app(report.reporter_id, I18n.t("notifications.read.title"), I18n.t("notifications.read.body", category: report.category&.name), report_path(report))
      when :assigned
        create_in_app(report.assignee_id, I18n.t("notifications.assigned.title"), I18n.t("notifications.assigned.body", category: report.category&.name), report_path(report)) if report.assignee_id
        create_in_app(report.reporter_id, I18n.t("notifications.assigned_to_reporter.title"), I18n.t("notifications.assigned_to_reporter.body", category: report.category&.name, assignee: report.assignee&.name), report_path(report)) if report.assignee_id
      when :resolved
        create_in_app(report.reporter_id, I18n.t("notifications.resolved.title"), I18n.t("notifications.resolved.body", category: report.category&.name), report_path(report))
      when :rejected
        create_in_app(report.assignee_id, I18n.t("notifications.rejected.title"), I18n.t("notifications.rejected.body"), report_path(report)) if report.assignee_id
      when :created
        users_to_notify = User.active.where(role: "system_admin")
        users_to_notify = users_to_notify.or(User.active.where(role: "mayor", alcaldia_id: report.alcaldia_id)) if report.alcaldia_id.present?
        users_to_notify.find_each do |user|
          create_in_app(user.id, I18n.t("notifications.new_report.title"), I18n.t("notifications.new_report.body", category: report.category&.name), inbox_path)
        end
      end
    end

    def self.create_in_app(user_id, title, body, path)
      notification = Notification.create!(user_id: user_id, title: title, body: body, path: path)
      stream = "notifications_#{user_id}"
      Turbo::StreamsChannel.broadcast_prepend_to(stream, target: "notifications_list", partial: "notifications/notification", locals: { notification: notification })
      Turbo::StreamsChannel.broadcast_replace_to(stream, target: "notifications_badge", partial: "notifications/badge", locals: { count: User.find(user_id).notifications.unread.count })
      Turbo::StreamsChannel.broadcast_remove_to(stream, target: "notifications_empty")
    end

    def self.notify_reporter_read(report)
      NotifyPushJob.perform_later(
        report.reporter_id,
        title: I18n.t("notifications.read.title"),
        body: I18n.t("notifications.read.body", category: report.category&.name),
        path: report_path(report)
      )
    end

    def self.notify_assignee(report)
      return unless report.assignee_id
      NotifyPushJob.perform_later(
        report.assignee_id,
        title: I18n.t("notifications.assigned.title"),
        body: I18n.t("notifications.assigned.body", category: report.category&.name),
        path: report_path(report)
      )
    end

    def self.notify_reporter_assigned(report)
      return unless report.assignee_id
      NotifyPushJob.perform_later(
        report.reporter_id,
        title: I18n.t("notifications.assigned_to_reporter.title"),
        body: I18n.t("notifications.assigned_to_reporter.body", category: report.category&.name, assignee: report.assignee&.name),
        path: report_path(report)
      )
    end

    def self.notify_reporter(report)
      NotifyPushJob.perform_later(
        report.reporter_id,
        title: I18n.t("notifications.resolved.title"),
        body: I18n.t("notifications.resolved.body", category: report.category&.name),
        path: report_path(report)
      )
    end

    def self.notify_assignee_rejected(report)
      return unless report.assignee_id
      NotifyPushJob.perform_later(
        report.assignee_id,
        title: I18n.t("notifications.rejected.title"),
        body: I18n.t("notifications.rejected.body"),
        path: report_path(report)
      )
    end

    def self.notify_inbox_new_report(report)
      users_to_notify = User.active.where(role: "system_admin")
      users_to_notify = users_to_notify.or(User.active.where(role: "mayor", alcaldia_id: report.alcaldia_id)) if report.alcaldia_id.present?
      users_to_notify.find_each do |user|
        NotifyPushJob.perform_later(
          user.id,
          title: I18n.t("notifications.new_report.title"),
          body: I18n.t("notifications.new_report.body", category: report.category&.name),
          path: inbox_path
        )
      end
    end

    def self.report_path(report)
      Rails.application.routes.url_helpers.report_url(report)
    end

    def self.inbox_path
      Rails.application.routes.url_helpers.inbox_url
    end
  end
end
