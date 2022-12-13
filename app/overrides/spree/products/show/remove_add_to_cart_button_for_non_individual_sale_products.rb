Deface::Override.new(
  virtual_path: 'spree/products/show',
  name:         'remove_add_to_cart_button_for_non_individual_sale_products',
  surround:     '[data-hook="cart_form"]',
  text:         <<-HTML
                  <% if @product.individual_sale? %>
                    <%= render_original %>
                  <% end %>
                HTML
)
