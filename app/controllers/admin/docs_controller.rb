module Admin
  class DocsController < Admin::ApplicationController
    def index
      authorize :docs
    end
  end
end
