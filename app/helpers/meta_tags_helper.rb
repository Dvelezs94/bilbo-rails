module MetaTagsHelper
    def opengraph_meta_tags
        # Creates opengraph meta tags for a specific bilbo landing page
        if controller_name.eql?("landing_pages") && action_name.eql?("show") && @board.present?
            "
            <meta property='og:locale' content='es_MX'/>
            <meta property='og:site_name' content='Bilbo'/>
            <meta property='og:type' content='website'/>
            <meta property='og:title' content='#{@board.name} en #{@board.short_address}'/>
            <meta property='og:description' content='Encuentra los mejores #{t("bilbos.#{@board.category}s")} cerca de #{@board.short_address} en Bilbo. Contrata #{@board.name} en #{@board.short_address} desde #{number_to_currency_usd(@board.minimum_budget)} #{ENV.fetch("CURRENCY")}'/>
            <meta property='og:url' content='#{request.original_url}'/>
            <meta property='og:image' content='#{url_from_media(@board.images.first)}'/>
            <meta property='twitter:card' content='summary_large_image'/>
            ".html_safe
        end
    end

    def seo_meta_tags
        # Sets default meta tags for improved SEO search results

    end
end