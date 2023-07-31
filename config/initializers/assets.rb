# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Include FoxitSDK npm package
Rails.application.config.assets.paths << Rails.root.join(
  "node_modules/@foxitsoftware/foxit-pdf-sdk-for-web-library-full"
)

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
