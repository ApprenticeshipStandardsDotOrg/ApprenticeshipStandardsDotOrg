class DataImportsController < ApplicationController
  def new
    @data_import = DataImport.new
  end
end