class PagesController < ApplicationController
    def sitemap
      redirect_to "https://#{ENV.fetch('CDN_HOST')}/sitemaps/sitemap.xml"
    end

    def robots
        respond_to :text
        expires_in 6.hours, public: true
      end    
  end
  