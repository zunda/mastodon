# frozen_string_literal: true

module StatusThreadingConcern
  extend ActiveSupport::Concern

  def ancestors(limit, account = nil)
    find_statuses_from_tree_path(ancestor_ids(limit), account)
  end

  def descendants(limit, account = nil, max_child_id = nil, since_child_id = nil, depth = nil)
    find_statuses_from_tree_path(descendant_ids(limit, max_child_id, since_child_id, depth), account)
  end

  private

  def ancestor_ids(limit)
    key = "ancestors:#{id}"
    ancestors = Rails.cache.fetch(key)

    if ancestors.nil? || ancestors[:limit] < limit
      ids = ancestor_statuses(limit).pluck(:id).reverse!
      Rails.cache.write key, limit: limit, ids: ids
      ids
    else
      ancestors[:ids].last(limit)
    end
  end

  def ancestor_statuses(limit)
    Status.find_by_sql([<<-SQL.squish, id: in_reply_to_id, limit: limit])
      WITH RECURSIVE search_tree(id, in_reply_to_id, path)
      AS (
        SELECT id, in_reply_to_id, ARRAY[id]
        FROM statuses
        WHERE id = :id
        UNION ALL
        SELECT statuses.id, statuses.in_reply_to_id, path || statuses.id
        FROM search_tree
        JOIN statuses ON statuses.id = search_tree.in_reply_to_id
        WHERE NOT statuses.id = ANY(path)
      )
      SELECT id
      FROM search_tree
      ORDER BY path
      LIMIT :limit
    SQL
  end

  def descendant_ids(limit, max_child_id, since_child_id, depth)
    descendant_statuses(limit, max_child_id, since_child_id, depth).pluck(:id)
  end

  def descendant_statuses(limit, max_child_id, since_child_id, depth)
    Status.find_by_sql([<<-SQL.squish, id: id, limit: limit, max_child_id: max_child_id, since_child_id: since_child_id, depth: depth])
      WITH RECURSIVE search_tree(id, path)
      AS (
        SELECT id, ARRAY[id]
        FROM statuses
        WHERE in_reply_to_id = :id AND COALESCE(id < :max_child_id, TRUE) AND COALESCE(id > :since_child_id, TRUE)
        UNION ALL
        SELECT statuses.id, path || statuses.id
        FROM search_tree
        JOIN statuses ON statuses.in_reply_to_id = search_tree.id
        WHERE COALESCE(array_length(path, 1) < :depth, TRUE) AND NOT statuses.id = ANY(path)
      )
      SELECT id
      FROM search_tree
      ORDER BY path
      LIMIT :limit
    SQL
  end

  def find_statuses_from_tree_path(ids, account)
    statuses = statuses_with_accounts(ids).to_a

    # FIXME: n+1 bonanza
    statuses.reject! { |status| filter_from_context?(status, account) }

    # Order ancestors/descendants by tree path
    statuses.sort_by! { |status| ids.index(status.id) }
  end

  def statuses_with_accounts(ids)
    Status.where(id: ids).includes(:account)
  end

  def filter_from_context?(status, account)
    StatusFilter.new(status, account).filtered?
  end
end
