require "pagy/extras/overflow"
require "pagy/extras/elasticsearch_rails"
Pagy::DEFAULT[:overflow] = :last_page
Pagy::DEFAULT[:size] = 4

Pagy::I18n.load(
  {locale: "en", filepath: "config/locales/pagy.yml"}
)
