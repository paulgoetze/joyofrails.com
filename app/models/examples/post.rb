class Examples::Post < ApplicationRecord
  delegated_type :postable, types: %w[
    Examples::Posts::Markdown
    Examples::Posts::Link
    Examples::Posts::Image
  ]
end
