GravatarImageTag.configure do |config|
  config.default_image            = "https://cdn-bilbo.app.bilbo.mx/statics/default_avatar-1.png"   # Set this to use your own default gravatar image rather then serving up Gravatar's default image [ 'http://example.com/images/default_gravitar.jpg', :identicon, :monsterid, :wavatar, 404 ].
  config.secure                   = true # Set this to true if you require secure images on your pages.
end
