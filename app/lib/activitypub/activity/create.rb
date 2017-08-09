# frozen_string_literal: true

class ActivityPub::Activity::Create < ActivityPub::Activity
  def perform
    return if delete_arrived_first?(object_uri) || unsupported_object_type?

    status = Status.find_by(uri: object_uri)

    return status unless status.nil?

    ApplicationRecord.transaction do
      status = Status.create!(status_params)

      process_tags(status)
      process_attachments(status)
    end

    resolve_thread(status)
    distribute(status)

    status
  end

  private

  def status_params
    {
      uri: @object['id'],
      url: @object['url'],
      account: @account,
      text: text_from_content || '',
      language: language_from_content,
      spoiler_text: @object['summary'] || '',
      created_at: @object['published'] || Time.now.utc,
      reply: @object['inReplyTo'].present?,
      sensitive: @object['sensitive'] || false,
      visibility: visibility_from_audience,
      thread: replied_to_status,
      conversation: conversation_from_uri(@object['_:conversation']),
    }
  end

  def process_tags(status)
    return unless @object['tag'].is_a?(Array)

    @object['tag'].each do |tag|
      case tag['type']
      when 'Hashtag'
        process_hashtag tag, status
      when 'Mention'
        process_mention tag, status
      end
    end
  end

  def process_hashtag(tag, status)
    hashtag = tag['name'].gsub(/\A#/, '').mb_chars.downcase
    hashtag = Tag.where(name: hashtag).first_or_initialize(name: hashtag)

    status.tags << hashtag
  end

  def process_mention(tag, status)
    account = account_from_uri(tag['href'])
    account = ActivityPub::FetchRemoteAccountService.new.call(tag['href']) if account.nil?
    return if account.nil?
    account.mentions.create(status: status)
  end

  def process_attachments(status)
    return unless @object['attachment'].is_a?(Array)

    @object['attachment'].each do |attachment|
      next if unsupported_media_type?(attachment['mediaType'])

      href             = Addressable::URI.parse(attachment['url']).normalize.to_s
      media_attachment = MediaAttachment.create(status: status, account: status.account, remote_url: href)

      next if skip_download?

      media_attachment.file_remote_url = href
      media_attachment.save
    end
  end

  def resolve_thread(status)
    return unless status.reply? && status.thread.nil?
    ActivityPub::ThreadResolveWorker.perform_async(status.id, @object['inReplyTo'])
  end

  def conversation_from_uri(uri)
    return nil if uri.nil?
    return Conversation.find_by(id: TagManager.instance.unique_tag_to_local_id(uri, 'Conversation')) if TagManager.instance.local_id?(uri)
    Conversation.find_by(uri: uri) || Conversation.create!(uri: uri)
  end

  def visibility_from_audience
    if equals_or_includes?(@object['to'], ActivityPub::TagManager::COLLECTIONS[:public])
      :public
    elsif equals_or_includes?(@object['cc'], ActivityPub::TagManager::COLLECTIONS[:public])
      :unlisted
    elsif equals_or_includes?(@object['to'], @account.followers_url)
      :private
    else
      :direct
    end
  end

  def audience_includes?(account)
    uri = ActivityPub::TagManager.instance.uri_for(account)
    equals_or_includes?(@object['to'], uri) || equals_or_includes?(@object['cc'], uri)
  end

  def replied_to_status
    return if @object['inReplyTo'].blank?
    @replied_to_status ||= status_from_uri(@object['inReplyTo'])
  end

  def text_from_content
    if @object['content'].present?
      @object['content']
    elsif language_map?
      @object['contentMap'].values.first
    end
  end

  def language_from_content
    return nil unless language_map?
    @object['contentMap'].keys.first
  end

  def language_map?
    @object['contentMap'].is_a?(Hash) && !@object['contentMap'].empty?
  end

  def unsupported_object_type?
    @object.is_a?(String) || !%w(Article Note).include?(@object['type'])
  end

  def unsupported_media_type?(mime_type)
    mime_type.present? && !(MediaAttachment::IMAGE_MIME_TYPES + MediaAttachment::VIDEO_MIME_TYPES).include?(mime_type)
  end

  def skip_download?
    return @skip_download if defined?(@skip_download)
    @skip_download ||= DomainBlock.find_by(domain: @account.domain)&.reject_media?
  end
end
