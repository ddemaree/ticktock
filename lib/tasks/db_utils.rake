namespace :ticktock do
  
  namespace :db do

    desc "Fixes tagging counts on labels"
    task :fix_tagging_counts => :environment do
      Label.all.each do |label|
        tagging_count = label.taggings.count
        Label.update_all "taggings_count = #{tagging_count}", "id = #{label.id}"
      end
    end

  end
  
end