defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true
  require IEx

  setup do
    PlateSlate.Seeds.run()
  end

  @menu_items [
    %{"name" => "Bánh mì"},
    %{"name" => "Chocolate Milkshake"},
    %{"name" => "Croque Monsieur"},
    %{"name" => "French Fries"},
    %{"name" => "Lemonade"},
    %{"name" => "Masala Chai"},
    %{"name" => "Muffuletta"},
    %{"name" => "Papadum"},
    %{"name" => "Pasta Salad"},
    %{"name" => "Reuben"},
    %{"name" => "Soft Drink"},
    %{"name" => "Vada Pav"},
    %{"name" => "Vanilla Milkshake"},
    %{"name" => "Water"},
  ]

  @query """
  {
    menuItems {
      name
    }
  }
  """
  test "menuItems field returns menu items" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query)

    assert %{"data" => %{"menuItems" => menu_items}} = json_response(conn, 200)
    assert Enum.all?([
        %{"name" => "Reuben"},
        %{"name" => "Croque Monsieur"},
        %{"name" => "Muffuletta"},
    ], fn item -> item in menu_items end)
  end

  @query """
  query validQuery($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
    }
  }
  """
  @variables %{filter: %{"name" => "reu"}}
  test "menuItems field returns menu items filtered by name" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query, variables: @variables)

    assert %{"data" => %{"menuItems" => menu_items}} = json_response(conn, 200)
    assert [%{"name" => "Reuben"}] = menu_items
  end

  @query """
  query invalidQuery($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
    }
  }
  """
  @variables %{filter: %{"name" => 123}}
  test "menuItems field returns errors when using a bad value" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query, variables: @variables)

    assert %{"errors" => [%{"message" => message}]} = json_response(conn, 400)
    assert message =~ ~s{Argument "filter" has invalid value $filter.}
  end

  @query """
  query filteredQuery($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
    }
  }
  """
  @variables %{filter: %{category: "Sandwiches", tag: "Vegetarian"}}
  test "menuItems field returns menuItems, filtering by category and tag" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)
    assert %{
      "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}
    } == json_response(response, 200)
  end

  @query """
  query orderedQuery($order: SortOrder) {
    menuItems(order: $order) {
      name
    }
  }
  """
  @variables %{order: "ASC"}
  test "menuItems field returns menu items ordered by ascending name" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query, variables: @variables)

    response_data = %{"data" => %{"menuItems" => @menu_items}}
    assert json_response(conn, 200) == response_data
  end

  @query """
  query orderedQuery($order: SortOrder) {
    menuItems(order: $order) {
      name
    }
  }
  """
  @variables %{order: "DESC"}
  test "menuItems field returns items ordered by descending name" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query, variables: @variables)

    menu_items = Enum.sort(@menu_items, &(&1 >= &2))
    response_data = %{"data" => %{"menuItems" => menu_items }}
    assert json_response(conn, 200) == response_data
  end

  @query """
  query ($id: ID) {
    menuItem(id: $id) {
      id
      name
    }
  }
  """
  test "menuItem field returns a menu item" do
    query = "query { menuItems { id name } }"
    conn = get(build_conn(), "/api", query: query)
    assert %{"data" => %{"menuItems" => [first_menu_item = %{"id" => first_menu_item_id} | _menu_items]}} = json_response(conn, 200)

    conn = get(build_conn(), "/api", query: @query, variables: %{id: first_menu_item_id})
    assert %{"data" => %{"menuItem" => first_menu_item}} = json_response(conn, 200)
  end

  @query """
  query ($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
      addedOn
    }
  }
  """
  @variables %{filter: %{"addedBefore" => "2019-08-11"}}
  test "menuItems filtered by custom scalar date" do
    sides = PlateSlate.Repo.get_by!(PlateSlate.Menu.Category, name: "Sides")
    %PlateSlate.Menu.Item{
      name: "Garlic Fries",
      added_on: ~D[2019-08-10],
      price: 2.50,
      category: sides
    } |> PlateSlate.Repo.insert!()

    response = get(build_conn(), "/api", query: @query, variables: @variables)
    assert %{
      "data" => %{
        "menuItems" => [%{"name" => "Garlic Fries", "addedOn" => "2019-08-10"}]
      }
    } == json_response(response, 200)
  end

  @query """
  query ($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
      addedOn
    }
  }
  """
  @variables %{filter: %{"addedBefore" => "not-a-date"}}
  test "menuItems filtered by custom scalar data with error" do
    response = get(conn, "/api", query: @query, variables: @variables)

    assert %{"errors" => [%{
             "locations" => [%{"column" => 0, "line" => 2}],
             "message" => message}]} = json_response(response, 400)

    expected = """
    Argument "filter" has invalid value $filter.
    In field "addedBefore": Expected type "Date", found "not-a-date".\
    """

    assert expected == message
  end
end