RSpec.feature "Managing parts for a product bundle", type: :feature, js: true do
  stub_authorization!

  given!(:tshirt) { create(:product, :name => "T-Shirt") }
  given!(:mug) { create(:product, :name => "Mug", can_be_part: true) }

  context "when searching for parts" do
    background do
      visit spree.admin_product_path(tshirt)
      click_on "Parts"
    end

    scenario "returns empty results when there is no query" do
      fill_in "searchtext", with: ""
      click_on "Search"

      expect(page).to have_content("No Match Found.")
    end

    scenario "displays no-match feedback when it does not find any products" do
      fill_in "searchtext", with: "Foo"
      click_on "Search"

      expect(page).to have_content("No Match Found.")
    end

    scenario "shows any products that were found" do
      fill_in "searchtext", with: mug.name
      click_on "Search"

      expect(page).to have_content(mug.name)
    end
  end

  context "when adding parts to a bundle" do
    scenario "allows adding a product with no variants" do
      visit spree.admin_product_path(tshirt)
      click_on "Parts"
      fill_in "searchtext", with: mug.name
      click_on "Search"

      within("#search_hits") { click_on "Select" }
      expect(page).to have_content(mug.sku)
    end

    context "when a part has multiple variants" do
      def build_option(options)
        option_type_name = options.fetch(:type)
        option_type = create(:option_type,
          presentation: option_type_name,
          name: option_type_name
        )
        option_value = options.fetch(:value)
        option_type.option_values.create(
          name: option_value.downcase,
          presentation: option_value
        )

        option_type
      end

      def build_part_with_options(product_name, option_type)
        product = create(:product,
          can_be_part: true,
          name: product_name,
          option_types: [option_type]
        )
        create(:variant,
          product: product,
          option_values: option_type.option_values
        )
      end

     scenario "allows a specific variant to be selected as part of the bundle" do
        bundle = create(:product)
        option = build_option(type: "Color", value: "Red")
        part = build_part_with_options("Shirt", option)

        visit spree.admin_product_path(bundle)
        click_on "Parts"
        fill_in "searchtext", with: "Shirt"
        click_on "Search"

        if Spree.version.to_f > 4.0
          find('#s2id_part_id').click
          find('div.select2-result-label', text: 'Color: Red').click
        else
          select 'Color: Red', from: 'part_id'
        end

        click_on "Select"

        expect(page).to have_content(part.sku)
      end

      scenario "allows admin to specify that user can select any variant" do
        bundle = create(:product)
        option = build_option(type: "Color", value: "Red")
        part = build_part_with_options("Shirt", option)

        visit spree.admin_product_path(bundle)
        click_on "Parts"
        fill_in "searchtext", with: "Shirt"
        click_on "Search"

        if Spree.version.to_f > 4.0
          find('#s2id_part_id').click
          find('div.select2-result-label', text: Spree.t(:user_selectable)).click
        else
          select Spree.t(:user_selectable), from: "part_id"
        end

        within("#search_hits") do
          fill_in "part_count", with: 666
          click_on "Select"
        end

        within("#product_parts") do
          expect(page).to have_content("Shirt")
          expect(page).to have_content(part.product.sku)
          expect(page).to have_content(Spree.t(:user_selectable))

          input = find_field("count")
          expect(input[:value]).to eq("666")
        end
      end
    end
  end

  scenario "allows parts to be removed from the bundle" do
    visit spree.admin_product_path(tshirt)
    click_on "Parts"
    fill_in "searchtext", with: mug.name
    click_on "Search"

    within('#search_hits .actions') { click_on "Select" }
    expect(page).to have_content(mug.sku)

    within("#product_parts") do
      find(".remove_admin_product_part_link").click

      expect(page).not_to have_content(mug.sku)
    end
  end

  context "when updating part quantities" do
    before do
      visit spree.admin_product_path(tshirt)
      click_on "Parts"
      fill_in "searchtext", with: mug.name
      click_on "Search"

      wait_for_ajax
      within("#search_hits") { click_on "Select" }
    end

    scenario "updates the quantity to match the newly-supplied value" do
      within("#product_parts") do
        fill_in "count", with: "5"
        find(".set_count_admin_product_part_link").click

        wait_for_ajax
        expect(find_field('count').value).to eq "5"
      end
    end

    scenario "rejects a negative quantity" do
      within("#product_parts") do
        fill_in "count", with: "-1"
        find(".set_count_admin_product_part_link").click
      end

      expect(page).to have_content("Quantity must be greater than 0")
    end

    scenario "rejects a part quantity of `0`" do
      within("#product_parts") do
        fill_in "count", with: "0"
        find(".set_count_admin_product_part_link").click
      end

      expect(page).to have_content("Quantity must be greater than 0")
    end

    scenario "rejects a non-numeric part quantity" do
      within("#product_parts") do
        fill_in "count", with: "non-numeric"
        find(".set_count_admin_product_part_link").click
      end

      expect(page).to have_content("Quantity must be greater than 0")
    end
  end
end
