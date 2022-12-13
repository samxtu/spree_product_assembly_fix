RSpec.feature "Checkout unshipabble", type: :feature, js: true do
  describe 'checkout with unshippable items', type: :feature, js: true do
    let!(:stock_location) { create(:stock_location) }
    let(:order) { OrderWalkthrough.up_to(:delivery) }
    let!(:bundle_line_item) { create(:line_item, order: order, product: bundle) }
    let!(:bundle) { create(:product, name: "RoR Mugs") }
    let!(:variant) { create(:variant) }

    before do
      bundle.master.parts.push variant
      OrderWalkthrough.add_line_item!(order)
      line_item = order.line_items.last
      stock_item = stock_location.stock_item(line_item.variant)
      stock_item.adjust_count_on_hand(-999)
      stock_item.backorderable = false
      stock_item.save!

      user = create(:user)
      order.user = user
      order.update_with_updater!

      allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: order)
      allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: user)
      allow_any_instance_of(Spree::CheckoutController).to receive_messages(skip_state_validation?: true)
      allow_any_instance_of(Spree::CheckoutController).to receive_messages(ensure_sufficient_stock_lines: true)

      visit spree.checkout_state_path(:delivery)

      expect(order.line_items.count).to eq 3

      click_button 'Save and Continue'
      order.reload
    end

    it 'removes but does not display unshipabble item' do
      expect(order.line_items.count).to eq 2

      expect(page).to_not have_css('.shipment.unshippable')
      expect(page).to_not have_content('Unshippable Items')
    end

    it 'keeps bundle in order' do
      expect(order.products).to include bundle
    end
  end
end
