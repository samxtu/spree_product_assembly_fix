Deface::Override.new(
  virtual_path: 'spree/checkout/_delivery',
  name: 'remove_unshippable_markup',
  remove: '.unshippable',
)
