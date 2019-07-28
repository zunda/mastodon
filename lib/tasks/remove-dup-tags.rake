namespace :db do
  desc 'Merge duplicate tags'
  task remove_dup_tags: :environment do
    ActiveRecord::Base.transaction do
      con = ActiveRecord::Base.connection

      dup_ids = con.select_rows(<<-'_SQL'
        SELECT JSON_AGG(id ORDER BY id) AS ids
            FROM tags
            WHERE name IN (SELECT name FROM tags GROUP BY name HAVING COUNT(1) > 1)
            GROUP BY name;
        _SQL
      ).map{|x| JSON.parse(x.first)}
      puts "IDs for duplicate tags:"
      puts dup_ids.map{|x| "\t" + x.join(', ')}

      %w(featured_tags statuses_tags).each do |table|
        puts "Merging tags on #{table}..."
        dup_ids.each do |target_id, *src_ids|
          src_ids.each do |src_id|
            con.execute("UPDATE #{table} SET tag_id=#{target_id} WHERE tag_id=#{src_id};")
          end
        end
      end

      # It seems that there is no accounts_count in account_tag_stats table:
      # SELECT accounts_count FROM account_tag_stats WHERE accounts_count > 0 returnes 0 rows
      puts "Deleting tags that are no longer in use..."
      dup_ids.each do |target_id, *src_ids|
        src_ids.each do |src_id|
          con.execute("DELETE FROM account_tag_stats WHERE tag_id=#{src_id};")
          con.execute("DELETE FROM tags WHERE id=#{src_id};")
        end
      end
    end
  end
end
