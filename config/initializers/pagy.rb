require "pagy/extras/overflow"
require "pagy/extras/elasticsearch_rails"
Pagy::DEFAULT[:overflow] = :last_page
Pagy::DEFAULT[:size] = [1, 4, 4, 1]

Pagy::I18n.load(
  {locale: "en", filepath: "config/locales/pagy.yml"}
)
