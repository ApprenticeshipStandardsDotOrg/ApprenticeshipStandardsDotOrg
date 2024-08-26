class LowerCamelTransformer < Blueprinter::Transformer
  def transform(hash, object, options)
    # keys are symbols, have to convert to string to camelize then back to symbol
    hash.deep_transform_keys! { |key| key.to_s.camelize(:lower).to_sym }
  end
end

class BaseBlueprint < Blueprinter::Base
  transform LowerCamelTransformer
end
