# frozen_string_literal: true

class InstancePresenter
  def user_count
    @user_count ||= Rails.cache.fetch('user_count', expires_in: 37.hours) { User.confirmed.count }
  end

  def status_count
    @status_count ||= Rails.cache.fetch('local_status_count', expires_in: 11.hours) { Status.local.count }
  end

  def domain_count
    @domain_count ||= Rails.cache.fetch('distinct_domain_count', expires_in: 17.hours) { Account.distinct.count(:domain) }
  end

  def thumbnail
    @thumbnail ||= Rails.cache.fetch('site_uploads/thumbnail', expires_in: 21.hours) { SiteUpload.find_by(var: 'thumbnail') }
  end
end
