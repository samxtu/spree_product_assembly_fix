Deface::Override.new(
  virtual_path: 'spree/admin/orders/_shipment',
  name: 'stock_contents',
  replace_contents: '.stock-contents tbody',
  partial: 'spree/admin/orders/stock_contents'
)
