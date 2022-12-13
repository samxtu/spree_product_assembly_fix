module Spree
  describe OrderInventoryAssembly, type: :model do
    describe "#verify" do
      context "when line item involves variants that are not user-selectable" do
        context "when a shipment is provided" do
          context "when the bundle is created" do
            it "produces inventory units for each item in the bundle" do
              shipment, line_item, variants = create_line_item_for_bundle(
                parts: [{ count: 1 }, { count: 1 }, { count: 3 }]
              )
              inventory = OrderInventoryAssembly.new(line_item)
              inventory.verify(shipment)


              expect(get_quantity_for_inventory_units(inventory.inventory_units)).to eq 5

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 3
            end
          end

          context "when the bundle quantity is increased" do
            it "adds [difference in quantity] sets of inventory units" do
              shipment, line_item, variants = create_line_item_for_bundle(
                parts: [{ count: 1 }, { count: 1 }, { count: 3 }]
              )
              inventory = OrderInventoryAssembly.new(line_item)
              inventory.verify(shipment)

              expect(get_quantity_for_inventory_units(inventory.inventory_units)).to eq 5

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 3

              line_item.update_column(:quantity, 2)
              inventory = OrderInventoryAssembly.new(line_item.reload)
              inventory.verify(shipment)


              expect(get_quantity_for_inventory_units(inventory.inventory_units)).to eq 10

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 2
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 2
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 6
            end
          end

          context "when the bundle quantity is decreased" do
            it "removes [difference in quantity] sets of inventory units" do
              shipment, line_item, variants = create_line_item_for_bundle(
                line_item_quantity: 2,
                parts: [{ count: 1 }, { count: 1 }, { count: 3 }]
              )
              inventory = OrderInventoryAssembly.new(line_item)
              inventory.verify(shipment)

              expect(get_quantity_for_inventory_units(inventory.inventory_units)).to eq 10

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 2
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 2
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 6

              line_item.update_column(:quantity, 1)
              inventory = OrderInventoryAssembly.new(line_item.reload)
              inventory.verify(shipment)

              expect(get_quantity_for_inventory_units(inventory.inventory_units)).to eq 5

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 3
            end
          end
        end

        context "when a shipment is not provided" do
          context "when the bundle is created" do
            it "produces inventory units for each item in the bundle" do
              shipment, line_item, variants = create_line_item_for_bundle(
                parts: [{ count: 1 }, { count: 1 }, { count: 3 }]
              )
              inventory = OrderInventoryAssembly.new(line_item)
              inventory.verify

              expect(get_quantity_for_inventory_units(inventory.inventory_units)).to eq 5

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 3
            end
          end

          context "when the bundle quantity is increased" do
            it "adds [difference in quantity] sets of inventory units" do
              shipment, line_item, variants = create_line_item_for_bundle(
                parts: [{ count: 1 }, { count: 1 }, { count: 3 }]
              )
              inventory = OrderInventoryAssembly.new(line_item)
              inventory.verify

              expect(get_quantity_for_inventory_units(inventory.inventory_units)).to eq 5

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 3

              line_item.update_column(:quantity, 2)
              inventory = OrderInventoryAssembly.new(line_item.reload)
              inventory.verify

              expect(get_quantity_for_inventory_units(inventory.inventory_units)).to eq 10

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 2
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 2
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 6
            end
          end

          context "when the bundle quantity is decreased" do
            it "removes [difference in quantity] sets of inventory units" do
              shipment, line_item, variants = create_line_item_for_bundle(
                line_item_quantity: 2,
                parts: [{ count: 1 }, { count: 1 }, { count: 3 }]
              )
              inventory = OrderInventoryAssembly.new(line_item)
              inventory.verify

              expect(get_quantity_for_inventory_units(inventory.inventory_units)).to eq 10

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 2
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 2
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 6

              line_item.update_column(:quantity, 1)
              inventory = OrderInventoryAssembly.new(line_item.reload)
              inventory.verify

              expect(get_quantity_for_inventory_units(inventory.inventory_units)).to eq 5

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 3
            end

            context "when the bundle has shipped and unshipped shipments" do
              xit "removes the items from only the unshipped shipments" do
                unshipped_shipment,
                line_item,
                variants = create_line_item_for_bundle(
                  line_item_quantity: 2,
                  parts: [{ count: 1 }, { count: 1 }, { count: 3 }]
                )
                shipped_shipment = create(:shipment, state: 'shipped')
                InventoryUnit.all[0..1].each do |unit|
                  unit.update_attribute(:shipment_id, shipped_shipment.id)
                end

                inventory = OrderInventoryAssembly.new(line_item)

                line_item.update_column(:quantity, 1)
                inventory.verify

                expect(get_quantity_for_inventory_units(inventory.inventory_units)).to eq 7

                unshipped_units = unshipped_shipment.inventory_units
                expect(get_quantity_for_inventory_units(unshipped_units)).to eq 3
                unshipped_units.each do |unit|
                  expect(unit.variant).to eq variants[2]
                end

                shipped_units = shipped_shipment.inventory_units
                expect(get_quantity_for_inventory_units(shipped_units)).to eq 4
                expect(shipped_units[0].variant).to eq variants[0]
                expect(shipped_units[1].variant).to eq variants[1]
              end
            end
          end
        end
      end

      context "when line item involves user-selectable variants" do
        context "when a shipment is provided" do
          context "when the bundle is created" do
            it "produces inventory units for each item in the bundle" do
              shipment, line_item, variants = create_line_item_for_bundle(
                line_item_quantity: 1,
                parts: [
                  { count: 1 },
                  { count: 1 },
                  { count: 3, variant_selection_deferred: true }
                ]
              )

              inventory = OrderInventoryAssembly.new(line_item)
              inventory.verify(shipment)

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 3
            end
          end

          # expect(get_quantity_for_inventory_units(inventory.inventory_units)).to eq 10

          context "when the bundle quantity is increased" do
            it "adds [difference in quantity] sets of inventory units" do
              shipment, line_item, variants = create_line_item_for_bundle(
                parts: [
                  { count: 1 },
                  { count: 1 },
                  { count: 3, variant_selection_deferred: true }
                ]
              )

              inventory = OrderInventoryAssembly.new(line_item)
              inventory.verify(shipment)

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 3

              line_item.update_column(:quantity, 2)
              inventory = OrderInventoryAssembly.new(line_item.reload)
              inventory.verify(shipment)

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 2
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 2
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 6
            end
          end

          context "when the bundle quantity is decreased" do
            it "removes [difference in quantity] sets of inventory units" do
              shipment, line_item, variants = create_line_item_for_bundle(
                line_item_quantity: 2,
                parts: [
                  { count: 1 },
                  { count: 1 },
                  { count: 3, variant_selection_deferred: true }
                ]
              )

              inventory = OrderInventoryAssembly.new(line_item)
              inventory.verify(shipment)

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 2
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 2
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 6

              line_item.update_column(:quantity, 1)
              inventory = OrderInventoryAssembly.new(line_item.reload)
              inventory.verify(shipment)

              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[0]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[1]))).to eq 1
              expect(get_quantity_for_inventory_units(shipment.inventory_units_for(variants[2]))).to eq 3
            end
          end
        end
      end
    end

    def create_line_item_for_bundle(args)
      parts = args.fetch(:parts)
      line_item_quantity = args.fetch(:line_item_quantity, 1)
      order = create(:order, completed_at: Time.now)
      shipment = create(:shipment, order: order)
      bundle = create(:product, name: "Bundle")

      red_option = create(:option_value, presentation: "Red")
      blue_option = create(:option_value, presentation: "Blue")

      option_type = create(:option_type, presentation: "Color",
                                         name: "color",
                                         option_values: [
                                           red_option,
                                           blue_option
                                         ])

      variants = []
      selected_variants = {}
      parts.each do |part|
        product_properties = { can_be_part: true }
        if part[:variant_selection_deferred]
          product_properties[:option_types] = [option_type]
        end

        product = create(:product_in_stock, product_properties)

        assemblies_part_attributes = { assembly: bundle.master }.merge(part)

        if part[:variant_selection_deferred]
          create(:variant_in_stock, product: product,
                                    option_values: [red_option])
          variants << create(:variant_in_stock, product: product,
                                                option_values: [blue_option])
        else
          variants << product.master
        end

        assemblies_part_attributes[:part] = product.master
        create(:assemblies_part, assemblies_part_attributes)

        if part[:variant_selection_deferred]
          selected_variants = {
            "selected_variants" => {
              "#{bundle.master.parts_variants.last.part_id}" => "#{variants.last.id}"
            }
          }
        end
      end

      bundle.reload

      line_item = Spree::Cart::AddItem.call(
        order: order,
        variant: bundle.master,
        quantity: line_item_quantity,
        options: {
          selected_variants: selected_variants,
          populate: true
        }
      ).value
      line_item.reload

      [shipment, line_item, variants]
    end

    def get_quantity_for_inventory_units(inventory_units)
      if Gem.loaded_specs['spree_core'].version >= Gem::Version.create('3.3.0')
        inventory_units.sum(&:quantity)
      else
        inventory_units.count
      end
    end
  end
end
