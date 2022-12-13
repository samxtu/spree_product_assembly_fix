Deface::Override.new(
  virtual_path: 'spree/admin/orders/_form',
  name: 'inject_product_assemblies',
  insert_bottom: "[data-hook='admin_order_form_fields']",
  partial: 'spree/admin/orders/assemblies'
)
