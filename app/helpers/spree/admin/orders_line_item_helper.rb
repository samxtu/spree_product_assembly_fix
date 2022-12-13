module Spree
  module Admin
    module OrdersLineItemHelper
      def shipment_price(line_item, quantity)
        Spree::Money.new(line_item.price * quantity, { currency: line_item.currency })
      end
    end
  end
end
