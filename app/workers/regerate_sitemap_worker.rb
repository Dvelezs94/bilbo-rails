class RegenerateSitemapWorker
    include Sidekiq::Worker
    require 'rake'
    sidekiq_options retry: false, dead: false
    def perform()
      Bilbo::Application.load_tasks
      Rake::Task['sitemap:refresh:no_ping'].invoke
    end
  end
  