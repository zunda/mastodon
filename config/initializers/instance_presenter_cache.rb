# frozen_string_literal: true

class InstancePresenter
  MAX_CACHE_AGE = 36.hours

  def user_count
    Rails.cache.fetch('user_count', expires_in: MAX_CACHE_AGE) { User.confirmed.count }
  end

  def status_count
    Rails.cache.fetch('local_status_count', expires_in: MAX_CACHE_AGE) { Status.local.count }
  end

  def domain_count
    Rails.cache.fetch('distinct_domain_count', expires_in: MAX_CACHE_AGE) { Account.distinct.count(:domain) }
  end

  def thumbnail
    @thumbnail ||= Rails.cache.fetch('site_uploads/thumbnail', expires_in: MAX_CACHE_AGE) { SiteUpload.find_by(var: 'thumbnail') }
  end
end
