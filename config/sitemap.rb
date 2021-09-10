# Set the host name for URL creation
SitemapGenerator::Interpreter.send :include, ApplicationHelper
SitemapGenerator::Sitemap.default_host = "https://app.bilbo.mx"
SitemapGenerator::Sitemap.compress = false
SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new(fog_provider: 'AWS',
                                                                    use_iam_profile: true,
                                                                    fog_directory: ENV.fetch('S3_BUCKET_NAME') {""},
                                                                    fog_region: ENV.fetch('AWS_REGION') {""})

SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_host = "https://#{ENV.fetch('S3_BUCKET_NAME') {""}}.s3.amazonaws.com/"
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.ping_search_engines('https://app.bilbo.mx/sitemap')
SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.

  Board.enabled.where(smart: true).find_each do |board|
    begin
        add bilbo_landing_path(board.country_state, board.city, board.parameterized_name), :lastmod => board.updated_at
    rescue
        true
    end
  end
end