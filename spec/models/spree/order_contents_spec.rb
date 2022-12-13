if Spree.version.to_f < 3.7
  describe Spree::OrderContents, type: :model do
    describe "#add_to_line_item" do
      context "given a variant which is an assembly" do
        it "creates a PartLineItem for each part of the assembly" do
          order = create(:order)
          assembly = create(:product)
          pieces = create_list(:product, 2)
          pieces.each do |piece|
            create(:assemblies_part, assembly: assembly.master, part: piece.master)
          end

          line_item = Spree::Cart::AddItem.call(
            order: order,
            variant: assembly.master,
            quantity: 1,
            options: {
              populate: true
            }
          )

          part_line_items = line_item.part_line_items

          expect(part_line_items[0].line_item_id).to eq line_item.id
          expect(part_line_items[0].variant_id).to eq pieces[0].master.id
          expect(part_line_items[0].quantity).to eq 1
          expect(part_line_items[1].line_item_id).to eq line_item.id
          expect(part_line_items[1].variant_id).to eq pieces[1].master.id
          expect(part_line_items[1].quantity).to eq 1
        end
      end

      context "given parts of an assembly" do
        xit "creates a PartLineItem for each part" do # doesnt work on travis ci because of issues with database cleaner
          order = create(:order)
          assembly = create(:product)

          red_option = create(:option_value, presentation: "Red")
          blue_option = create(:option_value, presentation: "Blue")

          option_type = create(:option_type,
                              presentation: "Color",
                              name: "color",
                              option_values: [
                                red_option,
                                blue_option
                              ])

          keychain = create(:product_in_stock)

          shirt = create(:product_in_stock,
                        option_types: [option_type],
                        can_be_part: true)

          create(:variant_in_stock, product: shirt, option_values: [red_option])
          create(:variant_in_stock, product: shirt, option_values: [blue_option])

          assembly_part_keychain = create(:assemblies_part,
                assembly_id: assembly.id,
                part_id: keychain.master.id)
          assembly_part_shirt = create(:assemblies_part,
                assembly_id: assembly.id,
                part_id: shirt.master.id,
                variant_selection_deferred: true)
          assembly.reload

          Spree::Cart::AddItem.call(order: order, variant: assembly.master, quantity: 1, options: {
            "selected_variants" => {
              "#{assembly_part_keychain.part_id}" => "#{keychain.master.id}",
              "#{assembly_part_shirt.part_id}" => "#{shirt.variants.last.id}"
            }, populate: true
          })

          part_line_items = line_item.part_line_items

          expect(part_line_items[0].line_item_id).to eq line_item.id
          expect(part_line_items[0].variant_id).to eq keychain.master.id
          expect(part_line_items[0].quantity).to eq 1
          expect(part_line_items[1].line_item_id).to eq line_item.id
          expect(part_line_items[1].variant_id).to eq shirt.variants.last.id
          expect(part_line_items[1].quantity).to eq 1
        end
      end
    end
  end
end
